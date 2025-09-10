const mysql = require("mysql2/promise");
const axios = require("axios");
require("dotenv").config();

class SingleContentUpdater {
  constructor() {
    this.tmdbApiKey = process.env.TMDB_API_KEY;
    this.omdbApiKey = process.env.OMDB_API_KEY;
    this.connection = null;
  }

  async init() {
    this.connection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });
  }

  async searchAndUpdateContent(contentId) {
    try {
      // Obtener información del contenido
      const [rows] = await this.connection.execute(
        "SELECT * FROM content WHERE id = ?",
        [contentId]
      );

      if (rows.length === 0) {
        console.log(`❌ No se encontró contenido con ID: ${contentId}`);
        return false;
      }

      const item = rows[0];
      console.log(`🔄 Actualizando: ${item.title} (${item.year})`);

      // Buscar en TMDb
      const tmdbData = await this.searchTMDb(item.title, item.year, item.type);
      
      if (!tmdbData) {
        console.log(`❌ No encontrado en TMDb: ${item.title}`);
        return false;
      }

      // Buscar en OMDb si tenemos IMDB ID
      let omdbData = null;
      if (tmdbData.imdb_id) {
        omdbData = await this.searchOMDb(item.title, item.year, tmdbData.imdb_id);
      }

      // Actualizar base de datos
      await this.connection.execute(`
        UPDATE content SET
          title_en = ?,
          overview = ?,
          poster_path = ?,
          backdrop_path = ?,
          runtime = ?,
          imdb_id = ?,
          tmdb_id = ?,
          rating = ?,
          genres = ?,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [
        tmdbData.title_en || item.title_en,
        tmdbData.overview || item.overview,
        tmdbData.poster_path || item.poster_path,
        tmdbData.backdrop_path || item.backdrop_path,
        tmdbData.runtime || item.runtime,
        tmdbData.imdb_id || item.imdb_id,
        tmdbData.tmdb_id || item.tmdb_id,
        (omdbData?.imdb_rating || tmdbData.rating || item.rating),
        tmdbData.genres.length > 0 ? JSON.stringify(tmdbData.genres) : item.genres,
        contentId
      ]);

      console.log(`✅ Actualizado exitosamente!`);
      console.log(`   TMDb ID: ${tmdbData.tmdb_id}`);
      console.log(`   IMDB ID: ${tmdbData.imdb_id}`);
      console.log(`   Rating: ${omdbData?.imdb_rating || tmdbData.rating}`);
      console.log(`   Póster: ${tmdbData.poster_path ? "Sí" : "No"}`);

      return true;

    } catch (error) {
      console.error(`❌ Error:`, error.message);
      return false;
    }
  }

  async searchTMDb(title, year, type) {
    try {
      const endpoint = type === "movie" ? "movie" : "tv";
      const searchUrl = `https://api.themoviedb.org/3/search/${endpoint}`;
      
      const response = await axios.get(searchUrl, {
        params: {
          api_key: this.tmdbApiKey,
          query: title,
          year: type === "movie" ? year : undefined,
          first_air_date_year: type === "series" ? year : undefined,
          language: "es-ES"
        },
        timeout: 10000
      });

      if (response.data.results && response.data.results.length > 0) {
        const result = response.data.results[0];
        
        const detailsUrl = `https://api.themoviedb.org/3/${endpoint}/${result.id}`;
        const detailsResponse = await axios.get(detailsUrl, {
          params: {
            api_key: this.tmdbApiKey,
            language: "es-ES",
            append_to_response: "external_ids"
          },
          timeout: 10000
        });

        const details = detailsResponse.data;
        
        return {
          tmdb_id: details.id,
          title_en: type === "movie" ? details.original_title : details.original_name,
          overview: details.overview || "",
          poster_path: details.poster_path ? `https://image.tmdb.org/t/medium/w300${details.poster_path}` : null,
          backdrop_path: details.backdrop_path ? `https://image.tmdb.org/t/original/w1920${details.backdrop_path}` : null,
          runtime: type === "movie" ? details.runtime : (details.episode_run_time?.[0] || null),
          imdb_id: details.external_ids?.imdb_id || null,
          rating: details.vote_average || null,
          genres: details.genres ? details.genres.map(g => g.name) : []
        };
      }
      
      return null;
    } catch (error) {
      console.log(`⚠️  Error TMDb: ${error.message}`);
      return null;
    }
  }

  async searchOMDb(title, year, imdbId = null) {
    try {
      const params = {
        apikey: this.omdbApiKey,
        type: "movie"
      };

      if (imdbId) {
        params.i = imdbId;
      } else {
        params.t = title;
        if (year) params.y = year;
      }

      const response = await axios.get("http://www.omdbapi.com/", {
        params,
        timeout: 10000
      });

      if (response.data && response.data.Response === "True") {
        return {
          imdb_rating: parseFloat(response.data.imdbRating) || null,
          imdb_id: response.data.imdbID || null,
          runtime: response.data.Runtime ? parseInt(response.data.Runtime.replace(/\D/g, "")) : null,
          title_en: response.data.Title || null
        };
      }
      
      return null;
    } catch (error) {
      console.log(`⚠️  Error OMDb: ${error.message}`);
      return null;
    }
  }

  async showIncompleteContent() {
    const [content] = await this.connection.execute(`
      SELECT id, title, year, type, rating, poster_path, imdb_id
      FROM content 
      WHERE 
        (poster_path IS NULL OR poster_path = '') OR
        (rating IS NULL OR rating = 0) OR
        (imdb_id IS NULL OR imdb_id = '')
      ORDER BY title ASC
      LIMIT 20
    `);

    console.log("\n📋 Primeros 20 elementos que necesitan actualización:\n");
    content.forEach((item, index) => {
      const missing = [];
      if (!item.poster_path) missing.push("póster");
      if (!item.rating || item.rating === 0) missing.push("rating");
      if (!item.imdb_id) missing.push("IMDB");
      
      console.log(`${item.id.toString().padStart(3)}: ${item.title} (${item.year}) - Falta: ${missing.join(", ")}`);
    });
    console.log("");
  }

  async close() {
    if (this.connection) {
      await this.connection.end();
    }
  }
}

async function updateSingleContent() {
  const updater = new SingleContentUpdater();
  
  try {
    await updater.init();
    
    // Obtener ID desde argumentos de línea de comandos
    const contentId = process.argv[2];
    
    if (!contentId) {
      console.log("🔍 MovieFlix - Actualizador Individual de Contenido\n");
      console.log("Uso: node scripts/update-single-content.js <ID>");
      console.log("Ejemplo: node scripts/update-single-content.js 15\n");
      
      await updater.showIncompleteContent();
      console.log("💡 Copia el ID del elemento que quieres actualizar y ejecútalo así:");
      console.log("   node scripts/update-single-content.js <ID>");
      return;
    }

    console.log(`🎯 Actualizando contenido con ID: ${contentId}\n`);
    const success = await updater.searchAndUpdateContent(parseInt(contentId));
    
    if (success) {
      console.log("\n🎉 ¡Actualización completada! Verifica en la web.");
    } else {
      console.log("\n❌ No se pudo actualizar el contenido.");
    }

  } catch (error) {
    console.error("❌ Error:", error.message);
  } finally {
    await updater.close();
  }
}

if (require.main === module) {
  updateSingleContent();
}

module.exports = updateSingleContent;
