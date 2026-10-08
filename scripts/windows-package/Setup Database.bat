@echo off
rem Creates (or updates) the local PokeVerse development database.
rem Safe to run again: existing accounts and characters are kept.
setlocal
title PokeVerse - Setup Database
call "%~dp0tools\env.bat"

echo ============================================
echo  PokeVerse - development database setup
echo ============================================
echo.

if exist "%PV_DB_DATA%\mysql\" goto :have_data
echo Creating a new local database folder ...
"%PV_DB_BIN%\mariadb-install-db.exe" "--datadir=%PV_DB_DATA%" --port=%PV_DB_PORT% || goto :failed

:have_data
call "%~dp0tools\start-database.bat" || goto :failed

echo Creating the database and its user ...
"%PV_DB%" %PV_DB_ARGS% -uroot < "%PV_DB_SQL%\00-create-database.sql" || goto :failed

"%PV_DB%" %PV_DB_ARGS% -upokeverse -ppokeverse pokeverse -e "SELECT 1 FROM accounts LIMIT 1" >nul 2>&1 && goto :have_schema
echo Creating the game tables ...
"%PV_DB%" %PV_DB_ARGS% -upokeverse -ppokeverse pokeverse < "%PV_DB_SQL%\01-base-schema.sql" || goto :failed

:have_schema
echo Updating PokeVerse tables, defaults and development accounts ...
for %%f in (10-pokeverse-extensions.sql 20-world-defaults.sql 30-account-tools.sql 40-dev-seed.sql) do (
    "%PV_DB%" %PV_DB_ARGS% -upokeverse -ppokeverse pokeverse < "%PV_DB_SQL%\%%f" || goto :failed
)

echo.
echo Database ready on 127.0.0.1:%PV_DB_PORT%.
echo.
echo Test accounts:
echo   account: test    password: test    character: Trainer
echo   account: admin   password: admin   character: Admin (game master)
echo.
echo Next: run "Start Server and Client.bat".
if not defined PV_NO_PAUSE pause
exit /b 0

:failed
echo.
echo SETUP FAILED - see the messages above.
if not defined PV_NO_PAUSE pause
exit /b 1
