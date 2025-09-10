const mysql = require("mysql2/promise");
require("dotenv").config();

async function checkPosterPaths() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  const [rows] = await connection.execute(
    'SELECT id, title, poster_path FROM content WHERE poster_path IS NOT NULL AND poster_path != "" LIMIT 5'
  );

  console.log("🔍 Primeros 5 elementos con poster_path:");
  console.log("");
  rows.forEach((row) => {
    console.log(`ID ${row.id}: ${row.title}`);
    console.log(`Poster: ${row.poster_path}`);
    console.log("---");
  });

  await connection.end();
}

checkPosterPaths().catch(console.error);
