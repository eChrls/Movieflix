const mysql = require("mysql2/promise");
require("dotenv").config();

async function initDatabase() {
  console.log("🗄️  Inicializando base de datos MovieFlix...\n");

  let rootConnection;
  let appConnection;

  try {
    // Conexión como root para crear base de datos y usuario
    console.log("🔌 Conectando como root para configuración inicial...");
    rootConnection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: "root",
      password: process.env.DB_ROOT_PASSWORD || "",
    });

    console.log("✅ Conexión establecida");

    // Crear base de datos
    console.log(`🏗️  Creando base de datos '${process.env.DB_NAME}'...`);
    await rootConnection.execute(
      `CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
    );
    console.log("✅ Base de datos creada");

    // Crear usuario específico para la aplicación
    console.log(`👤 Creando usuario '${process.env.DB_USER}'...`);
    await rootConnection.execute(
      `CREATE USER IF NOT EXISTS '${process.env.DB_USER}'@'localhost' IDENTIFIED BY '${process.env.DB_PASSWORD}'`
    );
    await rootConnection.execute(
      `GRANT ALL PRIVILEGES ON ${process.env.DB_NAME}.* TO '${process.env.DB_USER}'@'localhost'`
    );
    await rootConnection.execute("FLUSH PRIVILEGES");
    console.log("✅ Usuario de aplicación creado con permisos");

    // Cerrar conexión root
    await rootConnection.end();

    // Conectar con el nuevo usuario para crear tablas
    console.log("🔗 Conectando con usuario de aplicación...");
    appConnection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log("📋 Creando tablas...\n");

    // Tabla de perfiles
    console.log("👥 Creando tabla profiles...");
    await appConnection.execute(`
      CREATE TABLE IF NOT EXISTS profiles (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE,
        emoji VARCHAR(10) DEFAULT '🎬',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Tabla de plataformas
    console.log("📱 Creando tabla platforms...");
    await appConnection.execute(`
      CREATE TABLE IF NOT EXISTS platforms (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE,
        icon VARCHAR(10) DEFAULT '📺',
        color VARCHAR(7) DEFAULT '#333333',
        url VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Tabla de géneros
    console.log("🎭 Creando tabla genres...");
    await appConnection.execute(`
      CREATE TABLE IF NOT EXISTS genres (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE,
        icon VARCHAR(10) DEFAULT '🎬',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Tabla de contenido
    console.log("🎬 Creando tabla content...");
    await appConnection.execute(`
      CREATE TABLE IF NOT EXISTS content (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        title_en VARCHAR(255),
        year INT,
        type ENUM('movie', 'series') NOT NULL,
        rating DECIMAL(3,1),
        runtime INT,
        genres JSON,
        overview TEXT,
        poster_path VARCHAR(500),
        backdrop_path VARCHAR(500),
        imdb_id VARCHAR(20),
        tmdb_id INT,
        platform_id INT,
        profile_id INT NOT NULL,
        status ENUM('pending', 'watched') DEFAULT 'pending',
        watched_at TIMESTAMP NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (platform_id) REFERENCES platforms(id) ON DELETE SET NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
        INDEX idx_profile_status (profile_id, status),
        INDEX idx_type (type),
        INDEX idx_rating (rating),
        INDEX idx_year (year),
        INDEX idx_title (title),
        INDEX idx_imdb_id (imdb_id),
        INDEX idx_tmdb_id (tmdb_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    console.log("✅ Todas las tablas creadas correctamente");

    // Crear tabla de cache para ratings de IMDb
    console.log("💾 Creando tabla de cache para ratings...");
    await appConnection.execute(`
      CREATE TABLE IF NOT EXISTS movie_ratings_cache (
        id INT PRIMARY KEY AUTO_INCREMENT,
        title VARCHAR(255) NOT NULL,
        year INT,
        imdb_rating DECIMAL(3,1),
        imdb_id VARCHAR(20),
        cached_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_title_year (title, year),
        INDEX idx_title (title),
        INDEX idx_cached_at (cached_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    console.log("✅ Tabla de cache creada correctamente\n");

    // Insertar datos iniciales
    console.log("📦 Insertando datos iniciales...\n");

    // Insertar perfil Home
    console.log("🏠 Creando perfil Home...");
    const [homeProfile] = await appConnection.execute(`
      INSERT IGNORE INTO profiles (name, emoji) VALUES ('Home', '🏠')
    `);

    // Obtener ID del perfil Home
    const [profiles] = await appConnection.execute(
      'SELECT id FROM profiles WHERE name = "Home"'
    );
    const homeProfileId = profiles[0].id;

    // Insertar plataformas con colores corporativos
    console.log("📱 Insertando plataformas de streaming...");
    const platforms = [
      {
        name: "Netflix",
        icon: "📺",
        color: "#E50914",
        url: "https://netflix.com",
      },
      { name: "HBO", icon: "🏛️", color: "#9B59B6", url: "https://hbomax.com" },
      {
        name: "Prime Video",
        icon: "📦",
        color: "#00A8E1",
        url: "https://primevideo.com",
      },
      {
        name: "Apple TV+",
        icon: "🍎",
        color: "#000000",
        url: "https://tv.apple.com",
      },
      {
        name: "Disney+",
        icon: "🏰",
        color: "#113CCF",
        url: "https://disneyplus.com",
      },
      {
        name: "SkyShowtime",
        icon: "🌌",
        color: "#0064FF",
        url: "https://skyshowtime.com",
      },
      {
        name: "Movistar+",
        icon: "📡",
        color: "#00B7ED",
        url: "https://movistarplus.es",
      },
      {
        name: "Filmin",
        icon: "🎪",
        color: "#FF6B35",
        url: "https://filmin.es",
      },
      {
        name: "Criterion Channel",
        icon: "🎯",
        color: "#FFD700",
        url: "https://criterionchannel.com",
      },
      {
        name: "Shudder",
        icon: "👻",
        color: "#FF4500",
        url: "https://shudder.com",
      },
      { name: "APK", icon: "📱", color: "#34C759", url: "" },
    ];

    for (const platform of platforms) {
      await appConnection.execute(
        `
        INSERT IGNORE INTO platforms (name, icon, color, url)
        VALUES (?, ?, ?, ?)
      `,
        [platform.name, platform.icon, platform.color, platform.url]
      );
    }

    // Insertar géneros con iconos
    console.log("🎭 Insertando géneros...");
    const genres = [
      { name: "Action", icon: "💥" },
      { name: "Adventure", icon: "🗺️" },
      { name: "Animation", icon: "🎨" },
      { name: "Comedy", icon: "😂" },
      { name: "Crime", icon: "🔫" },
      { name: "Documentary", icon: "📚" },
      { name: "Drama", icon: "🎭" },
      { name: "Family", icon: "👨‍👩‍👧‍👦" },
      { name: "Fantasy", icon: "🧙‍♂️" },
      { name: "History", icon: "🏛️" },
      { name: "Horror", icon: "👻" },
      { name: "Music", icon: "🎵" },
      { name: "Mystery", icon: "🔍" },
      { name: "Romance", icon: "💕" },
      { name: "Sci-Fi", icon: "🚀" },
      { name: "Thriller", icon: "⚡" },
      { name: "War", icon: "⚔️" },
      { name: "Western", icon: "🤠" },
      { name: "Workplace Drama", icon: "💼" },
      { name: "Political Drama", icon: "🏛️" },
      { name: "Spy", icon: "🕵️" },
      { name: "Biography", icon: "📖" },
    ];

    for (const genre of genres) {
      await appConnection.execute(
        `
        INSERT IGNORE INTO genres (name, icon)
        VALUES (?, ?)
      `,
        [genre.name, genre.icon]
      );
    }

    console.log("✅ Datos iniciales insertados correctamente\n");
    console.log("🚀 ¡Base de datos MovieFlix inicializada exitosamente!\n");

    console.log("📋 Información de la configuración:");
    console.log(`   • Base de datos: ${process.env.DB_NAME}`);
    console.log(`   • Usuario: ${process.env.DB_USER}`);
    console.log(`   • Host: ${process.env.DB_HOST}`);
    console.log(`   • Perfil inicial: Home (ID: ${homeProfileId})`);
    console.log("\n📝 Próximos pasos:");
    console.log(
      "   1. Ejecuta: node scripts/seed-data.js (para cargar contenido inicial)"
    );
    console.log("   2. Inicia el servidor: npm start");
    console.log("   3. Accede a: http://localhost:3001/api/health");
    console.log(
      "\n💡 Recuerda configurar las API keys en el archivo .env para autocompletar"
    );
  } catch (error) {
    console.error("❌ Error inicializando base de datos:", error.message);

    if (error.code === "ER_ACCESS_DENIED_ERROR") {
      console.error("\n🔧 Solución: Verifica las credenciales de MySQL");
      console.error("   - Asegúrate de que MySQL esté ejecutándose");
      console.error("   - Verifica el password de root en DB_ROOT_PASSWORD");
      console.error("   - Ejecuta: sudo mysql_secure_installation");
    } else if (error.code === "ECONNREFUSED") {
      console.error("\n🔧 Solución: MySQL no está ejecutándose");
      console.error("   - Ejecuta: sudo systemctl start mysql");
      console.error("   - Verifica: sudo systemctl status mysql");
    }

    process.exit(1);
  } finally {
    if (rootConnection) await rootConnection.end();
    if (appConnection) await appConnection.end();
  }
}

if (require.main === module) {
  initDatabase();
}

module.exports = initDatabase;
