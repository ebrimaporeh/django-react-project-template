#!/usr/bin/env bash
set -euo pipefail

BOLD="\033[1m"; DIM="\033[2m"; GREEN="\033[0;32m"
YELLOW="\033[0;33m"; CYAN="\033[0;36m"; RED="\033[0;31m"; RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/.init-config"
PID_FILE="${SCRIPT_DIR}/.pids"
VENV_PY="${SCRIPT_DIR}/backend/venv/bin/python"

# ─── Load or ask for frontend choice ─────────────────────────────────────────
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo ""
  echo -e "${BOLD}Which frontend would you like to run?${RESET}"
  echo ""
  echo -e "  ${CYAN}[1]${RESET} JavaScript  ${DIM}(frontend-js, port 5173)${RESET}"
  echo -e "  ${CYAN}[2]${RESET} TypeScript  ${DIM}(frontend-ts, port 5174)${RESET}"
  echo ""
  while true; do
    read -rp "$(echo -e "  ${BOLD}Enter choice [1/2]:${RESET} ")" choice
    case "$choice" in
      1) FRONTEND_DIR="frontend-js"; FRONTEND_LABEL="JavaScript"; FRONTEND_PORT=5173; break ;;
      2) FRONTEND_DIR="frontend-ts"; FRONTEND_LABEL="TypeScript";  FRONTEND_PORT=5174; break ;;
      *) echo -e "  ${YELLOW}Please enter 1 or 2.${RESET}" ;;
    esac
  done
fi

# ─── Pre-flight checks ────────────────────────────────────────────────────────
if [ ! -f "$VENV_PY" ]; then
  echo -e "${RED}Backend not set up. Run ./init.sh first.${RESET}"
  exit 1
fi

if [ ! -d "${SCRIPT_DIR}/${FRONTEND_DIR}/node_modules" ]; then
  echo -e "${RED}${FRONTEND_DIR} not set up. Run ./init.sh first.${RESET}"
  exit 1
fi

if [ ! -f "${SCRIPT_DIR}/backend/.env" ]; then
  echo -e "${RED}backend/.env missing. Run ./init.sh first.${RESET}"
  exit 1
fi

# ─── Cleanup on exit ─────────────────────────────────────────────────────────
cleanup() {
  echo ""
  echo -e "${YELLOW}Shutting down servers...${RESET}"

  BACKEND_PID=$(sed -n '1p' "$PID_FILE" 2>/dev/null || true)
  FRONTEND_PID=$(sed -n '2p' "$PID_FILE" 2>/dev/null || true)

  [ -n "$BACKEND_PID" ]  && kill "$BACKEND_PID"  2>/dev/null || true
  [ -n "$FRONTEND_PID" ] && kill "$FRONTEND_PID" 2>/dev/null || true

  # Wait for process substitution subshells to drain and exit
  wait 2>/dev/null || true

  rm -f "$PID_FILE"
  echo -e "${GREEN}Done. Run ${BOLD}./start.sh${RESET}${GREEN} to restart.${RESET}"
  echo ""
  exit 0
}
trap cleanup INT TERM

# ─── Print URLs ───────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║              Dev Servers Running             ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${BOLD}Backend:${RESET}  ${CYAN}http://localhost:8000${RESET}"
echo -e "  ${BOLD}API Docs:${RESET} ${CYAN}http://localhost:8000/api/docs/${RESET}"
echo -e "  ${BOLD}Frontend:${RESET} ${CYAN}http://localhost:${FRONTEND_PORT}${RESET}  ${DIM}(React ${FRONTEND_LABEL})${RESET}"
echo ""
echo -e "  ${DIM}Ctrl+C to stop  ·  ./stop.sh from another terminal${RESET}"
echo ""

# ─── Start backend ────────────────────────────────────────────────────────────
# cd into backend/ so SQLite path (relative or absolute) always resolves correctly.
# Use process substitution (> >(...)) so $! captures Django's real PID,
# not a pipe process — this is what makes Ctrl+C reliable.
cd "${SCRIPT_DIR}/backend"
DJANGO_SETTINGS_MODULE=settings.development \
  "$VENV_PY" manage.py runserver \
  > >(while IFS= read -r line; do printf "  \033[2m[backend]\033[0m %s\n" "$line"; done) 2>&1 &
BACKEND_PID=$!
cd "${SCRIPT_DIR}"

sleep 1  # let Django bind its port before Vite starts

# ─── Start frontend ───────────────────────────────────────────────────────────
cd "${SCRIPT_DIR}/${FRONTEND_DIR}"
npm run dev \
  > >(while IFS= read -r line; do printf "  \033[2m[${FRONTEND_DIR}]\033[0m %s\n" "$line"; done) 2>&1 &
FRONTEND_PID=$!
cd "${SCRIPT_DIR}"

# ─── Save PIDs for stop.sh ────────────────────────────────────────────────────
printf "%s\n%s\n" "$BACKEND_PID" "$FRONTEND_PID" > "$PID_FILE"

# Wait — this blocks until both processes exit or cleanup() fires
wait "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
