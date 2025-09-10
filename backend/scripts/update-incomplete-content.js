const mysql = require("mysql2/promise");
const axios = require("axios");
require("dotenv").config();

class ContentUpdater {
  constructor() {
    this.tmdbApiKey = process.env.TMDB_API_KEY;
    this.omdbApiKey = process.env.OMDB_API_KEY;
    this.connection = null;
    this.updated = 0;
    this.errors = 0;
    this.skipped = 0;
  }

  async init() {
    console.log("🔄 Inicializando actualizador de contenido MovieFlix...\n");
    
    this.connection = await mysql.createConnection({
      host: process.env.DB_HOST || "localhost",
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log("✅ Conectado a la base de datos");
    console.log(`🔑 TMDb API Key: ${this.tmdbApiKey ? "Configurado" : "No encontrado"}`);
    console.log(`🔑 OMDb API Key: ${this.omdbApiKey ? "Configurado" : "No encontrado"}\n`);
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
        
        // Obtener detalles completos
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
      console.log(`⚠️  Error buscando en TMDb: ${error.message}`);
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
      console.log(`⚠️  Error buscando en OMDb: ${error.message}`);
      return null;
    }
  }

  async updateContentItem(item) {
    console.log(`🔄 Actualizando: ${item.title} (${item.year})`);

    try {
      // Buscar en TMDb primero
      const tmdbData = await this.searchTMDb(item.title, item.year, item.type);
      
      if (!tmdbData) {
        console.log(`❌ No encontrado en TMDb: ${item.title}`);
        this.skipped++;
        return false;
      }

      // Buscar rating en OMDb si tenemos IMDB ID
      let omdbData = null;
      if (tmdbData.imdb_id) {
        omdbData = await this.searchOMDb(item.title, item.year, tmdbData.imdb_id);
      }

      // Preparar datos para actualizar
      const updateData = {
        title_en: tmdbData.title_en || item.title_en,
        overview: tmdbData.overview || item.overview,
        poster_path: tmdbData.poster_path || item.poster_path,
        backdrop_path: tmdbData.backdrop_path || item.backdrop_path,
        runtime: tmdbData.runtime || item.runtime,
        imdb_id: tmdbData.imdb_id || item.imdb_id,
        tmdb_id: tmdbData.tmdb_id || item.tmdb_id,
        rating: (omdbData?.imdb_rating || tmdbData.rating || item.rating),
        genres: tmdbData.genres.length > 0 ? JSON.stringify(tmdbData.genres) : item.genres
      };

      // Actualizar en base de datos
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
        updateData.title_en,
        updateData.overview,
        updateData.poster_path,
        updateData.backdrop_path,
        updateData.runtime,
        updateData.imdb_id,
        updateData.tmdb_id,
        updateData.rating,
        updateData.genres,
        item.id
      ]);

      console.log(`✅ Actualizado: ${item.title}`);
      console.log(`   - TMDb ID: ${updateData.tmdb_id}`);
      console.log(`   - IMDB ID: ${updateData.imdb_id}`);
      console.log(`   - Rating: ${updateData.rating}`);
      console.log(`   - Póster: ${updateData.poster_path ? "Sí" : "No"}`);
      console.log("");

      this.updated++;
      
      // Pequeña pausa para no saturar las APIs
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      return true;

    } catch (error) {
      console.error(`❌ Error actualizando ${item.title}:`, error.message);
      this.errors++;
      return false;
    }
  }

  async updateAllIncompleteContent() {
    try {
      // Obtener contenido incompleto
      const [incompleteContent] = await this.connection.execute(`
        SELECT 
          id, title, title_en, year, type, rating, runtime, overview,
          poster_path, backdrop_path, imdb_id, tmdb_id, platform_id
        FROM content 
        WHERE 
          (poster_path IS NULL OR poster_path = '') OR
          (overview IS NULL OR overview = '') OR
          (rating IS NULL OR rating = 0) OR
          (runtime IS NULL OR runtime = 0) OR
          (imdb_id IS NULL OR imdb_id = '') OR
          (tmdb_id IS NULL OR tmdb_id = 0)
        ORDER BY year DESC, title ASC
      `);

      console.log(`📊 Contenido para actualizar: ${incompleteContent.length} elementos\n`);

      if (incompleteContent.length === 0) {
        console.log("🎉 ¡Todo el contenido ya está actualizado!");
        return;
      }

      // Procesar cada elemento
      for (let i = 0; i < incompleteContent.length; i++) {
        const item = incompleteContent[i];
        console.log(`[${i + 1}/${incompleteContent.length}] Procesando...`);
        await this.updateContentItem(item);
      }

      // Resumen final
      console.log("\n" + "=".repeat(50));
      console.log("📊 RESUMEN DE ACTUALIZACIÓN");
      console.log("=".repeat(50));
      console.log(`✅ Actualizados exitosamente: ${this.updated}`);
      console.log(`⏭️  Omitidos (no encontrados): ${this.skipped}`);
      console.log(`❌ Errores: ${this.errors}`);
      console.log(`📊 Total procesados: ${this.updated + this.skipped + this.errors}`);
      console.log("");

      if (this.updated > 0) {
        console.log("🎉 ¡Actualización completada! El contenido ahora debería mostrar:");
        console.log("   - Pósters y fondos");
        console.log("   - Ratings de IMDB/TMDb");
        console.log("   - Resúmenes completos");
        console.log("   - Enlaces a IMDB");
        console.log("   - Duración de películas/episodios");
      }

    } catch (error) {
      console.error("❌ Error en actualización masiva:", error.message);
    }
  }

  async close() {
    if (this.connection) {
      await this.connection.end();
    }
  }
}

async function updateIncompleteContent() {
  const updater = new ContentUpdater();
  
  try {
    await updater.init();
    await updater.updateAllIncompleteContent();
  } catch (error) {
    console.error("❌ Error fatal:", error.message);
  } finally {
    await updater.close();
  }
}

// Ejecutar si se llama directamente
if (require.main === module) {
  updateIncompleteContent();
}

module.exports = updateIncompleteContent;
