@echo off
rem Start the LEGACY PokeVerse client (legacy-client\pokeverse-legacy-client.exe): the original
rem PokeJornadas/PokeVerse interface, compiled from client\source. It connects to 127.0.0.1:7564.
rem Its settings live in %USERPROFILE%\Pokecenter, separate from the Redemption client's.
setlocal EnableDelayedExpansion
title PokeVerse LEGACY client
cd /d "%~dp0legacy-client" || goto :nofolder

set "MISSING="
for %%F in (pokeverse-legacy-client.exe libotc_framework.dll required-dlls.txt VARIANT CLIENT init.lua data\things\Tibia.dat data\things\Tibia.spr modules\client\client.otmod modules\game_pokebar\pokebar.otmod) do (
    if not exist "%%F" set "MISSING=!MISSING! %%F"
)
if exist "required-dlls.txt" (
    for /f "usebackq delims=" %%D in ("required-dlls.txt") do if not exist "%%D" set "MISSING=!MISSING! %%D"
)
if defined MISSING (
    echo ERROR: the legacy-client folder is incomplete. Missing:!MISSING!
    echo Extract the whole PokeVerse package again.
    set "CODE=3"
    goto :end
)
set /p CLIENT=<CLIENT
if not "!CLIENT!"=="legacy" (
    echo ERROR: legacy-client\CLIENT is "!CLIENT!", not "legacy". This folder does not hold the legacy client.
    set "CODE=3"
    goto :end
)
set /p VARIANT=<VARIANT
if not "!VARIANT!"=="production" (
    echo ERROR: legacy-client\VARIANT is "!VARIANT!". This launcher only starts the production build.
    set "CODE=3"
    goto :end
)
for %%A in (data\things\Tibia.spr) do if %%~zA LSS 1000000 (
    echo ERROR: legacy-client\data\things\Tibia.spr is only %%~zA bytes. It is a Git LFS placeholder, not the sprite file.
    set "CODE=3"
    goto :end
)
if exist "opengl32.dll" (
    echo ERROR: legacy-client\opengl32.dll must not be there; the legacy client refuses to start next to it.
    echo Delete it and update the graphics driver instead.
    set "CODE=3"
    goto :end
)

echo Starting the LEGACY client (pokeverse-legacy-client.exe). Log in with your account, or
echo player / player when the development accounts were installed.
start "PokeVerse LEGACY client" /D "%CD%" "%CD%\pokeverse-legacy-client.exe"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" echo ERROR: Windows could not start pokeverse-legacy-client.exe, code %CODE%.
if "%CODE%"=="0" if not defined POKEVERSE_NO_PAUSE exit /b 0
goto :end

:nofolder
echo ERROR: no legacy-client folder next to this file. Extract the whole PokeVerse package again.
set "CODE=3"

:end
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
