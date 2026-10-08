@echo off
rem Cleanly stops the local database. Stop the server first.
setlocal
call "%~dp0tools\env.bat"
"%PV_DB_BIN%\mariadb-admin.exe" %PV_DB_ARGS% -uroot shutdown && echo The database has stopped.
if not defined PV_NO_PAUSE pause
