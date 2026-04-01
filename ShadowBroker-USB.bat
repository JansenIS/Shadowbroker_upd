@echo off
setlocal
cd /d "%~dp0"
title ShadowBroker USB Launcher

echo =============================================
echo   ShadowBroker USB Launcher (Windows)
echo =============================================
echo.

set COMPOSE_CMD=

docker compose version >nul 2>&1
if %errorlevel%==0 set COMPOSE_CMD=docker compose

if not defined COMPOSE_CMD (
  docker-compose version >nul 2>&1
  if %errorlevel%==0 set COMPOSE_CMD=docker-compose
)

if not defined COMPOSE_CMD (
  echo [!] Docker Compose not found.
  echo [!] Install Docker Desktop and try again.
  pause
  exit /b 1
)

echo [*] Using: %COMPOSE_CMD%
echo [*] Starting containers...
%COMPOSE_CMD% -f docker-compose.yml up -d
if %errorlevel% neq 0 (
  echo [!] Failed to start containers.
  pause
  exit /b 1
)

echo [*] Opening dashboard: http://localhost:3939
start "" "http://localhost:3939"

echo.
echo [*] Done. To stop, run:
echo     %COMPOSE_CMD% -f docker-compose.yml down
echo.
pause
