#!/usr/bin/env bash

GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RED="\033[0;31m"
DIM="\033[2m"; BOLD="\033[1m"; RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${SCRIPT_DIR}/.pids"

echo ""

if [ ! -f "$PID_FILE" ]; then
  echo -e "${YELLOW}No .pids file found — servers may not be running, or were started outside start.sh.${RESET}"
  echo ""
  echo -e "${DIM}Attempting pkill fallback...${RESET}"
  pkill -f "manage.py runserver" 2>/dev/null && echo -e "  ${GREEN}✓  Stopped Django${RESET}" || echo -e "  ${DIM}Django was not running${RESET}"
  pkill -f "vite"                2>/dev/null && echo -e "  ${GREEN}✓  Stopped Vite${RESET}"   || echo -e "  ${DIM}Vite was not running${RESET}"
  echo ""
  exit 0
fi

echo -e "${BOLD}Stopping servers...${RESET}"

BACKEND_PID=$(sed -n '1p' "$PID_FILE")
FRONTEND_PID=$(sed -n '2p' "$PID_FILE")

stop_pid() {
  local pid="$1" name="$2"
  if [ -z "$pid" ]; then return; fi
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null && echo -e "  ${GREEN}✓  Stopped ${name} (pid ${pid})${RESET}"
  else
    echo -e "  ${DIM}${name} (pid ${pid}) was already stopped${RESET}"
  fi
}

stop_pid "$BACKEND_PID"  "backend"
stop_pid "$FRONTEND_PID" "frontend"

rm -f "$PID_FILE"

echo ""
echo -e "${GREEN}Done. Run ${BOLD}./start.sh${RESET}${GREEN} to start again.${RESET}"
echo ""
