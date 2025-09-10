const mysql = require("mysql2/promise");
require("dotenv").config();

async function fixPosterUrls() {
  console.log("🔧 Corrigiendo URLs de pósters TMDb...\n");

  let connection;

  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log("✅ Conectado a la base de datos");

    // Buscar pósters con URLs incorrectas
    const [incorrectPosters] = await connection.execute(`
      SELECT id, title, poster_path, backdrop_path
      FROM content
      WHERE poster_path LIKE '%image.tmdb.org/t/medium%'
         OR poster_path LIKE '%image.tmdb.org/t/original%'
         OR backdrop_path LIKE '%image.tmdb.org/t/medium%'
         OR backdrop_path LIKE '%image.tmdb.org/t/original%'
    `);

    console.log(
      `📊 Elementos con URLs incorrectas: ${incorrectPosters.length}`
    );

    if (incorrectPosters.length === 0) {
      console.log("🎉 ¡Todas las URLs ya están correctas!");
      return;
    }

    console.log("\n🔄 Corrigiendo URLs...\n");

    let corrected = 0;

    for (const item of incorrectPosters) {
      let newPosterPath = item.poster_path;
      let newBackdropPath = item.backdrop_path;

      // Corregir poster_path
      if (item.poster_path) {
        newPosterPath = item.poster_path
          .replace(
            "https://image.tmdb.org/t/medium/w300",
            "https://image.tmdb.org/t/p/w300"
          )
          .replace(
            "https://image.tmdb.org/t/original/w1920",
            "https://image.tmdb.org/t/p/w500"
          );
      }

      // Corregir backdrop_path
      if (item.backdrop_path) {
        newBackdropPath = item.backdrop_path
          .replace(
            "https://image.tmdb.org/t/medium/w300",
            "https://image.tmdb.org/t/p/w300"
          )
          .replace(
            "https://image.tmdb.org/t/original/w1920",
            "https://image.tmdb.org/t/p/w1280"
          );
      }

      // Actualizar en base de datos
      await connection.execute(
        `UPDATE content SET poster_path = ?, backdrop_path = ? WHERE id = ?`,
        [newPosterPath, newBackdropPath, item.id]
      );

      console.log(`✅ ${item.title}`);
      console.log(`   Anterior: ${item.poster_path}`);
      console.log(`   Nueva:    ${newPosterPath}`);
      console.log("");

      corrected++;
    }

    console.log("=".repeat(50));
    console.log(`✅ URLs corregidas: ${corrected}`);
    console.log("🎬 Las portadas ahora deberían cargar correctamente");
    console.log("🔄 Recarga la página para ver los cambios");
  } catch (error) {
    console.error("❌ Error:", error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

if (require.main === module) {
  fixPosterUrls();
}

module.exports = fixPosterUrls;
