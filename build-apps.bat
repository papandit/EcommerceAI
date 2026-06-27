@echo off
REM ── Rebuild both Flutter web apps (release) ─────────────────────────────
REM Run this after changing app code, then start-servers.bat to serve them.
REM Tip: stop the running servers first so the build can overwrite main.dart.js.

set ROOT=%~dp0

echo Building storefront (user)...
cd /d %ROOT%user
call flutter build web --release

echo.
echo Building admin panel...
cd /d %ROOT%admin
call flutter build web --release

echo.
echo Both builds complete.
pause
