import React, { useState, useEffect } from "react";
import {
  Search,
  Plus,
  Star,
  Check,
  X,
  Edit,
  Trash2,
  Loader2,
  AlertCircle,
  WifiOff,
  ChevronUp,
} from "lucide-react";

const API_BASE =
  process.env.NODE_ENV === "production" ? "/api" : "http://localhost:3001/api";

const MovieManager = () => {
  // State management
  const [profiles, setProfiles] = useState([]);
  const [currentProfile, setCurrentProfile] = useState(null);
  const [content, setContent] = useState([]);
  const [watchedContent, setWatchedContent] = useState([]);
  const [platforms, setPlatforms] = useState([]);
  const [genres, setGenres] = useState([]);
  const [activeTab, setActiveTab] = useState("pending");
  const [filters, setFilters] = useState({
    type: "",
    platform: "",
    genre: "",
    search: "",
  });
  const [topContent, setTopContent] = useState({ movies: [], series: [] });
  const [showAddModal, setShowAddModal] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [editingContent, setEditingContent] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [error, setError] = useState(null);
  const [searchLoading, setSearchLoading] = useState(false);
  const [showPlatformMenu, setShowPlatformMenu] = useState(null); // Para el menú de plataformas
  const [showScrollTop, setShowScrollTop] = useState(false); // Para el botón volver arriba
  const [topActiveTab, setTopActiveTab] = useState("movies"); // Para las pestañas del Top 3
  const [searchSuggestions, setSearchSuggestions] = useState([]); // Para sugerencias de búsqueda
  const [showSuggestions, setShowSuggestions] = useState(false); // Mostrar dropdown de sugerencias

  const [newContent, setNewContent] = useState({
    title: "",
    title_en: "",
    year: "",
    type: "movie",
    rating: "",
    runtime: "",
    genres: [],
    overview: "",
    poster_path: "",
    backdrop_path: "",
    imdb_id: "",
    tmdb_id: "",
    platform_id: "",
  });

  // Network status monitoring
  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);
    const handleClickOutside = (event) => {
      // Cerrar menú de plataformas si se hace click fuera
      if (!event.target.closest(".platform-menu-container")) {
        setShowPlatformMenu(null);
      }
    };
    const handleScroll = () => {
      // Mostrar botón volver arriba cuando se hace scroll hacia abajo
      setShowScrollTop(window.pageYOffset > 300);
    };

    window.addEventListener("online", handleOnline);
    window.addEventListener("offline", handleOffline);
    window.addEventListener("scroll", handleScroll);
    document.addEventListener("click", handleClickOutside);

    return () => {
      window.removeEventListener("online", handleOnline);
      window.removeEventListener("offline", handleOffline);
      window.removeEventListener("scroll", handleScroll);
      document.removeEventListener("click", handleClickOutside);
    };
  }, []);

  // API helper with error handling
  const apiCall = async (url, options = {}) => {
    try {
      const response = await fetch(`${API_BASE}${url}`, {
        headers: {
          "Content-Type": "application/json",
          ...options.headers,
        },
        ...options,
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error(`API Error (${url}):`, error);
      setError(`Error de conexión: ${error.message}`);
      throw error;
    }
  };

  // Genre parsing helper - handles both JSON and string formats safely
  const parseGenres = (genresData) => {
    if (!genresData) return [];

    try {
      // If it's already an array, return it
      if (Array.isArray(genresData)) return genresData;

      // If it's a string, try to parse as JSON first
      if (typeof genresData === "string") {
        // Check if it looks like JSON (starts with [ or ")
        if (genresData.startsWith("[") || genresData.startsWith('"')) {
          return JSON.parse(genresData);
        }
        // Otherwise, treat as comma-separated string
        return genresData
          .split(",")
          .map((g) => g.trim())
          .filter((g) => g);
      }

      return [];
    } catch (error) {
      console.warn("Error parsing genres:", genresData, error);
      // Fallback: treat as comma-separated string
      return typeof genresData === "string"
        ? genresData
            .split(",")
            .map((g) => g.trim())
            .filter((g) => g)
        : [];
    }
  };

  // Load initial data
  useEffect(() => {
    const initializeApp = async () => {
      setLoading(true);
      setError(null);

      try {
        await Promise.all([loadProfiles(), loadPlatforms(), loadGenres()]);
      } catch (error) {
        setError("Error cargando datos iniciales");
      } finally {
        setLoading(false);
      }
    };

    initializeApp();
  }, []);

  useEffect(() => {
    if (currentProfile) {
      loadContent();
      loadTopContent();
    }
  }, [currentProfile, filters, activeTab]);

  const loadProfiles = async () => {
    try {
      const data = await apiCall("/profiles");
      setProfiles(data);

      if (data.length > 0 && !currentProfile) {
        setCurrentProfile(data.find((p) => p.name === "Home") || data[0]);
      }
    } catch (error) {
      console.error("Error loading profiles:", error);
    }
  };

  const loadPlatforms = async () => {
    try {
      const data = await apiCall("/platforms");
      setPlatforms(data);
    } catch (error) {
      console.error("Error loading platforms:", error);
    }
  };

  const loadGenres = async () => {
    try {
      const data = await apiCall("/genres");
      setGenres(data);
    } catch (error) {
      console.error("Error loading genres:", error);
    }
  };

  const loadContent = async () => {
    if (!currentProfile) return;

    try {
      const params = new URLSearchParams({
        status: activeTab,
        ...filters,
      });

      const data = await apiCall(`/content/${currentProfile.id}?${params}`);

      if (activeTab === "pending") {
        setContent(data);
      } else {
        setWatchedContent(data);
      }
    } catch (error) {
      console.error("Error loading content:", error);
    }
  };

  // Función para búsqueda mejorada con TMDb API
  const searchEnhancedAPI = async (title, year, type = "movie") => {
    if (!title.trim()) return;

    setSearchLoading(true);
    try {
      const data = await apiCall(
        `/search/enhanced?title=${encodeURIComponent(
          title
        )}&year=${year}&type=${type}`
      );

      if (!data.error) {
        console.log("✅ Datos obtenidos:", data);
        return {
          title: data.titleES || title,
          title_en: data.titleEN || title,
          year: data.year,
          rating: data.rating,
          runtime: data.runtime,
          genres: data.genres || [],
          overview: data.overview,
          poster_path: data.poster_path,
          backdrop_path: data.backdrop_path,
          imdb_id: data.imdb_id,
          tmdb_id: data.tmdb_id,
          type: type,
        };
      } else {
        console.log("⚠️ No se encontraron datos:", data.error);
        return null;
      }
    } catch (error) {
      console.error("Error searching enhanced API:", error);
      return null;
    } finally {
      setSearchLoading(false);
    }
  };

  // Función para autocompletar solo el rating desde OMDb API con cache
  const searchMovieRating = async (title, year) => {
    if (!title || title.length < 3) return null;

    setSearchLoading(true);
    try {
      const yearParam = year ? `&year=${year}` : "";
      const response = await fetch(
        `http://localhost:3001/api/search?title=${encodeURIComponent(
          title
        )}${yearParam}`
      );
      const data = await response.json();

      setSearchLoading(false);

      if (data && data.imdbRating && data.imdbRating !== "N/A") {
        console.log(
          `✅ Rating encontrado: ${data.imdbRating}/10 (${
            data.source || "OMDb"
          })`
        );
        return data.imdbRating;
      }

      if (data.error) {
        console.log(`⚠️ ${data.error}`);
      }
      return null;
    } catch (error) {
      console.error("Error buscando rating:", error);
      setSearchLoading(false);
      return null;
    }
  };

  // Función para obtener sugerencias de búsqueda
  const getSearchSuggestions = async (query) => {
    if (!query || query.length < 2) {
      setSearchSuggestions([]);
      setShowSuggestions(false);
      return;
    }

    try {
      const data = await apiCall(
        `/search/suggestions?query=${encodeURIComponent(query)}`
      );
      
      if (data && data.results) {
        setSearchSuggestions(data.results.slice(0, 5)); // Limitar a 5 sugerencias
        setShowSuggestions(true);
      }
    } catch (error) {
      console.error("Error getting suggestions:", error);
      setSearchSuggestions([]);
      setShowSuggestions(false);
    }
  };

  // Función para seleccionar una sugerencia y completar el formulario
  const selectSuggestion = async (suggestion) => {
    setNewContent({
      ...newContent,
      title: suggestion.title || suggestion.name,
      title_en: suggestion.original_title || suggestion.original_name,
      year: suggestion.release_date ? suggestion.release_date.split('-')[0] : suggestion.first_air_date ? suggestion.first_air_date.split('-')[0] : '',
      type: suggestion.media_type === 'tv' ? 'series' : 'movie',
      tmdb_id: suggestion.id,
      poster_path: suggestion.poster_path ? `https://image.tmdb.org/t/p/w500${suggestion.poster_path}` : '',
      backdrop_path: suggestion.backdrop_path ? `https://image.tmdb.org/t/p/w1280${suggestion.backdrop_path}` : '',
      overview: suggestion.overview,
    });

    // Buscar datos adicionales (rating, duración, etc.)
    const enhancedData = await searchEnhancedAPI(
      suggestion.title || suggestion.name,
      suggestion.release_date ? suggestion.release_date.split('-')[0] : suggestion.first_air_date ? suggestion.first_air_date.split('-')[0] : '',
      suggestion.media_type === 'tv' ? 'series' : 'movie'
    );

    if (enhancedData) {
      setNewContent(prev => ({
        ...prev,
        rating: enhancedData.rating || prev.rating,
        runtime: enhancedData.runtime || prev.runtime,
        genres: enhancedData.genres || prev.genres,
        imdb_id: enhancedData.imdb_id || prev.imdb_id,
      }));
    }

    setShowSuggestions(false);
    setSearchSuggestions([]);
  };

  // Función para cambiar plataforma
  const changePlatform = async (contentId, newPlatformId) => {
    try {
      await apiCall(`/content/${contentId}`, {
        method: "PUT",
        body: JSON.stringify({ platform_id: newPlatformId }),
      });

      // Recargar contenido para reflejar cambios
      loadContent();
      setShowPlatformMenu(null);
    } catch (error) {
      console.error("Error cambiando plataforma:", error);
    }
  };

  const loadTopContent = async () => {
    if (!currentProfile) return;

    try {
      const data = await apiCall(`/content/${currentProfile.id}/top`);
      setTopContent(data);
    } catch (error) {
      console.error("Error loading top content:", error);
    }
  };

  const createProfile = async (name, emoji) => {
    try {
      const newProfile = await apiCall("/profiles", {
        method: "POST",
        body: JSON.stringify({ name, emoji }),
      });

      setProfiles([...profiles, newProfile]);
      setCurrentProfile(newProfile);
      setShowProfileModal(false);
    } catch (error) {
      console.error("Error creating profile:", error);
    }
  };

  const addContent = async (contentData) => {
    try {
      const newContent = await apiCall("/content", {
        method: "POST",
        body: JSON.stringify({ ...contentData, profile_id: currentProfile.id }),
      });

      setContent([newContent, ...content]);
      loadTopContent();
    } catch (error) {
      console.error("Error adding content:", error);
    }
  };

  const updateContent = async (id, contentData) => {
    try {
      const updatedContent = await apiCall(`/content/${id}`, {
        method: "PUT",
        body: JSON.stringify(contentData),
      });

      setContent(content.map((c) => (c.id === id ? updatedContent : c)));
      loadTopContent();
    } catch (error) {
      console.error("Error updating content:", error);
    }
  };

  const markAsWatched = async (id) => {
    try {
      await apiCall(`/content/${id}/watch`, { method: "PATCH" });
      setContent(content.filter((c) => c.id !== id));
      loadTopContent();
      loadContent();
    } catch (error) {
      console.error("Error marking as watched:", error);
    }
  };

  const deleteContent = async (id) => {
    try {
      await apiCall(`/content/${id}`, { method: "DELETE" });
      setContent(content.filter((c) => c.id !== id));
      setWatchedContent(watchedContent.filter((c) => c.id !== id));
      loadTopContent();
    } catch (error) {
      console.error("Error deleting content:", error);
    }
  };

  const searchExternalAPI = async (title, year) => {
    if (!title.trim()) return;

    setSearchLoading(true);
    try {
      const data = await apiCall(
        `/search?title=${encodeURIComponent(title)}&year=${year}`
      );
      if (!data.error) {
        setNewContent({
          ...newContent,
          ...data,
        });
      }
    } catch (error) {
      console.error("Error searching external API:", error);
    } finally {
      setSearchLoading(false);
    }
  };

  const filteredContent = (
    activeTab === "pending" ? content : watchedContent
  ).filter((item) => {
    // Debug logging
    if (filters.platform) {
      console.log(
        "Filtering by platform:",
        filters.platform,
        "Item platform_id:",
        item.platform_id,
        "Parsed:",
        parseInt(filters.platform)
      );
    }

    if (
      filters.search &&
      !item.title.toLowerCase().includes(filters.search.toLowerCase())
    ) {
      return false;
    }
    if (filters.type && item.type !== filters.type) return false;
    if (filters.platform && item.platform_id !== parseInt(filters.platform))
      return false;
    if (
      filters.genre &&
      !parseGenres(item.genres || "[]").includes(filters.genre)
    )
      return false;
    return true;
  });

  // Platform color mapping - Updated per user specifications
  const getPlatformColor = (platformName) => {
    const colors = {
      Netflix: "#E50914",
      HBO: "#9B59B6",
      "Prime Video": "#00A8E1",
      "Apple TV+": "#000000",
      "Disney+": "#113CCF",
      SkyShowtime: "#0064FF",
      "Movistar+": "#00B7ED",
      Filmin: "#10B981", // 🟢 VERDE - Como solicitado
      APK: "#FF8500", // 🟠 NARANJA - Como solicitado
      // Shudder y Criterion Channel removidos como solicitado
    };
    return colors[platformName] || "#333333";
  };

  // Función para scroll hacia arriba
  const scrollToTop = () => {
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    });
  };

  // Components
  const LoadingSpinner = () => (
    <div className="flex items-center justify-center p-8">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-red-600"></div>
    </div>
  );

  const ScrollToTopButton = () => (
    <button
      onClick={scrollToTop}
      className={`fixed bottom-4 right-4 bg-red-600 hover:bg-red-700 text-white p-3 rounded-full shadow-lg transition-all duration-300 z-50 ${
        showScrollTop
          ? "opacity-100 translate-y-0"
          : "opacity-0 translate-y-4 pointer-events-none"
      }`}
      title="Volver arriba"
      aria-label="Volver arriba"
    >
      <ChevronUp size={20} />
    </button>
  );

  const ContentCard = ({ item, isWatched = false }) => (
    <div className="bg-gray-card rounded-lg border border-gray-700 overflow-hidden hover:border-netflix-dark hover:shadow-lg transition-all duration-300 group font-maven">
      {/* Poster Section - Más rectangular y alargado */}
      <div className="relative">
        {item.poster_path ? (
          <img
            src={item.poster_path}
            alt={item.title}
            className="w-full h-64 sm:h-72 object-contain bg-gray-800"
            loading="lazy"
            onError={(e) => {
              // Fallback si la imagen no carga
              e.target.style.display = "none";
              e.target.nextSibling.style.display = "flex";
            }}
          />
        ) : null}

        {/* Fallback cuando no hay poster */}
        <div
          className={`w-full h-64 sm:h-72 bg-gray-800 flex items-center justify-center ${
            item.poster_path ? "hidden" : "flex"
          }`}
        >
          <span className="text-6xl">
            {item.type === "series" ? "📺" : "🎬"}
          </span>
        </div>

        {/* Rating badge overlay */}
        {item.rating && (
          <div className="absolute top-2 right-2 bg-yellow-600 text-yellow-100 px-2 py-1 rounded-lg text-xs font-bold flex items-center gap-1 font-tech">
            <Star size={12} fill="currentColor" />
            {item.rating}
          </div>
        )}

        {/* Action buttons overlay */}
        <div className="absolute top-2 left-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
          {!isWatched && (
            <button
              onClick={() => markAsWatched(item.id)}
              className="bg-green-600 hover:bg-green-700 text-white p-2 rounded-lg transition-colors"
              title="Marcar como visto"
              aria-label="Marcar como visto"
            >
              <Check size={14} />
            </button>
          )}
          <button
            onClick={() => {
              setEditingContent(item);
              setNewContent({
                title: item.title,
                title_en: item.title_en,
                year: item.year,
                type: item.type,
                rating: item.rating,
                runtime: item.runtime,
                genres: parseGenres(item.genres || "[]"),
                overview: item.overview,
                poster_path: item.poster_path,
                backdrop_path: item.backdrop_path,
                imdb_id: item.imdb_id,
                tmdb_id: item.tmdb_id,
                platform_id: item.platform_id,
              });
              setShowAddModal(true);
            }}
            className="bg-blue-600 hover:bg-blue-700 text-white p-2 rounded-lg transition-colors"
            title="Editar"
            aria-label="Editar"
          >
            <Edit size={14} />
          </button>
          <button
            onClick={() => deleteContent(item.id)}
            className="bg-netflix-darker hover:bg-netflix text-white p-2 rounded-lg transition-colors"
            title="Eliminar"
            aria-label="Eliminar"
          >
            <Trash2 size={14} />
          </button>
        </div>
      </div>

      <div className="p-3">
        <div className="flex justify-between items-start mb-2">
          <div className="flex-1 min-w-0">
            <h3
              className="text-white font-semibold text-sm sm:text-base mb-1 truncate font-maven"
              title={item.title}
            >
              {item.title}
            </h3>
            {item.title_en && item.title_en !== item.title && (
              <p
                className="text-gray-400 text-xs mb-1 truncate font-maven"
                title={item.title_en}
              >
                {item.title_en}
              </p>
            )}
            <div className="flex items-center gap-2 mb-1 flex-wrap">
              <span className="text-gray-400 text-xs font-tech">{item.year}</span>
              {item.runtime && (
                <span className="text-gray-400 text-xs font-tech">
                  {item.runtime} min
                </span>
              )}
              {/* Temporadas y episodios para series */}
              {item.type === "series" && item.seasons && (
                <span className="text-gray-400 text-xs font-tech">
                  {item.seasons} temp.
                </span>
              )}
              {item.type === "series" && item.episodes && (
                <span className="text-gray-400 text-xs font-tech">
                  {item.episodes} ep.
                </span>
              )}
              {/* IMDb link */}
              {item.imdb_id && (
                <a
                  href={`https://www.imdb.com/title/${item.imdb_id}/`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-yellow-400 hover:text-yellow-300 transition-colors"
                  title="Ver en IMDb"
                  onClick={(e) => e.stopPropagation()}
                >
                  <span className="text-xs font-tech">IMDb</span>
                </a>
              )}
            </div>
          </div>
        </div>

        {/* Platform */}
        {item.platform_name && (
          <div className="relative platform-menu-container mb-3">
            <button
              onClick={() =>
                setShowPlatformMenu(
                  showPlatformMenu === item.id ? null : item.id
                )
              }
              className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs text-white font-medium hover:opacity-80 transition-opacity cursor-pointer"
              style={{
                backgroundColor:
                  item.platform_color || getPlatformColor(item.platform_name),
              }}
              title="Click para cambiar plataforma"
            >
              {item.platform_icon} {item.platform_name}
            </button>

            {/* Platform dropdown menu */}
            {showPlatformMenu === item.id && (
              <div className="absolute top-full left-0 mt-1 bg-gray-800 border border-gray-700 rounded-md shadow-lg z-50 min-w-[150px]">
                {platforms.map((platform) => (
                  <button
                    key={platform.id}
                    onClick={() => changePlatform(item.id, platform.id)}
                    className="w-full px-3 py-2 text-left text-sm text-white hover:bg-gray-700 flex items-center gap-2"
                    style={{
                      backgroundColor:
                        item.platform_id === platform.id
                          ? platform.color || getPlatformColor(platform.name)
                          : "transparent",
                    }}
                  >
                    {platform.icon} {platform.name}
                  </button>
                ))}
              </div>
            )}
          </div>
        )}

        {item.genres && parseGenres(item.genres).length > 0 && (
          <div className="flex flex-wrap gap-1 mt-2">
            {parseGenres(item.genres)
              .slice(0, 3)
              .map((genre) => {
                const genreObj = genres.find((g) => g.name === genre);
                return (
                  <span
                    key={genre}
                    className="bg-gray-800 text-gray-400 px-2 py-1 rounded text-xs border border-gray-700"
                  >
                    {genreObj?.icon} {genre}
                  </span>
                );
              })}
            {parseGenres(item.genres).length > 3 && (
              <span className="bg-gray-800 text-gray-500 px-2 py-1 rounded text-xs border border-gray-700">
                +{parseGenres(item.genres).length - 3}
              </span>
            )}
          </div>
        )}
      </div>
    </div>
  );

  const TopCard = ({ item, rank }) => (
    <div className="relative bg-gradient-to-br from-netflix-darker to-gray-card rounded-lg p-2 border border-netflix-dark hover:border-netflix transition-all duration-300 group font-maven">
      <div className="absolute -top-2 -left-2 bg-gradient-to-r from-yellow-500 to-orange-500 text-white rounded-full w-5 h-5 flex items-center justify-center font-bold text-xs shadow-lg font-tech">
        {rank}
      </div>
      <h3 className="text-white font-semibold text-xs sm:text-sm mb-1 pr-4 font-maven">
        {item.title}
      </h3>
      <div className="flex items-center gap-1 text-xs mb-1">
        <span className="bg-yellow-600 text-yellow-100 px-1 py-0.5 rounded text-xs font-medium flex items-center gap-1 font-tech">
          <Star size={8} fill="currentColor" />
          {item.rating}
        </span>
        <span className="text-gray-300 font-maven">{item.year}</span>
        <span>{item.type === "series" ? "📺" : "🎬"}</span>
      </div>
      {/* Duración y temporadas/episodios */}
      <div className="flex items-center gap-2 text-xs text-gray-400 font-maven">
        {item.runtime && <span>{item.runtime} min</span>}
        {item.type === "series" && item.seasons && (
          <span>{item.seasons} temp.</span>
        )}
        {item.type === "series" && item.episodes && (
          <span>{item.episodes} ep.</span>
        )}
      </div>
    </div>
  );

  // Error state
  if (error && !isOnline) {
    return (
      <div className="min-h-screen bg-black flex items-center justify-center p-4">
        <div className="text-center">
          <WifiOff size={64} className="text-red-600 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-white mb-2">Sin conexión</h1>
          <p className="text-gray-400 mb-4">Verifica tu conexión a internet</p>
          <button
            onClick={() => window.location.reload()}
            className="bg-red-600 hover:bg-red-700 px-6 py-2 rounded text-white font-medium"
          >
            Reintentar
          </button>
        </div>
      </div>
    );
  }

  // Loading state
  if (loading) {
    return (
      <div className="min-h-screen bg-black flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-red-600 mx-auto mb-4"></div>
          <h1 className="text-2xl font-bold text-netflix mb-2 font-maven">MovieFlix</h1>
          <p className="text-white">Cargando tu gestor personal...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-carbon text-white font-maven">
      {/* Header */}
      <header className="bg-gray-950 border-b border-gray-700 sticky top-0 z-40 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex flex-col lg:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-4">
              <h1 className="text-3xl font-bold text-netflix flex items-center gap-2 font-maven">
                🎬 MovieFlix
              </h1>
              <div className="flex items-center gap-2">
                <select
                  value={currentProfile?.id || ""}
                  onChange={(e) =>
                    setCurrentProfile(
                      profiles.find((p) => p.id === parseInt(e.target.value))
                    )
                  }
                  className="bg-gray-card border border-gray-600 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-netflix transition-colors font-maven"
                >
                  {profiles.map((profile) => (
                    <option key={profile.id} value={profile.id}>
                      {profile.emoji} {profile.name}
                    </option>
                  ))}
                </select>
                <button
                  onClick={() => setShowProfileModal(true)}
                  className="bg-netflix hover:bg-netflix-dark px-3 py-2 rounded-lg text-sm font-medium transition-colors font-maven"
                >
                  + Perfil
                </button>
              </div>
            </div>

            <div className="flex items-center gap-4 w-full lg:w-auto">
              <div className="relative flex-1 lg:flex-initial">
                <Search
                  size={20}
                  className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                />
                <input
                  type="text"
                  placeholder="Buscar películas y series..."
                  value={filters.search}
                  onChange={(e) =>
                    setFilters({ ...filters, search: e.target.value })
                  }
                  className="bg-gray-800 border border-gray-700 rounded-full pl-10 pr-4 py-2 focus:outline-none focus:border-red-600 transition-colors w-full lg:w-64"
                />
              </div>
              <button
                onClick={() => {
                  setEditingContent(null);
                  setNewContent({
                    title: "",
                    year: "",
                    type: "movie",
                    rating: "",
                    genres: [],
                    platform_id: "",
                  });
                  setShowAddModal(true);
                }}
                className="bg-red-600 hover:bg-red-700 px-4 py-2 rounded-lg flex items-center gap-2 font-medium transition-colors whitespace-nowrap"
              >
                <Plus size={20} />
                <span className="hidden sm:inline">Añadir</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-6">
        {/* Top Content - Rediseñado más compacto */}
        {activeTab === "pending" &&
          (topContent.movies.length > 0 || topContent.series.length > 0) && (
            <section className="mb-6">
              <h2 className="text-xl font-bold mb-4 text-netflix flex items-center gap-2 font-maven">
                🏆 Top 3
              </h2>
              
              {/* Pestañas */}
              <div className="flex mb-4 bg-gray-card rounded-lg p-1 w-fit">
                <button
                  onClick={() => setTopActiveTab("movies")}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-all duration-200 font-maven ${
                    topActiveTab === "movies"
                      ? "bg-netflix text-white shadow-md"
                      : "text-gray-300 hover:text-white hover:bg-gray-700"
                  }`}
                >
                  🎬 Películas
                </button>
                <button
                  onClick={() => setTopActiveTab("series")}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-all duration-200 font-maven ${
                    topActiveTab === "series"
                      ? "bg-netflix text-white shadow-md"
                      : "text-gray-300 hover:text-white hover:bg-gray-700"
                  }`}
                >
                  📺 Series
                </button>
              </div>

              {/* Contenido de las pestañas */}
              <div className="grid gap-2 max-h-40 overflow-hidden">
                {topActiveTab === "movies" && topContent.movies.length > 0 && (
                  <>
                    {topContent.movies.map((movie, index) => (
                      <TopCard key={movie.id} item={movie} rank={index + 1} />
                    ))}
                  </>
                )}
                {topActiveTab === "series" && topContent.series.length > 0 && (
                  <>
                    {topContent.series.map((series, index) => (
                      <TopCard key={series.id} item={series} rank={index + 1} />
                    ))}
                  </>
                )}
              </div>
            </section>
          )}

        {/* Tabs */}
        <div className="flex gap-1 mb-6 bg-gray-900 p-1 rounded-lg">
          <button
            onClick={() => setActiveTab("pending")}
            className={`flex-1 py-3 px-4 rounded-lg font-medium transition-all ${
              activeTab === "pending"
                ? "bg-red-600 text-white"
                : "text-gray-400 hover:text-white hover:bg-gray-800"
            }`}
          >
            📋 Pendientes ({content.length})
          </button>
          <button
            onClick={() => setActiveTab("watched")}
            className={`flex-1 py-3 px-4 rounded-lg font-medium transition-all ${
              activeTab === "watched"
                ? "bg-green-600 text-white"
                : "text-gray-400 hover:text-white hover:bg-gray-800"
            }`}
          >
            ✅ Vistas ({watchedContent.length})
          </button>
        </div>

        {/* Filters */}
        <div className="bg-gray-900 p-4 rounded-lg mb-6 border border-gray-800">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <select
              value={filters.type}
              onChange={(e) => setFilters({ ...filters, type: e.target.value })}
              className="bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-red-600 transition-colors"
            >
              <option value="">🎭 Todos los tipos</option>
              <option value="movie">🎬 Películas</option>
              <option value="series">📺 Series</option>
            </select>

            <select
              value={filters.platform}
              onChange={(e) =>
                setFilters({ ...filters, platform: e.target.value })
              }
              className="bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-red-600 transition-colors"
            >
              <option value="">📱 Todas las plataformas</option>
              {platforms.map((platform) => (
                <option key={platform.id} value={platform.id}>
                  {platform.icon} {platform.name}
                </option>
              ))}
            </select>

            <select
              value={filters.genre}
              onChange={(e) =>
                setFilters({ ...filters, genre: e.target.value })
              }
              className="bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-red-600 transition-colors"
            >
              <option value="">🎨 Todos los géneros</option>
              {genres.map((genre) => (
                <option key={genre.id} value={genre.name}>
                  {genre.icon} {genre.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Content Grid - Optimizado para móvil */}
        {filteredContent.length > 0 ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 sm:gap-4">
            {filteredContent.map((item) => (
              <ContentCard
                key={item.id}
                item={item}
                isWatched={activeTab === "watched"}
              />
            ))}
          </div>
        ) : (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">
              {activeTab === "pending" ? "🎬" : "✅"}
            </div>
            <h3 className="text-xl font-semibold mb-2">
              {activeTab === "pending"
                ? "No hay contenido pendiente"
                : "No has visto nada aún"}
            </h3>
            <p className="text-gray-400 mb-6">
              {activeTab === "pending"
                ? "Añade películas y series a tu lista para empezar"
                : "Marca algo como visto para que aparezca aquí"}
            </p>
            {activeTab === "pending" && (
              <button
                onClick={() => {
                  setEditingContent(null);
                  setNewContent({
                    title: "",
                    year: "",
                    type: "movie",
                    rating: "",
                    genres: [],
                    platform_id: "",
                  });
                  setShowAddModal(true);
                }}
                className="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg font-medium transition-colors"
              >
                Añadir tu primera película o serie
              </button>
            )}
          </div>
        )}
      </main>

      {/* Add/Edit Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-75 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-gray-900 rounded-lg border border-gray-800 shadow-2xl w-full max-w-md max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <h2 className="text-xl font-bold mb-4 text-white">
                {editingContent ? "Editar contenido" : "Añadir contenido"}
              </h2>

              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  if (editingContent) {
                    updateContent(editingContent.id, newContent);
                    setEditingContent(null);
                  } else {
                    addContent(newContent);
                  }
                  setShowAddModal(false);
                  setNewContent({
                    title: "",
                    year: "",
                    type: "movie",
                    rating: "",
                    genres: [],
                    platform_id: "",
                  });
                }}
              >
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-300">
                      Título *
                    </label>
                    <div className="flex gap-2">
                      <input
                        type="text"
                        value={newContent.title}
                        onChange={(e) =>
                          setNewContent({
                            ...newContent,
                            title: e.target.value,
                          })
                        }
                        className="flex-1 bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white placeholder-gray-500 focus:outline-none focus:border-red-600 transition-colors"
                        placeholder="Título de la película o serie"
                        required
                      />
                      <button
                        type="button"
                        onClick={async () => {
                          const data = await searchEnhancedAPI(
                            newContent.title,
                            newContent.year,
                            newContent.type
                          );
                          if (data) {
                            setNewContent({
                              ...newContent,
                              ...data,
                            });
                          }
                        }}
                        disabled={!newContent.title || searchLoading}
                        className="bg-green-600 hover:bg-green-700 disabled:bg-gray-600 px-3 py-2 rounded-lg transition-colors flex items-center gap-1"
                        title="Autocompletar información completa"
                      >
                        {searchLoading ? (
                          <Loader2 size={16} className="animate-spin" />
                        ) : (
                          <>
                            🔍<span className="hidden sm:inline">Auto</span>
                          </>
                        )}
                      </button>
                      <button
                        type="button"
                        onClick={async () => {
                          const rating = await searchMovieRating(
                            newContent.title,
                            newContent.year
                          );
                          if (rating) {
                            setNewContent({
                              ...newContent,
                              rating: rating,
                            });
                          }
                        }}
                        disabled={!newContent.title || searchLoading}
                        className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 px-3 py-2 rounded-lg transition-colors flex items-center"
                        title="Buscar rating IMDb automático"
                      >
                        {searchLoading ? (
                          <Loader2 size={16} className="animate-spin" />
                        ) : (
                          "⭐"
                        )}
                      </button>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium mb-2 text-gray-300">
                        Año
                      </label>
                      <input
                        type="number"
                        value={newContent.year}
                        onChange={(e) =>
                          setNewContent({ ...newContent, year: e.target.value })
                        }
                        className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white placeholder-gray-500 focus:outline-none focus:border-red-600 transition-colors"
                        min="1900"
                        max="2030"
                        placeholder="2024"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium mb-2 text-gray-300">
                        Tipo
                      </label>
                      <select
                        value={newContent.type}
                        onChange={(e) =>
                          setNewContent({ ...newContent, type: e.target.value })
                        }
                        className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-red-600 transition-colors"
                      >
                        <option value="movie">🎬 Película</option>
                        <option value="series">📺 Serie</option>
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-300">
                      Calificación IMDb
                    </label>
                    <input
                      type="number"
                      step="0.1"
                      min="0"
                      max="10"
                      value={newContent.rating}
                      onChange={(e) =>
                        setNewContent({ ...newContent, rating: e.target.value })
                      }
                      className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white placeholder-gray-500 focus:outline-none focus:border-red-600 transition-colors"
                      placeholder="8.5"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-300">
                      Plataforma
                    </label>
                    <select
                      value={newContent.platform_id}
                      onChange={(e) =>
                        setNewContent({
                          ...newContent,
                          platform_id: e.target.value,
                        })
                      }
                      className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-red-600 transition-colors"
                    >
                      <option value="">Seleccionar plataforma</option>
                      {platforms.map((platform) => (
                        <option key={platform.id} value={platform.id}>
                          {platform.icon} {platform.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-300">
                      Géneros
                    </label>
                    <div className="grid grid-cols-2 gap-2 max-h-40 overflow-y-auto bg-gray-800 border border-gray-700 rounded-lg p-3">
                      {genres.map((genre) => (
                        <label
                          key={genre.id}
                          className="flex items-center gap-2 text-sm cursor-pointer hover:bg-gray-700 p-1 rounded"
                        >
                          <input
                            type="checkbox"
                            checked={newContent.genres.includes(genre.name)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setNewContent({
                                  ...newContent,
                                  genres: [...newContent.genres, genre.name],
                                });
                              } else {
                                setNewContent({
                                  ...newContent,
                                  genres: newContent.genres.filter(
                                    (g) => g !== genre.name
                                  ),
                                });
                              }
                            }}
                            className="rounded text-red-600 focus:ring-red-600"
                          />
                          <span className="text-white">
                            {genre.icon} {genre.name}
                          </span>
                        </label>
                      ))}
                    </div>
                  </div>
                </div>

                <div className="flex gap-3 mt-6">
                  <button
                    type="submit"
                    className="flex-1 bg-red-600 hover:bg-red-700 py-3 rounded-lg font-medium text-white transition-colors"
                  >
                    {editingContent ? "Actualizar" : "Añadir"}
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setShowAddModal(false);
                      setEditingContent(null);
                      setNewContent({
                        title: "",
                        year: "",
                        type: "movie",
                        rating: "",
                        genres: [],
                        platform_id: "",
                      });
                    }}
                    className="flex-1 bg-gray-700 hover:bg-gray-600 py-3 rounded-lg font-medium text-white transition-colors"
                  >
                    Cancelar
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Profile Modal */}
      {showProfileModal && (
        <div className="fixed inset-0 bg-black bg-opacity-75 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-gray-900 rounded-lg border border-gray-800 shadow-2xl w-full max-w-sm">
            <div className="p-6">
              <h2 className="text-xl font-bold mb-4 text-white">
                Crear perfil
              </h2>

              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  const formData = new FormData(e.target);
                  createProfile(formData.get("name"), formData.get("emoji"));
                }}
              >
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-300">
                      Nombre *
                    </label>
                    <input
                      name="name"
                      type="text"
                      required
                      className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white placeholder-gray-500 focus:outline-none focus:border-red-600 transition-colors"
                      placeholder="Mi perfil"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-300">
                      Emoji
                    </label>
                    <input
                      name="emoji"
                      type="text"
                      maxLength="2"
                      className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white placeholder-gray-500 focus:outline-none focus:border-red-600 transition-colors"
                      placeholder="🎬"
                      defaultValue="🎬"
                    />
                  </div>
                </div>

                <div className="flex gap-3 mt-6">
                  <button
                    type="submit"
                    className="flex-1 bg-red-600 hover:bg-red-700 py-3 rounded-lg font-medium text-white transition-colors"
                  >
                    Crear
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowProfileModal(false)}
                    className="flex-1 bg-gray-700 hover:bg-gray-600 py-3 rounded-lg font-medium text-white transition-colors"
                  >
                    Cancelar
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Error Toast */}
      {error && (
        <div className="fixed bottom-4 left-4 bg-red-600 text-white px-4 py-3 rounded-lg shadow-lg z-50 flex items-center gap-2 max-w-md">
          <AlertCircle size={20} />
          <span className="flex-1">{error}</span>
          <button
            onClick={() => setError(null)}
            className="text-white hover:text-gray-200"
          >
            <X size={16} />
          </button>
        </div>
      )}

      {/* Botón volver arriba */}
      <ScrollToTopButton />
    </div>
  );
};

export default MovieManager;
