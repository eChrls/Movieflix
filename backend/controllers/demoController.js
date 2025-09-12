/**
 * 🎬 MovieFlix Demo Controller
 * Simula todas las operaciones CRUD en memoria
 * Funcionalidad completa sin persistencia real
 */

const {
  demoData,
  sanitizeInput,
  generateDemoId,
  findContentByTitle,
  getContentByStatus,
  getTopContent,
} = require("../middleware/demoMode");

class DemoController {
  // 🔐 Autenticación demo
  static authenticate(req, res) {
    const { code } = req.body;
    const demoCode = process.env.DEMO_CODE || "5202";

    if (code === demoCode) {
      res.json({
        success: true,
        message: "🎭 Acceso demo autorizado",
        demoMode: true,
      });
    } else {
      res.status(401).json({
        success: false,
        error: "Código incorrecto",
      });
    }
  }

  // 👥 Gestión de perfiles
  static getProfiles(req, res) {
    res.json({
      success: true,
      data: demoData.profiles,
      message: "📋 Perfiles demo cargados",
    });
  }

  static createProfile(req, res) {
    const { name, emoji } = req.body;
    const newProfile = {
      id: generateDemoId(),
      name: sanitizeInput(name),
      emoji: emoji || "👤",
      created_at: new Date().toISOString(),
    };

    // Simular creación (no persiste)
    res.json({
      success: true,
      data: newProfile,
      message: `✅ Perfil "${name}" creado (modo demo)`,
    });
  }

  static deleteProfile(req, res) {
    const { id } = req.params;
    res.json({
      success: true,
      message: `🗑️ Perfil eliminado (modo demo)`,
    });
  }

  // 🎬 Gestión de contenido
  static getContent(req, res) {
    const { profile_id, status = "pending" } = req.query;
    const profileId = parseInt(profile_id);

    const content = getContentByStatus(profileId, status);

    res.json({
      success: true,
      data: content,
      count: content.length,
      message: `🎭 Contenido ${status} demo cargado`,
    });
  }

  static addContent(req, res) {
    const contentData = req.body;

    // Validar duplicados en demo
    const existing = findContentByTitle(
      contentData.title,
      contentData.profile_id
    );
    if (existing) {
      return res.status(400).json({
        success: false,
        error: `La película "${contentData.title}" ya está en tu lista demo.`,
      });
    }

    const newContent = {
      id: generateDemoId(),
      title: sanitizeInput(contentData.title),
      year: contentData.year,
      genre: contentData.genre,
      rating: contentData.rating,
      status: "pending",
      type: contentData.type || "movie",
      profile_id: contentData.profile_id,
      platform_id: contentData.platform_id,
      platform_name: contentData.platform_name,
      poster_url: contentData.poster_url || "/api/placeholder/300/450",
      created_at: new Date().toISOString(),
    };

    res.json({
      success: true,
      data: newContent,
      message: `✅ "${contentData.title}" agregado (modo demo)`,
    });
  }

  static updateContent(req, res) {
    const { id } = req.params;
    const updates = req.body;

    res.json({
      success: true,
      data: { id: parseInt(id), ...updates },
      message: "✅ Contenido actualizado (modo demo)",
    });
  }

  static deleteContent(req, res) {
    const { id } = req.params;
    res.json({
      success: true,
      message: `🗑️ Contenido eliminado (modo demo)`,
    });
  }

  static markAsWatched(req, res) {
    const { id } = req.params;
    res.json({
      success: true,
      message: `✅ Marcado como visto (modo demo)`,
    });
  }

  static markAsPending(req, res) {
    const { id } = req.params;
    res.json({
      success: true,
      message: `📋 Devuelto a pendientes (modo demo)`,
    });
  }

  // 🏆 Top content
  static getTopMovies(req, res) {
    const topMovies = getTopContent("movie");
    res.json({
      success: true,
      data: topMovies,
      message: "🏆 Top películas demo",
    });
  }

  static getTopSeries(req, res) {
    const topSeries = getTopContent("series");
    res.json({
      success: true,
      data: topSeries,
      message: "📺 Top series demo",
    });
  }

  // 🔍 Búsquedas
  static getSearchSuggestions(req, res) {
    const { query } = req.query;

    // Simular sugerencias basadas en contenido demo
    const suggestions = demoData.content
      .filter((item) => item.title.toLowerCase().includes(query.toLowerCase()))
      .slice(0, 5)
      .map((item) => ({
        title: item.title,
        year: item.year,
        type: item.type,
        poster: item.poster_url,
      }));

    res.json({
      success: true,
      data: suggestions,
      message: "🔍 Sugerencias demo",
    });
  }

  // 🎯 Plataformas
  static getPlatforms(req, res) {
    res.json({
      success: true,
      data: demoData.platforms,
      message: "📱 Plataformas demo",
    });
  }

  // 💫 Health check
  static healthCheck(req, res) {
    res.json({
      status: "OK",
      mode: "DEMO",
      database: "Simulated",
      timestamp: new Date().toISOString(),
      message: "🎭 MovieFlix Demo Mode activo",
    });
  }
}

module.exports = DemoController;
