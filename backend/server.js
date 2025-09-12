const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
const axios = require("axios");
const helmet = require("helmet");
const compression = require("compression");
const rateLimit = require("express-rate-limit");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3001;

// Trust proxy configuration for Nginx reverse proxy
app.set("trust proxy", true);

// Security middleware
app.use(
  helmet({
    crossOriginEmbedderPolicy: false,
    contentSecurityPolicy: false,
  })
);
app.use(compression());

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: "Demasiadas peticiones desde esta IP, intenta de nuevo más tarde.",
  standardHeaders: true,
  legacyHeaders: false,
});
app.use("/api/", limiter);

// CORS configuration
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "http://localhost:3000",
    credentials: true,
  })
);

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Database connection pool - Configuración corregida para MySQL2
const dbPool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root", // Cambiar a root temporalmente
  password: process.env.DB_PASSWORD || "$@msunG--2025", // Usar credencial del Orange Pi
  database: process.env.DB_NAME || "movieflix_db",
  port: process.env.DB_PORT || 3306,
  connectionLimit: 10,
  queueLimit: 0,
  // Removidas configuraciones obsoletas para MySQL2
  charset: "utf8mb4",
});

// Test database connection
async function testConnection() {
  try {
    const connection = await dbPool.getConnection();
    console.log("✅ Conexión a la base de datos establecida correctamente");
    connection.release();
  } catch (error) {
    console.error("❌ Error conectando a la base de datos:", error.message);
    console.error(
      "🔧 Asegúrate de que MySQL esté ejecutándose y las credenciales sean correctas"
    );
  }
}

// API Routes

