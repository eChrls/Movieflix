/**
 * 🎬 MovieFlix Demo Mode Middleware
 * Gestiona el comportamiento en modo demostración para portfolio
 *
 * Características:
 * - Datos simulados en memoria (no persisten)
 * - Rate limiting para evitar abuso
 * - Sanitización automática de inputs
 * - Funcionalidad completa sin BD real
 */

const isDemoMode = process.env.DEMO_MODE === "true";
const demoPassword = process.env.DEMO_PASSWORD || "demo2024";

// 🎭 Datos demo realistas y completos
const demoData = {
  profiles: [
    {
      id: 1,
      name: "Demo User",
      emoji: "👤",
      created_at: new Date("2024-01-15").toISOString(),
    },
    {
      id: 2,
      name: "Familia",
      emoji: "👨‍👩‍👧‍👦",
      created_at: new Date("2024-02-01").toISOString(),
    },
    {
      id: 3,
      name: "Niños",
      emoji: "🧒",
      created_at: new Date("2024-02-15").toISOString(),
    },
  ],

  platforms: [
    { id: 1, name: "Netflix", logo_url: "/images/netflix.png" },
    { id: 2, name: "HBO Max", logo_url: "/images/hbo.png" },
    { id: 3, name: "Disney+", logo_url: "/images/disney.png" },
    { id: 4, name: "Amazon Prime", logo_url: "/images/prime.png" },
    { id: 5, name: "Apple TV+", logo_url: "/images/apple.png" },
  ],

  content: [
    {
      id: 1,
      title: "Inception",
      year: 2010,
      genre: '["Sci-Fi","Thriller","Drama"]',
      rating: 8.8,
      status: "watched",
      type: "movie",
      profile_id: 1,
      platform_id: 1,
      platform_name: "Netflix",
      poster_url:
        "https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
      created_at: new Date("2024-03-01").toISOString(),
      watched_at: new Date("2024-03-05").toISOString(),
    },
    {
      id: 2,
      title: "The Dark Knight",
      year: 2008,
      genre: '["Action","Crime","Drama"]',
      rating: 9.0,
      status: "watched",
      type: "movie",
      profile_id: 1,
      platform_id: 2,
      platform_name: "HBO Max",
      poster_url:
        "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
      created_at: new Date("2024-03-02").toISOString(),
      watched_at: new Date("2024-03-10").toISOString(),
    },
    {
      id: 3,
      title: "Interstellar",
      year: 2014,
      genre: '["Sci-Fi","Drama","Adventure"]',
      rating: 8.6,
      status: "pending",
      type: "movie",
      profile_id: 1,
      platform_id: 1,
      platform_name: "Netflix",
      poster_url:
        "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
      created_at: new Date("2024-03-03").toISOString(),
    },
    {
      id: 4,
      title: "Breaking Bad",
      year: 2008,
      genre: '["Crime","Drama","Thriller"]',
      rating: 9.5,
      status: "watched",
      type: "series",
      seasons: 5,
      episodes: 62,
      profile_id: 2,
      platform_id: 1,
      platform_name: "Netflix",
      poster_url:
        "https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg",
      created_at: new Date("2024-02-20").toISOString(),
      watched_at: new Date("2024-03-15").toISOString(),
    },
    {
      id: 5,
      title: "The Mandalorian",
      year: 2019,
      genre: '["Sci-Fi","Adventure","Action"]',
      rating: 8.7,
      status: "pending",
      type: "series",
      seasons: 3,
      episodes: 24,
      profile_id: 3,
      platform_id: 3,
      platform_name: "Disney+",
      poster_url:
        "https://image.tmdb.org/t/p/w500/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg",
      created_at: new Date("2024-03-05").toISOString(),
    },
    {
      id: 6,
      title: "Dune",
      year: 2021,
      genre: '["Sci-Fi","Adventure","Drama"]',
      rating: 8.1,
      status: "pending",
      type: "movie",
      profile_id: 1,
      platform_id: 2,
      platform_name: "HBO Max",
      poster_url:
        "https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
      created_at: new Date("2024-03-07").toISOString(),
    },
  ],
};

// 🛡️ Sanitización de inputs para demo
const sanitizeInput = (input) => {
  if (typeof input === "string") {
    return input.substring(0, 100).replace(/[<>]/g, "");
  }
  return input;
};

// 🎲 Generador de IDs únicos para demo
let nextId = 100;
const generateDemoId = () => ++nextId;

// 🔍 Utilidades para demo
const findContentByTitle = (title, profileId) => {
  return demoData.content.find(
    (item) =>
      item.title.toLowerCase() === title.toLowerCase() &&
      item.profile_id === profileId
  );
};

const getContentByStatus = (profileId, status) => {
  return demoData.content.filter(
    (item) => item.profile_id === profileId && item.status === status
  );
};

const getTopContent = (type, limit = 3) => {
  return demoData.content
    .filter((item) => item.type === type && item.status === "watched")
    .sort((a, b) => b.rating - a.rating)
    .slice(0, limit);
};

module.exports = {
  isDemoMode,
  demoPassword,
  demoData,
  sanitizeInput,
  generateDemoId,
  findContentByTitle,
  getContentByStatus,
  getTopContent,
};
