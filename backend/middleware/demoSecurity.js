/**
 * 🛡️ MovieFlix Demo Security Middleware
 * Rate limiting y medidas de seguridad para modo demo
 */

const rateLimit = require("express-rate-limit");
const { isDemoMode, sanitizeInput } = require("./demoMode");

// 🚫 Rate limiter específico para demo
const demoLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 200, // máximo 200 requests por IP (generoso para demo)
  message: {
    success: false,
    error: "Demasiadas requests. Es una demo, ten paciencia 😊",
    retryAfter: "15 minutos",
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Personalizar headers para demo
  onLimitReached: (req, res) => {
    console.log(`🚫 Rate limit alcanzado para IP: ${req.ip} en modo demo`);
  },
});

// 🧹 Middleware de sanitización para demo
const demoSanitizer = (req, res, next) => {
  if (isDemoMode && req.body) {
    // Sanitizar todos los strings en el body
    const sanitizeObject = (obj) => {
      for (const key in obj) {
        if (typeof obj[key] === "string") {
          obj[key] = sanitizeInput(obj[key]);
        } else if (typeof obj[key] === "object" && obj[key] !== null) {
          sanitizeObject(obj[key]);
        }
      }
    };

    sanitizeObject(req.body);

    // Limitar tamaño del payload en demo
    const jsonString = JSON.stringify(req.body);
    if (jsonString.length > 2000) {
      return res.status(413).json({
        success: false,
        error: "Payload demasiado grande para el modo demo",
        limit: "2KB máximo",
      });
    }
  }

  next();
};

// 🔒 Headers de seguridad para demo
const demoSecurityHeaders = (req, res, next) => {
  if (isDemoMode) {
    res.setHeader("X-Content-Type-Options", "nosniff");
    res.setHeader("X-Frame-Options", "SAMEORIGIN");
    res.setHeader("X-XSS-Protection", "1; mode=block");
    res.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
    res.setHeader(
      "X-Demo-Warning",
      "This is a demonstration. Data is not persistent."
    );
  }
  next();
};

// 📊 Logger específico para demo
const demoLogger = (req, res, next) => {
  if (isDemoMode) {
    const start = Date.now();

    res.on("finish", () => {
      const duration = Date.now() - start;
      const logColor = res.statusCode >= 400 ? "\x1b[31m" : "\x1b[32m"; // Rojo para errores, verde para éxito
      const resetColor = "\x1b[0m";

      console.log(
        `🎭 DEMO ${logColor}${req.method}${resetColor} ${req.path} - ${res.statusCode} (${duration}ms) [${req.ip}]`
      );
    });
  }
  next();
};

// 🎯 Middleware combinado para demo
const applyDemoSecurity = (app) => {
  if (isDemoMode) {
    console.log("🛡️ Aplicando medidas de seguridad para modo demo...");

    // Aplicar rate limiting solo a rutas de API en modo demo
    app.use("/api", demoLimiter);

    // Aplicar sanitización
    app.use(demoSanitizer);

    // Aplicar headers de seguridad
    app.use(demoSecurityHeaders);

    // Aplicar logging específico
    app.use(demoLogger);

    console.log("✅ Seguridad demo configurada correctamente");
  }
};

module.exports = {
  demoLimiter,
  demoSanitizer,
  demoSecurityHeaders,
  demoLogger,
  applyDemoSecurity,
};
