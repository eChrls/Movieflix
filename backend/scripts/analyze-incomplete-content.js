const mysql = require("mysql2/promise");
require("dotenv").config();

async function analyzeIncompleteContent() {
  console.log("🔍 Analizando contenido incompleto en MovieFlix...\n");

  let connection;

  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log("✅ Conectado a la base de datos");

    // Buscar contenido que necesita actualización
    const [incompleteContent] = await connection.execute(`
      SELECT
        id,
        title,
        title_en,
        year,
        type,
        rating,
        runtime,
        overview,
        poster_path,
        backdrop_path,
        imdb_id,
        tmdb_id,
        platform_id
      FROM content
      WHERE
        (poster_path IS NULL OR poster_path = '') OR
        (overview IS NULL OR overview = '') OR
        (rating IS NULL OR rating = 0) OR
        (runtime IS NULL OR runtime = 0) OR
        (imdb_id IS NULL OR imdb_id = '') OR
        (tmdb_id IS NULL OR tmdb_id = 0)
      ORDER BY title ASC
    `);

    console.log(
      `📊 Total de contenido que necesita actualización: ${incompleteContent.length}\n`
    );

    if (incompleteContent.length === 0) {
      console.log("🎉 ¡Todo el contenido ya está completo!");
      return;
    }

    // Categorizar por tipo de datos faltantes
    const missingData = {
      poster: [],
      overview: [],
      rating: [],
      runtime: [],
      imdb_id: [],
      tmdb_id: [],
    };

    incompleteContent.forEach((item) => {
      if (!item.poster_path) missingData.poster.push(item.title);
      if (!item.overview) missingData.overview.push(item.title);
      if (!item.rating || item.rating === 0)
        missingData.rating.push(item.title);
      if (!item.runtime || item.runtime === 0)
        missingData.runtime.push(item.title);
      if (!item.imdb_id) missingData.imdb_id.push(item.title);
      if (!item.tmdb_id || item.tmdb_id === 0)
        missingData.tmdb_id.push(item.title);
    });

    console.log("📋 Análisis detallado:");
    console.log(`🖼️  Sin póster: ${missingData.poster.length} elementos`);
    console.log(`📝 Sin resumen: ${missingData.overview.length} elementos`);
    console.log(`⭐ Sin rating: ${missingData.rating.length} elementos`);
    console.log(`⏱️  Sin duración: ${missingData.runtime.length} elementos`);
    console.log(`🎬 Sin IMDB ID: ${missingData.imdb_id.length} elementos`);
    console.log(`📺 Sin TMDb ID: ${missingData.tmdb_id.length} elementos\n`);

    // Mostrar algunos ejemplos
    console.log("📋 Primeros 10 elementos que necesitan actualización:");
    incompleteContent.slice(0, 10).forEach((item, index) => {
      const missing = [];
      if (!item.poster_path) missing.push("póster");
      if (!item.overview) missing.push("resumen");
      if (!item.rating || item.rating === 0) missing.push("rating");
      if (!item.runtime || item.runtime === 0) missing.push("duración");
      if (!item.imdb_id) missing.push("IMDB ID");
      if (!item.tmdb_id || item.tmdb_id === 0) missing.push("TMDb ID");

      console.log(
        `${index + 1}. ${item.title} (${item.year}) - Falta: ${missing.join(
          ", "
        )}`
      );
    });

    console.log(
      "\n🔧 Próximo paso: Ejecutar script de actualización automática"
    );
  } catch (error) {
    console.error("❌ Error:", error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

if (require.main === module) {
  analyzeIncompleteContent();
}

module.exports = analyzeIncompleteContent;
