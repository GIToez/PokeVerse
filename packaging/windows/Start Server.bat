@echo off
rem Start server\pokeverse-server.exe in this console. The window stays open and shows the exit code.
setlocal EnableDelayedExpansion
title PokeVerse Server
cd /d "%~dp0server" || goto :nofolder

set "MISSING="
if not exist "pokeverse-server.exe" set "MISSING=!MISSING! pokeverse-server.exe"
if not exist "required-dlls.txt" set "MISSING=!MISSING! required-dlls.txt"
if exist "required-dlls.txt" (
    for /f "usebackq delims=" %%D in ("required-dlls.txt") do if not exist "%%D" set "MISSING=!MISSING! %%D"
)
for %%F in (config.lua data\world\map.otbm data\items\items.otb data\XML\vocations.xml pt_br.loc) do (
    if not exist "%%F" set "MISSING=!MISSING! %%F"
)
if defined MISSING (
    echo ERROR: the server folder is incomplete. Missing:!MISSING!
    echo Extract the whole PokeVerse package again.
    set "CODE=3"
    goto :end
)

for %%L in (logs logs\server logs\chat logs\bots logs\talkactions) do if not exist "%%L" mkdir "%%L"

if not defined POKEVERSE_SKIP_DB_CHECK (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1" -Action Verify
    if errorlevel 1 (
        echo ERROR: the database in server\config.lua is not ready. Run "Setup Database.bat" first.
        set "CODE=5"
        goto :end
    )
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1" -Action PortFree -Port 7564
if errorlevel 1 (
    echo ERROR: port 7564 is in use. Close the other PokeVerse server first.
    set "CODE=4"
    goto :end
)

echo Starting pokeverse-server.exe in %CD%
echo Loading takes a while. The server is ready when it prints "server Online!".
echo Stop it with /shutdown as GM Admin in game, Ctrl+C, or by closing this window (all of them save first).
echo.
pokeverse-server.exe
set "CODE=%ERRORLEVEL%"
echo.
echo pokeverse-server.exe exited with code %CODE%.
if not "%CODE%"=="0" echo Read the lines above for the reason, and the files in server\logs.
goto :end

:nofolder
echo ERROR: no server folder next to this file. Extract the whole PokeVerse package again.
set "CODE=3"

:end
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
