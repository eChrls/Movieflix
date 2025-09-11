const mysql = require("mysql2/promise");
require("dotenv").config();

async function addSeasonsEpisodesFields() {
  console.log("🔄 Añadiendo campos seasons y episodes a tabla content...\n");

  let connection;

  try {
    // Conectar a la base de datos
    console.log("🔌 Conectando a la base de datos...");
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log("✅ Conexión establecida");

    // Verificar si las columnas ya existen
    console.log("🔍 Verificando estructura actual de la tabla...");
    const [columns] = await connection.execute(`
      SELECT COLUMN_NAME
      FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = '${process.env.DB_NAME}'
        AND TABLE_NAME = 'content'
        AND COLUMN_NAME IN ('seasons', 'episodes')
    `);

    const existingColumns = columns.map((row) => row.COLUMN_NAME);

    // Añadir columna seasons si no existe
    if (!existingColumns.includes("seasons")) {
      console.log("📺 Añadiendo columna 'seasons'...");
      await connection.execute(`
        ALTER TABLE content
        ADD COLUMN seasons INT NULL
        COMMENT 'Número de temporadas para series'
      `);
      console.log("✅ Columna 'seasons' añadida");
    } else {
      console.log("ℹ️  Columna 'seasons' ya existe");
    }

    // Añadir columna episodes si no existe
    if (!existingColumns.includes("episodes")) {
      console.log("📺 Añadiendo columna 'episodes'...");
      await connection.execute(`
        ALTER TABLE content
        ADD COLUMN episodes INT NULL
        COMMENT 'Número total de episodios para series'
      `);
      console.log("✅ Columna 'episodes' añadida");
    } else {
      console.log("ℹ️  Columna 'episodes' ya existe");
    }

    // Verificar la estructura final
    console.log("🔍 Verificando estructura final...");
    const [finalColumns] = await connection.execute(`
      SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_COMMENT
      FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = '${process.env.DB_NAME}'
        AND TABLE_NAME = 'content'
        AND COLUMN_NAME IN ('seasons', 'episodes', 'runtime', 'type')
      ORDER BY ORDINAL_POSITION
    `);

    console.log("\n📋 Campos relevantes en tabla content:");
    finalColumns.forEach((col) => {
      console.log(
        `   - ${col.COLUMN_NAME}: ${col.DATA_TYPE} ${
          col.IS_NULLABLE === "YES" ? "(NULL)" : "(NOT NULL)"
        } ${col.COLUMN_COMMENT ? `// ${col.COLUMN_COMMENT}` : ""}`
      );
    });

    console.log("\n✅ Migración completada exitosamente");
    console.log(
      "💡 Ahora las series pueden almacenar información de temporadas y episodios"
    );
  } catch (error) {
    console.error("❌ Error durante la migración:", error.message);
    throw error;
  } finally {
    if (connection) {
      await connection.end();
      console.log("🔌 Conexión cerrada");
    }
  }
}

// Ejecutar la migración si se llama directamente
if (require.main === module) {
  addSeasonsEpisodesFields()
    .then(() => {
      console.log("\n🎉 Proceso completado");
      process.exit(0);
    })
    .catch((error) => {
      console.error("\n💥 Error fatal:", error.message);
      process.exit(1);
    });
}

module.exports = { addSeasonsEpisodesFields };
