/**
 * 🎭 MovieFlix Demo Notice Component
 * Banner informativo para modo demostración
 *
 * Características:
 * - Dismissible (se puede cerrar)
 * - Solo aparece en modo demo
 * - Información clara sobre limitaciones
 * - Diseño atractivo y profesional
 */

import React, { useState, useEffect } from "react";

const DemoNotice = () => {
  const [dismissed, setDismissed] = useState(false);
  const [isDemoMode, setIsDemoMode] = useState(false);

  useEffect(() => {
    // Verificar si estamos en modo demo
    const checkDemoMode = async () => {
      try {
        const response = await fetch("/api/health");
        const data = await response.json();
        setIsDemoMode(data.mode === "DEMO");
      } catch (error) {
        console.log("No se pudo verificar el modo demo");
      }
    };

    checkDemoMode();
  }, []);

  // No mostrar si fue cerrado o no estamos en modo demo
  if (dismissed || !isDemoMode) return null;

  return (
    <div className="bg-gradient-to-r from-blue-600 via-purple-600 to-indigo-600 text-white shadow-lg relative z-50">
      {/* Botón cerrar */}
      <button
        onClick={() => setDismissed(true)}
        className="absolute right-4 top-4 text-white/80 hover:text-white hover:bg-white/20 rounded-full p-2 transition-all duration-200 z-10"
        aria-label="Cerrar banner demo"
        title="Cerrar banner"
      >
        <svg
          className="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </button>

      {/* Contenido del banner */}
      <div className="max-w-6xl mx-auto px-6 py-4">
        <div className="flex items-center justify-center gap-4 flex-wrap">
          {/* Icono principal */}
          <div className="flex-shrink-0">
            <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
              <span className="text-2xl">🎭</span>
            </div>
          </div>

          {/* Contenido principal */}
          <div className="flex-1 min-w-0">
            <h3 className="font-bold text-lg sm:text-xl font-maven flex items-center gap-2">
              🎬 Demo Interactivo de MovieFlix
              <span className="px-2 py-1 bg-white/20 rounded-full text-xs font-normal">
                PORTFOLIO
              </span>
            </h3>

            <p className="text-sm sm:text-base text-white/90 mt-1 font-maven">
              Esta es una <strong>demostración completa</strong> con
              funcionalidad real. Puedes agregar, editar y eliminar contenido
              libremente.
            </p>

            {/* Características demo */}
            <div className="flex flex-wrap gap-4 mt-2 text-xs sm:text-sm">
              <div className="flex items-center gap-1">
                <span className="w-2 h-2 bg-green-400 rounded-full"></span>
                <span>Datos simulados</span>
              </div>
              <div className="flex items-center gap-1">
                <span className="w-2 h-2 bg-blue-400 rounded-full"></span>
                <span>Funcionalidad completa</span>
              </div>
              <div className="flex items-center gap-1">
                <span className="w-2 h-2 bg-purple-400 rounded-full"></span>
                <span>Sin registro requerido</span>
              </div>
              <div className="flex items-center gap-1">
                <span className="w-2 h-2 bg-yellow-400 rounded-full"></span>
                <span>Los cambios no se guardan</span>
              </div>
            </div>
          </div>

          {/* Call to action */}
          <div className="flex-shrink-0">
            <div className="bg-white/20 backdrop-blur-sm rounded-lg p-3 text-center">
              <p className="text-xs font-semibold">¿Te gusta?</p>
              <p className="text-xs text-white/80">
                Código disponible en GitHub
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Efecto de brillo animado */}
      <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent animate-pulse opacity-50"></div>
    </div>
  );
};

export default DemoNotice;
