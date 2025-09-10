const mysql = require("mysql2/promise");
require("dotenv").config();

async function seedData() {
  console.log("🌱 Insertando contenido inicial de MovieFlix...\n");

  let connection;

  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    // Obtener IDs necesarios
    const [profiles] = await connection.execute(
      'SELECT id FROM profiles WHERE name = "Home"'
    );
    const homeProfileId = profiles[0].id;

    const [platforms] = await connection.execute(
      "SELECT id, name FROM platforms"
    );
    const platformMap = {};
    platforms.forEach((p) => {
      platformMap[p.name] = p.id;
    });

    console.log("🏠 Insertando contenido inicial para el perfil Home...");

    // Contenido inicial basado en tus datos
    const initialContent = [
      // Series
      {
        title: "Band of Brothers",
        year: 2001,
        type: "series",
        rating: 9.4,
        genres: ["War", "Drama", "History"],
        platform: "HBO",
      },
      {
        title: "Death Note",
        year: 2006,
        type: "series",
        rating: 8.9,
        genres: ["Animation", "Mystery", "Drama"],
        platform: null,
      },
      {
        title: "The Pitt",
        year: 2025,
        type: "series",
        rating: 8.9,
        genres: ["Drama"],
        platform: "HBO",
      },
      {
        title: "When They See Us",
        year: 2019,
        type: "series",
        rating: 8.8,
        genres: ["Crime", "Drama"],
        platform: "Netflix",
      },
      {
        title: "Dark",
        year: 2017,
        type: "series",
        rating: 8.7,
        genres: ["Sci-Fi", "Thriller"],
        platform: "Netflix",
      },
      {
        title: "Peaky Blinders",
        year: 2013,
        type: "series",
        rating: 8.7,
        genres: ["Crime", "Drama", "Thriller"],
        platform: "Netflix",
      },
      {
        title: "La Maravillosa Sra. Maisel",
        year: 2017,
        type: "series",
        rating: 8.7,
        genres: ["Comedy", "Drama"],
        platform: "Prime Video",
      },
      {
        title: "This Is Us",
        year: 2016,
        type: "series",
        rating: 8.7,
        genres: ["Drama", "Romance"],
        platform: "Prime Video",
      },
      {
        title: "Atlanta",
        year: 2016,
        type: "series",
        rating: 8.6,
        genres: ["Comedy", "Drama"],
        platform: null,
      },
      {
        title: "Dopesick",
        year: 2021,
        type: "series",
        rating: 8.6,
        genres: ["Drama", "Crime"],
        platform: "Disney+",
      },
      {
        title: "Bron/Broen - The Bridge",
        year: 2011,
        type: "series",
        rating: 8.6,
        genres: ["Crime", "Drama"],
        platform: null,
      },
      {
        title: "The Expanse",
        year: 2015,
        type: "series",
        rating: 8.5,
        genres: ["Sci-Fi", "Drama"],
        platform: "Prime Video",
      },
      {
        title: "Treme",
        year: 2010,
        type: "series",
        rating: 8.5,
        genres: ["Drama", "Music"],
        platform: null,
      },
      {
        title: "Ozark",
        year: 2017,
        type: "series",
        rating: 8.4,
        genres: ["Crime", "Drama"],
        platform: "Netflix",
      },
      {
        title: "Billions",
        year: 2016,
        type: "series",
        rating: 8.4,
        genres: ["Drama", "Crime"],
        platform: "Prime Video",
      },
      {
        title: "High Maintenance",
        year: 2016,
        type: "series",
        rating: 8.1,
        genres: ["Comedy", "Drama"],
        platform: "HBO",
      },
      {
        title: "Wild Wild Country",
        year: 2018,
        type: "series",
        rating: 8.1,
        genres: ["Documentary"],
        platform: "Netflix",
      },
      {
        title: "Tokyo Vice",
        year: 2022,
        type: "series",
        rating: 8.1,
        genres: ["Crime", "Drama", "Thriller"],
        platform: "HBO",
      },
      {
        title: "The Morning Show",
        year: 2019,
        type: "series",
        rating: 8.1,
        genres: ["Drama", "Workplace Drama"],
        platform: "Apple TV+",
      },
      {
        title: "Show Me a Hero",
        year: 2015,
        type: "series",
        rating: 7.9,
        genres: ["Drama", "Political Drama"],
        platform: "HBO",
      },
      {
        title: "ZeroZeroZero",
        year: 2019,
        type: "series",
        rating: 7.8,
        genres: ["Crime", "Drama"],
        platform: "Prime Video",
      },
      {
        title: "Undone",
        year: 2019,
        type: "series",
        rating: 7.8,
        genres: ["Animation", "Drama", "Fantasy"],
        platform: "Prime Video",
      },
      {
        title: "Crashing",
        year: 2017,
        type: "series",
        rating: 7.6,
        genres: ["Comedy"],
        platform: "HBO",
      },
      {
        title: "Somebody Somewhere",
        year: 2022,
        type: "series",
        rating: 7.6,
        genres: ["Comedy", "Drama"],
        platform: "HBO",
      },
      {
        title: "Staircase",
        year: 2022,
        type: "series",
        rating: 7.6,
        genres: ["Crime", "Drama"],
        platform: "HBO",
      },
      {
        title: "Slow Horses",
        year: 2022,
        type: "series",
        rating: 7.5,
        genres: ["Drama", "Spy"],
        platform: "Apple TV+",
      },
      {
        title: "La Ciudad es Nuestra",
        year: 2025,
        type: "series",
        rating: 7.2,
        genres: ["Crime", "Documentary"],
        platform: "Netflix",
      },
      {
        title: "CAEM",
        year: 2024,
        type: "series",
        rating: 6.9,
        genres: ["Documentary", "Action"],
        platform: "Netflix",
      },
      {
        title: "Las Gotas de Dios",
        year: 2023,
        type: "series",
        rating: 6.8,
        genres: ["Drama", "Mystery"],
        platform: "Prime Video",
      },
      {
        title: "Tierra de Mafiosos",
        year: 2024,
        type: "series",
        rating: 6.4,
        genres: ["Crime", "Thriller"],
        platform: "Movistar+",
      },

      // Westerns - Series
      {
        title: "Yellowstone",
        year: 2018,
        type: "series",
        rating: 8.7,
        genres: ["Drama", "Western"],
        platform: "Paramount+",
      },
      {
        title: "1883",
        year: 2021,
        type: "series",
        rating: 8.0,
        genres: ["Drama", "Western"],
        platform: "Paramount+",
      },

      // Películas - Westerns
      {
        title: "El Hombre que Mató a Liberty Valance",
        year: 1962,
        type: "movie",
        rating: 8.1,
        genres: ["Western", "Drama"],
        platform: "Disney+",
      },
      {
        title: "Río Bravo",
        year: 1959,
        type: "movie",
        rating: 8.0,
        genres: ["Western"],
        platform: "Paramount+",
      },
      {
        title: "Centauros del Desierto",
        year: 1956,
        type: "movie",
        rating: 8.0,
        genres: ["Western"],
        platform: "Criterion Channel",
      },
      {
        title: "Solo Ante el Peligro",
        year: 1952,
        type: "movie",
        rating: 7.5,
        genres: ["Western"],
        platform: "Criterion Channel",
      },

      // Anime
      {
        title: "Perfect Blue",
        year: 1997,
        type: "movie",
        rating: 8.0,
        genres: ["Animation", "Thriller"],
        platform: null,
      },
      {
        title: "Castle in the Sky",
        year: 1986,
        type: "movie",
        rating: 8.0,
        genres: ["Animation", "Adventure", "Family"],
        platform: null,
      },
      {
        title: "The Tale of the Princess Kaguya",
        year: 2013,
        type: "movie",
        rating: 8.0,
        genres: ["Animation", "Drama", "Fantasy"],
        platform: null,
      },
      {
        title: "Porco Rosso",
        year: 1992,
        type: "movie",
        rating: 7.7,
        genres: ["Animation", "Adventure", "Comedy"],
        platform: null,
      },

      // Películas - Acción
      {
        title: "First Blood",
        year: 1982,
        type: "movie",
        rating: 7.7,
        genres: ["Action"],
        platform: "Prime Video",
      },
      {
        title: "Dredd",
        year: 2012,
        type: "movie",
        rating: 7.1,
        genres: ["Action", "Sci-Fi"],
        platform: "Prime Video",
      },
      {
        title: "Chacal",
        year: 1997,
        type: "movie",
        rating: 6.0,
        genres: ["Action", "Thriller"],
        platform: "Prime Video",
      },
      {
        title: "Monkey Man",
        year: 2024,
        type: "movie",
        rating: 5.8,
        genres: ["Action", "Thriller"],
        platform: "Prime Video",
      },

      // Películas - Animación
      {
        title: "Akira",
        year: 1988,
        type: "movie",
        rating: 8.1,
        genres: ["Animation", "Sci-Fi", "Action"],
        platform: "Netflix",
      },

      // Películas - Ciencia Ficción
      {
        title: "2001: A Space Odyssey",
        year: 1968,
        type: "movie",
        rating: 8.3,
        genres: ["Sci-Fi", "Adventure"],
        platform: null,
      },
      {
        title: "Coherence",
        year: 2013,
        type: "movie",
        rating: 7.2,
        genres: ["Sci-Fi", "Thriller"],
        platform: null,
      },

      // Películas - Drama
      {
        title: "Doctor Zhivago",
        year: 1965,
        type: "movie",
        rating: 8.0,
        genres: ["Romance", "Drama", "War"],
        platform: "HBO",
      },
      {
        title: "Trece Vidas",
        year: 2022,
        type: "movie",
        rating: 7.8,
        genres: ["Biography", "Drama", "Thriller"],
        platform: "Prime Video",
      },
      {
        title: "La Cinta Blanca",
        year: 2009,
        type: "movie",
        rating: 7.8,
        genres: ["Drama", "Mystery"],
        platform: "Criterion Channel",
      },
      {
        title: "The Florida Project",
        year: 2017,
        type: "movie",
        rating: 7.6,
        genres: ["Drama"],
        platform: "Netflix",
      },
      {
        title: "Contratiempo",
        year: 2016,
        type: "movie",
        rating: 7.6,
        genres: ["Thriller", "Crime", "Drama"],
        platform: "Netflix",
      },
      {
        title: "Cría Cuervos",
        year: 1976,
        type: "movie",
        rating: 7.6,
        genres: ["Drama"],
        platform: "Filmin",
      },
      {
        title: "Cure",
        year: 1997,
        type: "movie",
        rating: 7.4,
        genres: ["Mystery", "Thriller"],
        platform: null,
      },
      {
        title: "Que Dios Nos Perdone",
        year: 2016,
        type: "movie",
        rating: 7.3,
        genres: ["Crime", "Drama", "Thriller"],
        platform: "Netflix",
      },
      {
        title: "Malas Calles",
        year: 1973,
        type: "movie",
        rating: 7.2,
        genres: ["Crime", "Drama"],
        platform: "Prime Video",
      },
      {
        title: "Tetris",
        year: 2023,
        type: "movie",
        rating: 7.0,
        genres: ["Drama"],
        platform: "Apple TV+",
      },
      {
        title: "El Jockey",
        year: 2021,
        type: "movie",
        rating: 6.3,
        genres: ["Drama"],
        platform: "Prime Video",
      },
      {
        title: "Hermanas Hasta la Muerte",
        year: 2022,
        type: "movie",
        rating: 6.3,
        genres: ["Drama", "Thriller"],
        platform: "Filmin",
      },
      {
        title: "The Rule of Jenny Penn",
        year: 2024,
        type: "movie",
        rating: 6.2,
        genres: ["Horror", "Mystery", "Thriller"],
        platform: "Apple TV+",
      },
      {
        title: "El Extraño",
        year: 2013,
        type: "movie",
        rating: 5.9,
        genres: ["Mystery", "Thriller"],
        platform: "Prime Video",
      },

      // Películas - Terror
      {
        title: "Häxan: Witchcraft Through the Ages",
        year: 1922,
        type: "movie",
        rating: 7.6,
        genres: ["Horror", "Documentary"],
        platform: null,
      },
      {
        title: "High Tension",
        year: 2003,
        type: "movie",
        rating: 6.7,
        genres: ["Horror", "Thriller"],
        platform: null,
      },
      {
        title: "El Baño del Diablo",
        year: 2024,
        type: "movie",
        rating: 6.6,
        genres: ["Horror", "Thriller"],
        platform: "Filmin",
      },
      {
        title: "Speak No Evil",
        year: 2022,
        type: "movie",
        rating: 6.6,
        genres: ["Horror", "Thriller"],
        platform: null,
      },
      {
        title: "La Hora del Diablo",
        year: 2021,
        type: "movie",
        rating: 6.0,
        genres: ["Horror", "Thriller"],
        platform: "Shudder",
      },
      {
        title: "La Casa",
        year: 2024,
        type: "movie",
        rating: 4.9,
        genres: ["Horror", "Mystery"],
        platform: "Netflix",
      },

      // Comedia
      {
        title: "Snack Shack",
        year: 2019,
        type: "movie",
        rating: 5.5,
        genres: ["Comedy", "Family"],
        platform: "Netflix",
      },
    ];

    console.log(
      `📊 Insertando ${initialContent.length} elementos de contenido...`
    );

    let insertedCount = 0;
    for (const item of initialContent) {
      try {
        const platformId = item.platform ? platformMap[item.platform] : null;

        await connection.execute(
          `
          INSERT INTO content (title, year, type, rating, genres, platform_id, profile_id, status)
          VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')
        `,
          [
            item.title,
            item.year,
            item.type,
            item.rating,
            JSON.stringify(item.genres),
            platformId,
            homeProfileId,
          ]
        );

        insertedCount++;
      } catch (error) {
        console.log(`⚠️  Error insertando "${item.title}": ${error.message}`);
      }
    }

    console.log(`✅ ${insertedCount} elementos insertados correctamente\n`);

    // Mostrar estadísticas
    const [stats] = await connection.execute(
      `
      SELECT
        type,
        COUNT(*) as count,
        AVG(rating) as avg_rating,
        MAX(rating) as max_rating
      FROM content
      WHERE profile_id = ? AND status = 'pending'
      GROUP BY type
    `,
      [homeProfileId]
    );

    console.log("📊 Estadísticas del contenido inicial:");
    stats.forEach((stat) => {
      console.log(
        `   • ${stat.type === "movie" ? "Películas" : "Series"}: ${
          stat.count
        } elementos`
      );
      console.log(
        `     - Calificación promedio: ${
          stat.avg_rating ? stat.avg_rating.toFixed(1) : "N/A"
        }`
      );
      console.log(`     - Calificación máxima: ${stat.max_rating || "N/A"}`);
    });

    console.log("\n🏆 Top 3 series por calificación:");
    const [topSeries] = await connection.execute(
      `
      SELECT title, year, rating
      FROM content
      WHERE profile_id = ? AND type = 'series' AND rating > 0 AND status = 'pending'
      ORDER BY rating DESC
      LIMIT 3
    `,
      [homeProfileId]
    );

    topSeries.forEach((series, index) => {
      console.log(
        `   ${index + 1}. ${series.title} (${series.year}) - ${series.rating}`
      );
    });

    console.log("\n🏆 Top 3 películas por calificación:");
    const [topMovies] = await connection.execute(
      `
      SELECT title, year, rating
      FROM content
      WHERE profile_id = ? AND type = 'movie' AND rating > 0 AND status = 'pending'
      ORDER BY rating DESC
      LIMIT 3
    `,
      [homeProfileId]
    );

    topMovies.forEach((movie, index) => {
      console.log(
        `   ${index + 1}. ${movie.title} (${movie.year}) - ${movie.rating}`
      );
    });

    console.log("\n🚀 ¡Datos iniciales cargados exitosamente!");
    console.log("\n📝 Próximos pasos:");
    console.log("   1. Inicia el backend: npm start");
    console.log("   2. Inicia el frontend: cd ../frontend && npm start");
    console.log("   3. Accede a: http://localhost:3000");
    console.log(
      "\n💡 Tip: Configura las API keys en .env para autocompletar datos de nuevas películas"
    );
  } catch (error) {
    console.error("❌ Error insertando datos iniciales:", error.message);
    process.exit(1);
  } finally {
    if (connection) await connection.end();
  }
}

if (require.main === module) {
  seedData();
}

module.exports = seedData;