// Get all profiles
app.get("/api/profiles", async (req, res) => {
  try {
    const [rows] = await dbPool.execute(
      "SELECT * FROM profiles ORDER BY created_at ASC"
    );
    res.json(rows);
  } catch (error) {
    console.error("Error fetching profiles:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Create new profile
app.post("/api/profiles", async (req, res) => {
  try {
    const { name, emoji } = req.body;

    if (!name || name.trim().length === 0) {
      return res
        .status(400)
        .json({ error: "El nombre del perfil es obligatorio" });
    }

    const [result] = await dbPool.execute(
      "INSERT INTO profiles (name, emoji) VALUES (?, ?)",
      [name.trim(), emoji || "🎬"]
    );

    const [newProfile] = await dbPool.execute(
      "SELECT * FROM profiles WHERE id = ?",
      [result.insertId]
    );

    res.status(201).json(newProfile[0]);
  } catch (error) {
    console.error("Error creating profile:", error);
    if (error.code === "ER_DUP_ENTRY") {
      res.status(400).json({ error: "Ya existe un perfil con ese nombre" });
    } else {
      res.status(500).json({ error: "Error interno del servidor" });
    }
  }
});

// Get all platforms
app.get("/api/platforms", async (req, res) => {
  try {
    const [rows] = await dbPool.execute(
      "SELECT * FROM platforms ORDER BY name ASC"
    );
    res.json(rows);
  } catch (error) {
    console.error("Error fetching platforms:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Get all genres
app.get("/api/genres", async (req, res) => {
  try {
    const [rows] = await dbPool.execute(
      "SELECT * FROM genres ORDER BY name ASC"
    );
    res.json(rows);
  } catch (error) {
    console.error("Error fetching genres:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Get content for a profile
app.get("/api/content/:profileId", async (req, res) => {
  try {
    const { profileId } = req.params;
    const { status = "pending", type, platform, genre, search } = req.query;

    let query = `
      SELECT c.*, p.name as platform_name, p.color as platform_color, p.icon as platform_icon
      FROM content c
      LEFT JOIN platforms p ON c.platform_id = p.id
      WHERE c.profile_id = ? AND c.status = ?
    `;
    const params = [profileId, status];

    if (type) {
      query += " AND c.type = ?";
      params.push(type);
    }

    if (platform) {
      query += " AND c.platform_id = ?";
      params.push(platform);
    }

    if (genre) {
      query += " AND JSON_CONTAINS(c.genres, JSON_QUOTE(?))";
      params.push(genre);
    }

    if (search) {
      query += " AND (c.title LIKE ? OR c.title_en LIKE ?)";
      params.push(`%${search}%`, `%${search}%`);
    }

    // Order by rating desc, then by title
    query += " ORDER BY c.rating DESC, c.title ASC";

    const [rows] = await dbPool.execute(query, params);
    res.json(rows);
  } catch (error) {
    console.error("Error fetching content:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Get top content for a profile
app.get("/api/content/:profileId/top", async (req, res) => {
  try {
    const { profileId } = req.params;

    const [movies] = await dbPool.execute(
      `
      SELECT c.*, p.name as platform_name, p.color as platform_color, p.icon as platform_icon
      FROM content c
      LEFT JOIN platforms p ON c.platform_id = p.id
      WHERE c.profile_id = ? AND c.status = 'pending' AND c.type = 'movie' AND c.rating > 0
      ORDER BY c.rating DESC
      LIMIT 3
    `,
      [profileId]
    );

    const [series] = await dbPool.execute(
      `
      SELECT c.*, p.name as platform_name, p.color as platform_color, p.icon as platform_icon
      FROM content c
      LEFT JOIN platforms p ON c.platform_id = p.id
      WHERE c.profile_id = ? AND c.status = 'pending' AND c.type = 'series' AND c.rating > 0
      ORDER BY c.rating DESC
      LIMIT 3
    `,
      [profileId]
    );

    res.json({ movies, series });
  } catch (error) {
    console.error("Error fetching top content:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Add new content
app.post("/api/content", async (req, res) => {
  try {
    const {
      title,
      title_en,
      year,
      type,
      rating,
      runtime,
      seasons,
      episodes,
      genres,
      overview,
      poster_path,
      backdrop_path,
      imdb_id,
      tmdb_id,
      platform_id,
      profile_id,
    } = req.body;

    if (!title || !type || !profile_id) {
      return res
        .status(400)
        .json({ error: "Título, tipo y perfil son obligatorios" });
    }

    const [result] = await dbPool.execute(
      `
      INSERT INTO content (
        title, title_en, year, type, rating, runtime, seasons, episodes, genres, overview,
        poster_path, backdrop_path, imdb_id, tmdb_id, platform_id, profile_id, status
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')
    `,
      [
        title,
        title_en || null,
        year || null,
        type,
        rating || null,
        runtime || null,
        seasons || null,
        episodes || null,
        JSON.stringify(genres || []),
        overview || null,
        poster_path || null,
        backdrop_path || null,
        imdb_id || null,
        tmdb_id || null,
        platform_id || null,
        profile_id,
      ]
    );

    const [newContent] = await dbPool.execute(
      `
      SELECT c.*, p.name as platform_name, p.color as platform_color, p.icon as platform_icon
      FROM content c
      LEFT JOIN platforms p ON c.platform_id = p.id
      WHERE c.id = ?
    `,
      [result.insertId]
    );

    res.status(201).json(newContent[0]);
  } catch (error) {
    console.error("Error adding content:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Update content
app.put("/api/content/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const {
      title,
      title_en,
      year,
      type,
      rating,
      runtime,
      seasons,
      episodes,
      genres,
      overview,
      poster_path,
      backdrop_path,
      imdb_id,
      tmdb_id,
      platform_id,
    } = req.body;

    if (!title || !type) {
      return res.status(400).json({ error: "Título y tipo son obligatorios" });
    }

    await dbPool.execute(
      `
      UPDATE content
      SET title = ?, title_en = ?, year = ?, type = ?, rating = ?, runtime = ?,
          seasons = ?, episodes = ?, genres = ?, overview = ?, poster_path = ?, backdrop_path = ?,
          imdb_id = ?, tmdb_id = ?, platform_id = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `,
      [
        title,
        title_en || null,
        year || null,
        type,
        rating || null,
        runtime || null,
        seasons || null,
        episodes || null,
        JSON.stringify(genres || []),
        overview || null,
        poster_path || null,
        backdrop_path || null,
        imdb_id || null,
        tmdb_id || null,
        platform_id || null,
        id,
      ]
    );

    const [updatedContent] = await dbPool.execute(
      `
      SELECT c.*, p.name as platform_name, p.color as platform_color, p.icon as platform_icon
      FROM content c
      LEFT JOIN platforms p ON c.platform_id = p.id
      WHERE c.id = ?
    `,
      [id]
    );

    res.json(updatedContent[0]);
  } catch (error) {
    console.error("Error updating content:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Mark content as watched
app.patch("/api/content/:id/watch", async (req, res) => {
  try {
    const { id } = req.params;

    await dbPool.execute(
      'UPDATE content SET status = "watched", watched_at = CURRENT_TIMESTAMP WHERE id = ?',
      [id]
    );

    res.json({ message: "Contenido marcado como visto" });
  } catch (error) {
    console.error("Error marking content as watched:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Delete content
app.delete("/api/content/:id", async (req, res) => {
  try {
    const { id } = req.params;

    await dbPool.execute("DELETE FROM content WHERE id = ?", [id]);

    res.json({ message: "Contenido eliminado correctamente" });
  } catch (error) {
    console.error("Error deleting content:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Enhanced search with TMDb API for complete information
app.get("/api/search/enhanced", async (req, res) => {
  try {
    const { title, year, type = "movie" } = req.query;

    if (!title) {
      return res.status(400).json({ error: "El título es obligatorio" });
    }

    let result = null;

    // Search in TMDb API with provided credentials
    if (process.env.TMDB_API_KEY) {
      try {
        console.log("🌐 Consultando TMDb API...");

        // Search for the content
        const searchUrl = `https://api.themoviedb.org/3/search/${type}?api_key=${
          process.env.TMDB_API_KEY
        }&query=${encodeURIComponent(
          title
        )}&language=es-ES&include_adult=false${year ? `&year=${year}` : ""}`;

        const searchResponse = await axios.get(searchUrl, { timeout: 5000 });

        if (
          searchResponse.data.results &&
          searchResponse.data.results.length > 0
        ) {
          const item = searchResponse.data.results[0];

          // Get detailed information
          const detailUrl = `https://api.themoviedb.org/3/${type}/${item.id}?api_key=${process.env.TMDB_API_KEY}&language=es-ES&append_to_response=external_ids`;
          const detailResponse = await axios.get(detailUrl, { timeout: 5000 });

          const details = detailResponse.data;

          // Map genres
          const genres = details.genres
            ? details.genres.map((g) => g.name)
            : [];

          // Get title in both languages
          const titleES = details.title || details.name || title;
          let titleEN = titleES;

          // Get English title
          try {
            const englishUrl = `https://api.themoviedb.org/3/${type}/${item.id}?api_key=${process.env.TMDB_API_KEY}&language=en-US`;
            const englishResponse = await axios.get(englishUrl, {
              timeout: 3000,
            });
            titleEN =
              englishResponse.data.title ||
              englishResponse.data.name ||
              titleES;
          } catch (englishError) {
            console.log("⚠️ No se pudo obtener título en inglés");
          }

          result = {
            titleES,
            titleEN,
            year:
              type === "movie"
                ? details.release_date
                  ? new Date(details.release_date).getFullYear()
                  : null
                : details.first_air_date
                ? new Date(details.first_air_date).getFullYear()
                : null,
            rating: details.vote_average
              ? parseFloat(details.vote_average.toFixed(1))
              : null,
            runtime: details.runtime || details.episode_run_time?.[0] || null,
            genres,
            overview: details.overview || null,
            poster_path: details.poster_path
              ? `https://image.tmdb.org/t/p/w500${details.poster_path}`
              : null,
            backdrop_path: details.backdrop_path
              ? `https://image.tmdb.org/t/p/w1280${details.backdrop_path}`
              : null,
            imdb_id: details.external_ids?.imdb_id || null,
            tmdb_id: details.id,
            type,
            source: "tmdb",
          };

          console.log("✅ Datos obtenidos de TMDb");
        }
      } catch (tmdbError) {
        console.log("❌ TMDb API error:", tmdbError.message);
      }
    }

    // Fallback to OMDb if TMDb fails
    if (!result && process.env.OMDB_API_KEY) {
      try {
        console.log("🔄 Fallback a OMDb API...");
        const omdbUrl = `http://www.omdbapi.com/?apikey=${
          process.env.OMDB_API_KEY
        }&t=${encodeURIComponent(title)}${year ? `&y=${year}` : ""}&type=${
          type === "series" ? "series" : "movie"
        }`;
        const omdbResponse = await axios.get(omdbUrl, { timeout: 5000 });

        if (omdbResponse.data.Response === "True") {
          const data = omdbResponse.data;
          result = {
            titleES: data.Title,
            titleEN: data.Title,
            year: parseInt(data.Year) || null,
            rating:
              data.imdbRating !== "N/A" ? parseFloat(data.imdbRating) : null,
            runtime: data.Runtime !== "N/A" ? parseInt(data.Runtime) : null,
            genres: data.Genre !== "N/A" ? data.Genre.split(", ") : [],
            overview: data.Plot !== "N/A" ? data.Plot : null,
            poster_path: data.Poster !== "N/A" ? data.Poster : null,
            imdb_id: data.imdbID,
            type,
            source: "omdb",
          };
        }
      } catch (omdbError) {
        console.log("❌ OMDb API error:", omdbError.message);
      }
    }

    if (result) {
      res.json(result);
    } else {
      res.json({
        error: "No se encontró información para este título",
        suggestion: "Verifica el título o añade la información manualmente",
      });
    }
  } catch (error) {
    console.error("Error in enhanced search:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Get search suggestions with autocomplete dropdown
app.get("/api/search/suggestions", async (req, res) => {
  try {
    const { query } = req.query;

    if (!query || query.length < 3) {
      return res.json({ results: [] });
    }

    if (!process.env.TMDB_API_KEY) {
      return res.status(500).json({
        error: "TMDb API key no configurada",
        results: [],
      });
    }

    console.log(`🔍 Obteniendo sugerencias para: "${query}"`);

    // Búsqueda combinada en TMDb (películas y series)
    const movieSearchUrl = `https://api.themoviedb.org/3/search/movie?api_key=${
      process.env.TMDB_API_KEY
    }&query=${encodeURIComponent(query)}&language=es-ES&include_adult=false`;

    const tvSearchUrl = `https://api.themoviedb.org/3/search/tv?api_key=${
      process.env.TMDB_API_KEY
    }&query=${encodeURIComponent(query)}&language=es-ES&include_adult=false`;

    // Realizar búsquedas en paralelo para optimizar velocidad
    const [movieResponse, tvResponse] = await Promise.all([
      axios.get(movieSearchUrl, { timeout: 3000 }),
      axios.get(tvSearchUrl, { timeout: 3000 }),
    ]);

    const suggestions = [];

    // Procesar resultados de películas
    if (movieResponse.data.results) {
      movieResponse.data.results.slice(0, 3).forEach((movie) => {
        suggestions.push({
          id: movie.id,
          title: movie.title,
          original_title: movie.original_title,
          year: movie.release_date ? movie.release_date.split("-")[0] : "",
          media_type: "movie",
          poster_path: movie.poster_path,
          backdrop_path: movie.backdrop_path,
          overview: movie.overview,
          release_date: movie.release_date,
          display_title: `${movie.title}${
            movie.release_date ? ` (${movie.release_date.split("-")[0]})` : ""
          }`,
        });
      });
    }

    // Procesar resultados de series
    if (tvResponse.data.results) {
      tvResponse.data.results.slice(0, 3).forEach((tv) => {
        suggestions.push({
          id: tv.id,
          title: tv.name,
          name: tv.name,
          original_title: tv.original_name,
          original_name: tv.original_name,
          year: tv.first_air_date ? tv.first_air_date.split("-")[0] : "",
          media_type: "tv",
          poster_path: tv.poster_path,
          backdrop_path: tv.backdrop_path,
          overview: tv.overview,
          first_air_date: tv.first_air_date,
          display_title: `${tv.name}${
            tv.first_air_date ? ` (${tv.first_air_date.split("-")[0]})` : ""
          }`,
        });
      });
    }

    // Ordenar por popularidad y limitar a 5 resultados
    suggestions.sort((a, b) => {
      // Priorizar resultados que comiencen con el query
      const aStartsWith = (a.title || a.name || "")
        .toLowerCase()
        .startsWith(query.toLowerCase());
      const bStartsWith = (b.title || b.name || "")
        .toLowerCase()
        .startsWith(query.toLowerCase());

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;

      return 0;
    });

    res.json({
      results: suggestions.slice(0, 5),
      query: query,
      total_results: suggestions.length,
    });
  } catch (error) {
    console.error("Error obteniendo sugerencias:", error);
    res.status(500).json({
      error: "Error interno del servidor",
      results: [],
    });
  }
});

// Search for movie rating (with cache)
app.get("/api/search", async (req, res) => {
  try {
    const { title, year } = req.query;

    if (!title) {
      return res
        .status(400)
        .json({ error: "El título es obligatorio para la búsqueda" });
    }

    // Primero buscar en cache
    console.log(
      `🔍 Buscando rating para: "${title}"${year ? ` (${year})` : ""}`
    );

    const cacheQuery = year
      ? "SELECT * FROM movie_ratings_cache WHERE title = ? AND year = ? AND cached_at > DATE_SUB(NOW(), INTERVAL 30 DAY)"
      : "SELECT * FROM movie_ratings_cache WHERE title = ? AND cached_at > DATE_SUB(NOW(), INTERVAL 30 DAY) ORDER BY cached_at DESC LIMIT 1";

    const cacheParams = year ? [title, parseInt(year)] : [title];
    const [cachedResults] = await dbPool.execute(cacheQuery, cacheParams);

    if (cachedResults.length > 0) {
      console.log("💾 Rating encontrado en cache");
      return res.json({
        title: cachedResults[0].title,
        year: cachedResults[0].year,
        imdbRating: cachedResults[0].imdb_rating,
        source: "cache",
      });
    }

    // Si no está en cache, buscar en OMDb API
    let result = null;

    if (process.env.OMDB_API_KEY) {
      try {
        console.log("🌐 Consultando OMDb API...");
        const omdbUrl = `http://www.omdbapi.com/?apikey=${
          process.env.OMDB_API_KEY
        }&t=${encodeURIComponent(title)}${year ? `&y=${year}` : ""}`;
        const omdbResponse = await axios.get(omdbUrl, { timeout: 5000 });

        if (omdbResponse.data.Response === "True") {
          const rating =
            omdbResponse.data.imdbRating !== "N/A"
              ? parseFloat(omdbResponse.data.imdbRating)
              : null;

          result = {
            title: omdbResponse.data.Title,
            year: parseInt(omdbResponse.data.Year) || null,
            imdbRating: rating,
            imdbID: omdbResponse.data.imdbID,
            source: "omdb",
          };

          // Guardar en cache
          try {
            await dbPool.execute(
              "INSERT INTO movie_ratings_cache (title, year, imdb_rating, imdb_id) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE imdb_rating = VALUES(imdb_rating), cached_at = NOW()",
              [result.title, result.year, result.imdbRating, result.imdbID]
            );
            console.log("💾 Rating guardado en cache");
          } catch (cacheError) {
            console.log("⚠️ Error guardando en cache:", cacheError.message);
          }
        }
      } catch (omdbError) {
        console.log("❌ OMDb API error:", omdbError.message);
      }
    }

    if (result) {
      res.json(result);
    } else {
      res.json({
        error: "No se encontró rating para este título",
        suggestion: "Verifica el título o añade el rating manualmente",
      });
    }
  } catch (error) {
    console.error("Error searching rating:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// Health check endpoint
app.get("/api/health", async (req, res) => {
  try {
    const connection = await dbPool.getConnection();
    connection.release();
    res.json({
      status: "OK",
      timestamp: new Date().toISOString(),
      database: "Connected",
    });
  } catch (error) {
    res.status(503).json({
      status: "ERROR",
      timestamp: new Date().toISOString(),
      database: "Disconnected",
      error: error.message,
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);
  res.status(500).json({
    error: "Error interno del servidor",
    message:
      process.env.NODE_ENV === "development" ? err.message : "Algo salió mal",
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Endpoint no encontrado" });
});

// Start server
app.listen(PORT, () => {
  console.log("🎬 MovieFlix Backend iniciado");
  console.log(`🚀 Servidor ejecutándose en http://localhost:${PORT}`);
  console.log(`📊 Entorno: ${process.env.NODE_ENV}`);
  console.log(`🔗 API Health Check: http://localhost:${PORT}/api/health`);
  testConnection();
});

// Graceful shutdown
process.on("SIGINT", async () => {
  console.log("\n🛑 Cerrando servidor MovieFlix...");
  await dbPool.end();
  process.exit(0);
});
