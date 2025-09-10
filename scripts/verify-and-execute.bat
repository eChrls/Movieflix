@echo off
REM ========================================
REM MOVIEFLIX - SCRIPT DE VERIFICACIÓN PREVIA (Windows)
REM ========================================
REM Este script verifica el estado de la base de datos antes de ejecutar cambios

setlocal EnableDelayedExpansion

REM Configuración
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..
set DATE_TIME=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set DATE_TIME=%DATE_TIME: =0%

echo =========================================
echo MovieFlix - Verificacion Previa Windows
echo =========================================
echo.

REM Cargar variables de entorno desde .env si existe
if exist "%PROJECT_DIR%\.env" (
    echo [INFO] Cargando variables de entorno desde .env...
    for /f "tokens=1,2 delims==" %%a in ('type "%PROJECT_DIR%\.env" ^| findstr /v "^#"') do (
        set %%a=%%b
    )
    echo [SUCCESS] Variables de entorno cargadas
) else (
    echo [WARNING] Archivo .env no encontrado, usando valores por defecto
    set DB_HOST=localhost
    set DB_NAME=movieflix_db
    set DB_USER=movieflix_user
    set DB_PASSWORD=movieflix_password_2025
)

echo.
echo Configuracion actual:
echo   Host: %DB_HOST%
echo   Base de datos: %DB_NAME%
echo   Usuario: %DB_USER%
echo.

REM Verificar si mysql está disponible
echo [INFO] Verificando disponibilidad de MySQL...
mysql --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] MySQL client no esta disponible
    echo [ERROR] Instala MySQL o agrega mysql.exe al PATH
    pause
    exit /b 1
)
echo [SUCCESS] MySQL client disponible

REM Verificar conexión a la base de datos
echo [INFO] Verificando conexion a la base de datos...
mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -e "USE %DB_NAME%; SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No se puede conectar a la base de datos
    echo [ERROR] Verifica:
    echo   - Que MySQL Server este ejecutandose
    echo   - Las credenciales en el archivo .env
    echo   - Que la base de datos %DB_NAME% exista
    pause
    exit /b 1
)
echo [SUCCESS] Conexion a la base de datos exitosa

REM Obtener estado actual
echo [INFO] Obteniendo estado actual de la base de datos...

for /f %%i in ('mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -se "SELECT COUNT(*) FROM content;"') do set CONTENT_COUNT=%%i
for /f %%i in ('mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -se "SELECT COUNT(*) FROM platforms;"') do set PLATFORM_COUNT=%%i
for /f %%i in ('mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -se "SELECT COUNT(*) FROM profiles;"') do set PROFILE_COUNT=%%i

echo.
echo Estado actual de la base de datos:
echo   - Contenido total: %CONTENT_COUNT% registros
echo   - Plataformas: %PLATFORM_COUNT% registros
echo   - Perfiles: %PROFILE_COUNT% registros
echo.

REM Verificar estructura de tablas críticas
echo [INFO] Verificando estructura de tablas...

REM Verificar tabla content
mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -e "DESCRIBE content;" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Tabla 'content' no existe o no es accesible
    pause
    exit /b 1
)

REM Verificar tabla platforms
mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -e "DESCRIBE platforms;" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Tabla 'platforms' no existe o no es accesible
    pause
    exit /b 1
)

REM Verificar tabla profiles
mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -e "DESCRIBE profiles;" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Tabla 'profiles' no existe o no es accesible
    pause
    exit /b 1
)

echo [SUCCESS] Estructura de tablas verificada

REM Verificar perfil Home
for /f %%i in ('mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -se "SELECT COUNT(*) FROM profiles WHERE name='Home';"') do set HOME_PROFILE_COUNT=%%i

if "%HOME_PROFILE_COUNT%"=="0" (
    echo [ERROR] Perfil 'Home' no encontrado
    echo [ERROR] El script requiere que exista un perfil llamado 'Home'
    pause
    exit /b 1
)
echo [SUCCESS] Perfil 'Home' encontrado

REM Mostrar plataformas disponibles
echo.
echo Plataformas disponibles:
mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -e "SELECT id, name FROM platforms ORDER BY name;"

REM Verificar contenido potencialmente duplicado
echo.
echo [INFO] Verificando contenido que podria ser duplicado...

