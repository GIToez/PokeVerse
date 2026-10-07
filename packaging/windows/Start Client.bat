@echo off
rem Start the Release client (client\pokeverse-client.exe). It connects to the server at 127.0.0.1:7564.
setlocal EnableDelayedExpansion
cd /d "%~dp0client" || goto :nofolder

set "MISSING="
for %%F in (pokeverse-client.exe VARIANT init.lua data\things\854\Tibia.dat data\things\854\Tibia.spr modules\client\client.otmod) do (
    if not exist "%%F" set "MISSING=!MISSING! %%F"
)
if defined MISSING (
    echo ERROR: the client folder is incomplete. Missing:!MISSING!
    echo Extract the whole PokeVerse package again.
    set "CODE=3"
    goto :end
)
set /p VARIANT=<VARIANT
if not "!VARIANT!"=="production" (
    echo ERROR: client\VARIANT is "!VARIANT!". This launcher only starts the production Release client.
    set "CODE=3"
    goto :end
)
for %%A in (data\things\854\Tibia.spr) do if %%~zA LSS 1000000 (
    echo ERROR: client\data\things\854\Tibia.spr is only %%~zA bytes. It is a Git LFS placeholder, not the sprite file.
    set "CODE=3"
    goto :end
)

echo Starting pokeverse-client.exe. Log in with the account you created, or player / player
echo when the development accounts were installed.
start "PokeVerse" /D "%CD%" "%CD%\pokeverse-client.exe"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" echo ERROR: Windows could not start pokeverse-client.exe, code %CODE%.
if "%CODE%"=="0" if not defined POKEVERSE_NO_PAUSE exit /b 0
goto :end

:nofolder
echo ERROR: no client folder next to this file. Extract the whole PokeVerse package again.
set "CODE=3"

:end
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
