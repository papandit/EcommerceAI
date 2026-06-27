@echo off
REM ── Start all three e-com servers in their own windows ──────────────────
REM Backend (Node/Express + MongoDB)  -> http://localhost:4000
REM Storefront (release web build)     -> http://localhost:8080
REM Admin panel (release web build)    -> http://localhost:8081
REM
REM Requires: MongoDB running, and the web apps already built
REM (run build-apps.bat once, or "flutter build web --release" in user/ and admin/).

set ROOT=%~dp0

start "E-com Backend :4000" cmd /k "cd /d %ROOT%admin\server && node src\server.js"
start "Storefront :8080"    cmd /k "node %ROOT%serve.js %ROOT%user\build\web 8080"
start "Admin :8081"         cmd /k "node %ROOT%serve.js %ROOT%admin\build\web 8081"

echo.
echo Started 3 windows:
echo   Backend     http://localhost:4000
echo   Storefront  http://localhost:8080
echo   Admin       http://localhost:8081
echo.
echo Close those windows to stop the servers.