REM Crear archivo temporal con títulos a insertar
echo The Pitt > temp_titles.txt
echo When They See Us >> temp_titles.txt
echo La Maravillosa Sra. Maisel >> temp_titles.txt
echo This Is Us >> temp_titles.txt
echo Dopesick >> temp_titles.txt
echo The Expanse >> temp_titles.txt
echo Billions >> temp_titles.txt
echo High Maintenance >> temp_titles.txt
echo Wild Wild Country >> temp_titles.txt
echo Tokyo Vice >> temp_titles.txt
echo The Morning Show >> temp_titles.txt
echo Slow Horses >> temp_titles.txt
echo El Hombre que Mató a Liberty Valance >> temp_titles.txt
echo Centauros del Desierto >> temp_titles.txt
echo Solo Ante el Peligro >> temp_titles.txt
echo Perfect Blue >> temp_titles.txt
echo Castle in the Sky >> temp_titles.txt
echo The Tale of the Princess Kaguya >> temp_titles.txt
echo Porco Rosso >> temp_titles.txt
echo Doctor Zhivago >> temp_titles.txt
echo Trece Vidas >> temp_titles.txt
echo La Cinta Blanca >> temp_titles.txt
echo The Florida Project >> temp_titles.txt
echo Contratiempo >> temp_titles.txt
echo Cría Cuervos >> temp_titles.txt
echo Que Dios Nos Perdone >> temp_titles.txt
echo Tetris >> temp_titles.txt
echo First Blood >> temp_titles.txt
echo Dredd >> temp_titles.txt
echo Coherence >> temp_titles.txt
echo La Hora del Diablo >> temp_titles.txt

set DUPLICATE_COUNT=0
for /f "delims=" %%i in (temp_titles.txt) do (
    for /f %%j in ('mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -se "SELECT COUNT(*) FROM content WHERE LOWER(TRIM(title)) = LOWER(TRIM('%%i'));"') do (
        if not %%j==0 (
            echo [WARNING] Ya existe contenido similar: %%i
            set /a DUPLICATE_COUNT+=1
        )
    )
)

del temp_titles.txt >nul 2>&1

echo.
if %DUPLICATE_COUNT%==0 (
    echo [SUCCESS] No se detectaron duplicados
) else (
    echo [WARNING] Se detectaron %DUPLICATE_COUNT% posibles duplicados
    echo [INFO] El script SQL verificara y evitara insertar duplicados
)

REM Verificar espacio en disco
echo.
echo [INFO] Verificando espacio en disco...
for /f "tokens=3" %%i in ('dir "%PROJECT_DIR%" ^| find "bytes free"') do set FREE_SPACE=%%i
echo [INFO] Espacio libre: %FREE_SPACE% bytes

REM Mostrar resumen y recomendaciones
echo.
echo =========================================
echo RESUMEN DE VERIFICACION
echo =========================================
echo.
echo [SUCCESS] Verificacion completada exitosamente
echo.
echo Estado actual:
echo   - Base de datos: %DB_NAME% [OK]
echo   - Contenido: %CONTENT_COUNT% registros
echo   - Plataformas: %PLATFORM_COUNT% registros
echo   - Perfil Home: Disponible [OK]
echo   - Posibles duplicados: %DUPLICATE_COUNT%
echo.
echo Recomendaciones antes de ejecutar:
echo   1. Hacer backup de la base de datos
echo   2. Cerrar la aplicacion si esta ejecutandose
echo   3. Verificar que tienes permisos de escritura
echo.
echo Comandos para ejecutar el script:
echo   OPCION 1 - Script SQL directo:
echo     mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% ^< scripts\add-missing-content-safe.sql
echo.
echo   OPCION 2 - Con backup automatico (recomendado):
echo     bash scripts\safe-execute.sh
echo.
echo =========================================

REM Preguntar si desea continuar
echo.
set /p CONTINUE="¿Deseas continuar con la ejecucion? (S/N): "
if /i "%CONTINUE%"=="S" (
    echo.
    echo [INFO] Procediendo con la ejecucion...
    echo [INFO] Ejecutando script SQL...

    REM Ejecutar el script SQL
    mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% < "%SCRIPT_DIR%add-missing-content-safe.sql"

    if errorlevel 1 (
        echo [ERROR] Error al ejecutar el script SQL
        pause
        exit /b 1
    )

    echo [SUCCESS] Script ejecutado exitosamente

    REM Mostrar nuevos totales
    for /f %%i in ('mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -D%DB_NAME% -se "SELECT COUNT(*) FROM content;"') do set NEW_CONTENT_COUNT=%%i
    set /a ADDED_CONTENT=%NEW_CONTENT_COUNT%-%CONTENT_COUNT%

    echo.
    echo Resultados:
    echo   - Contenido anterior: %CONTENT_COUNT%
    echo   - Contenido actual: %NEW_CONTENT_COUNT%
    echo   - Contenido agregado: %ADDED_CONTENT%
    echo.
    echo [SUCCESS] Proceso completado exitosamente
) else (
    echo [INFO] Ejecucion cancelada por el usuario
)

echo.
pause
