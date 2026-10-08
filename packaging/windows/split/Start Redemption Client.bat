@echo off
rem Start the REDEMPTION PokeVerse client (redemption-client\pokeverse-client.exe), built from
rem client-redemption. It connects to 127.0.0.1:7564. Its settings live in %APPDATA%\pokeverse,
rem separate from the legacy client's %USERPROFILE%\Pokecenter.
setlocal EnableDelayedExpansion
title PokeVerse REDEMPTION client
cd /d "%~dp0redemption-client" || goto :nofolder

set "MISSING="
for %%F in (pokeverse-client.exe VARIANT CLIENT init.lua data\images\background.png data\things\854\Tibia.dat data\things\854\Tibia.spr modules\client\client.otmod) do (
    if not exist "%%F" set "MISSING=!MISSING! %%F"
)
if defined MISSING (
    echo ERROR: the redemption-client folder is incomplete. Missing:!MISSING!
    echo Extract the whole PokeVerse package again.
    set "CODE=3"
    goto :end
)
set /p CLIENT=<CLIENT
if not "!CLIENT!"=="redemption" (
    echo ERROR: redemption-client\CLIENT is "!CLIENT!", not "redemption". This folder does not hold the Redemption client.
    set "CODE=3"
    goto :end
)
set /p VARIANT=<VARIANT
if not "!VARIANT!"=="production" (
    echo ERROR: redemption-client\VARIANT is "!VARIANT!". This launcher only starts the production Release build.
    set "CODE=3"
    goto :end
)
for %%A in (data\things\854\Tibia.spr) do if %%~zA LSS 1000000 (
    echo ERROR: redemption-client\data\things\854\Tibia.spr is only %%~zA bytes. It is a Git LFS placeholder, not the sprite file.
    set "CODE=3"
    goto :end
)

echo Starting the REDEMPTION client (pokeverse-client.exe). Log in with your account, or
echo player / player when the development accounts were installed.
start "PokeVerse REDEMPTION client" /D "%CD%" "%CD%\pokeverse-client.exe"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" echo ERROR: Windows could not start pokeverse-client.exe, code %CODE%.
if "%CODE%"=="0" if not defined POKEVERSE_NO_PAUSE exit /b 0
goto :end

:nofolder
echo ERROR: no redemption-client folder next to this file. Extract the whole PokeVerse package again.
set "CODE=3"

:end
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
