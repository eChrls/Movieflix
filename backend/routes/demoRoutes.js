/**
 * 🎬 MovieFlix Demo Routes
 * Sistema de rutas condicionales según modo de operación
 * DEMO_MODE=true → DemoController (datos simulados)
 * DEMO_MODE=false → ProductionController (MySQL real)
 */

const express = require("express");
const { isDemoMode } = require("../middleware/demoMode");
const DemoController = require("../controllers/demoController");

const router = express.Router();

// 🎭 Middleware para indicar modo demo
router.use((req, res, next) => {
  if (isDemoMode) {
    res.setHeader("X-Demo-Mode", "true");
    res.setHeader("X-Data-Source", "simulated");
  } else {
    res.setHeader("X-Demo-Mode", "false");
    res.setHeader("X-Data-Source", "mysql");
  }
  next();
});

/**
 * CONFIGURACIÓN CONDICIONAL DE RUTAS
 * Si DEMO_MODE=true, todas las rutas usan DemoController
 * Si DEMO_MODE=false, las rutas se manejan en server.js principal
 */

if (isDemoMode) {
  console.log("🎭 DEMO MODE ACTIVADO - Usando datos simulados");

  // 🔐 Autenticación
  router.post("/authenticate", DemoController.authenticate);

  // 👥 Perfiles
  router.get("/profiles", DemoController.getProfiles);
  router.post("/profiles", DemoController.createProfile);
  router.delete("/profiles/:id", DemoController.deleteProfile);

  // 🎬 Contenido
  router.get("/content", DemoController.getContent);
  router.post("/content", DemoController.addContent);
  router.put("/content/:id", DemoController.updateContent);
  router.delete("/content/:id", DemoController.deleteContent);
  router.patch("/content/:id/watch", DemoController.markAsWatched);
  router.patch("/content/:id/unwatch", DemoController.markAsPending);

  // 🏆 Top content
  router.get("/top/movies", DemoController.getTopMovies);
  router.get("/top/series", DemoController.getTopSeries);

  // 🔍 Búsquedas
  router.get("/search/suggestions", DemoController.getSearchSuggestions);

  // 🎯 Plataformas
  router.get("/platforms", DemoController.getPlatforms);

  // 💫 Health check
  router.get("/health", DemoController.healthCheck);
} else {
  console.log("🚀 PRODUCTION MODE - Usando MySQL database");

  // En modo producción, las rutas se manejan en server.js
  // Este archivo solo actúa como middleware informativo
  router.use((req, res, next) => {
    // Las rutas de producción se definen en server.js
    next();
  });
}

module.exports = router;
