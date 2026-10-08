@echo off
rem Starts the local MariaDB server (127.0.0.1:3307) if it is not running yet,
rem then waits until it accepts connections.
setlocal
call "%~dp0env.bat"

call :ping && exit /b 0

if exist "%PV_DB_DATA%\mysql\" goto :start
echo The database has not been set up yet. Run "Setup Database.bat" first.
exit /b 1

:start
echo Starting the local database on 127.0.0.1:%PV_DB_PORT% ...
start "PokeVerse Database" /min "%PV_DB_BIN%\mariadbd.exe" --no-defaults "--datadir=%PV_DB_DATA%" --port=%PV_DB_PORT% --bind-address=127.0.0.1 "--log-error=%PV_DB_DATA%\mariadb.err"

for /l %%i in (1,1,60) do (
    call :ping && goto :running
    ping -n 2 127.0.0.1 >nul
)
echo The database did not start. See "%PV_DB_DATA%\mariadb.err".
exit /b 1

:running
echo The database is running.
exit /b 0

:ping
"%PV_DB_BIN%\mariadb-admin.exe" %PV_DB_ARGS% -uroot --connect-timeout=2 ping >nul 2>&1
exit /b %errorlevel%
