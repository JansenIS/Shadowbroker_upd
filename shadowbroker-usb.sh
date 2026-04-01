#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================="
echo "  ShadowBroker USB Launcher (Linux)"
echo "============================================="

auto_open_browser() {
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "http://localhost:3939" >/dev/null 2>&1 || true
  fi
}

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
elif command -v podman >/dev/null 2>&1 && podman compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(podman compose)
elif command -v podman-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(podman-compose)
else
  echo "[!] No compose runtime found. Install Docker or Podman."
  exit 1
fi

echo "[*] Using: ${COMPOSE_CMD[*]}"
"${COMPOSE_CMD[@]}" -f "$SCRIPT_DIR/docker-compose.yml" up -d

echo "[*] Opening dashboard: http://localhost:3939"
auto_open_browser

echo "[*] Done. To stop, run: ${COMPOSE_CMD[*]} -f docker-compose.yml down"
