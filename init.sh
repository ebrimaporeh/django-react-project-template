#!/usr/bin/env bash
set -euo pipefail

BOLD="\033[1m"; DIM="\033[2m"; GREEN="\033[0;32m"
YELLOW="\033[0;33m"; CYAN="\033[0;36m"; RED="\033[0;31m"; RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/.init-config"

print_banner() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${CYAN}║       Production-Ready Starter Template      ║${RESET}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${RESET}"
  echo ""
}

step()    { echo -e "\n${BOLD}${GREEN}▸ $1${RESET}"; }
info()    { echo -e "  ${DIM}$1${RESET}"; }
success() { echo -e "  ${GREEN}✓  $1${RESET}"; }
error()   { echo -e "  ${RED}✗  $1${RESET}"; exit 1; }

# ─── Prerequisites ────────────────────────────────────────────────────────────
check_prerequisites() {
  step "Checking prerequisites"
  command -v python3 &>/dev/null || error "Python 3 not found. Install from https://python.org"
  success "Python 3: $(python3 --version)"
  command -v node &>/dev/null || error "Node.js not found. Install from https://nodejs.org"
  success "Node.js: $(node --version)"
  command -v npm &>/dev/null || error "npm not found"
  success "npm: $(npm --version)"
  command -v git &>/dev/null || error "git not found. Install git."
  success "git: $(git --version)"
}

# ─── Frontend choice ──────────────────────────────────────────────────────────
choose_frontend() {
  echo ""
  echo -e "${BOLD}Which frontend would you like to set up?${RESET}"
  echo ""
  echo -e "  ${CYAN}[1]${RESET} ${BOLD}JavaScript${RESET}  ${DIM}(React 19 + Vite + JSX)${RESET}"
  echo -e "  ${CYAN}[2]${RESET} ${BOLD}TypeScript${RESET}  ${DIM}(React 19 + Vite + TSX, strict mode)${RESET}"
  echo ""
  while true; do
    read -rp "$(echo -e "  ${BOLD}Enter choice [1/2]:${RESET} ")" choice
    case "$choice" in
      1) FRONTEND_DIR="frontend-js"; FRONTEND_LABEL="JavaScript"; FRONTEND_PORT=5173; break ;;
      2) FRONTEND_DIR="frontend-ts"; FRONTEND_LABEL="TypeScript";  FRONTEND_PORT=5174; break ;;
      *) echo -e "  ${YELLOW}Please enter 1 or 2.${RESET}" ;;
    esac
  done
  echo ""
  success "Selected: ${FRONTEND_LABEL} frontend (${FRONTEND_DIR}/)"

  # Persist choice so start.sh can pick it up without asking again
  cat > "$CONFIG_FILE" <<EOF
FRONTEND_DIR=${FRONTEND_DIR}
FRONTEND_LABEL=${FRONTEND_LABEL}
FRONTEND_PORT=${FRONTEND_PORT}
EOF
}

# ─── Backend setup ────────────────────────────────────────────────────────────
setup_backend() {
  step "Setting up backend"
  cd "${SCRIPT_DIR}/backend"

  if [ ! -d "venv" ]; then
    info "Creating virtual environment..."
    python3 -m venv venv
    success "Virtual environment created"
  else
    info "Virtual environment already exists, skipping"
  fi

  local PY="${SCRIPT_DIR}/backend/venv/bin/python"
  local PIP="${SCRIPT_DIR}/backend/venv/bin/pip"

  info "Installing Python dependencies..."
  "${PIP}" install --quiet --upgrade pip
  "${PIP}" install --quiet -r requirements.txt
  success "Python dependencies installed"

  if [ ! -f ".env" ]; then
    cp .env.example .env
    local KEY BACKEND_ABS
    KEY=$("${PY}" -c "import secrets,string; print(''.join(secrets.choice(string.ascii_letters+string.digits+'!@#\$%^&*') for _ in range(50)))")
    BACKEND_ABS="${SCRIPT_DIR}/backend"
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s/your-super-secret-key-change-this-in-production/${KEY}/" .env
    else
      sed -i "s/your-super-secret-key-change-this-in-production/${KEY}/" .env
    fi
    # Write absolute SQLite path so the DB resolves correctly regardless of cwd
    printf "\nDATABASE_URL=sqlite:///%s/db.sqlite3\n" "${BACKEND_ABS}" >> .env
    success ".env created with generated SECRET_KEY and absolute DATABASE_URL"
  else
    info ".env already exists, skipping"
  fi

  info "Creating any missing migrations..."
  DJANGO_SETTINGS_MODULE=settings.development "${PY}" manage.py makemigrations --no-input 2>/dev/null || true

  info "Running database migrations..."
  DJANGO_SETTINGS_MODULE=settings.development "${PY}" manage.py migrate --no-input
  success "Migrations applied"

  info "Seeding database with demo data..."
  DJANGO_SETTINGS_MODULE=settings.development "${PY}" manage.py seed_data
  success "Database seeded"

  cd "${SCRIPT_DIR}"
}

# ─── Frontend setup ───────────────────────────────────────────────────────────
setup_frontend() {
  step "Setting up ${FRONTEND_LABEL} frontend (${FRONTEND_DIR}/)"
  cd "${SCRIPT_DIR}/${FRONTEND_DIR}"

  if [ ! -f ".env" ]; then
    cp .env.example .env
    success ".env created"
  else
    info ".env already exists, skipping"
  fi

  info "Installing npm dependencies (this may take a minute)..."
  npm install --silent
  success "npm dependencies installed"

  cd "${SCRIPT_DIR}"
}

# ─── Git init ────────────────────────────────────────────────────────────────
init_git() {
  step "Initializing git repositories"

  for dir in backend frontend-js frontend-ts; do
    cd "${SCRIPT_DIR}/${dir}"
    if [ ! -d ".git" ]; then
      info "git init: ${dir}/"
      git init -q
      git add -A
      git commit -q -m "chore: initial commit"
      success "git initialized: ${dir}/"
    else
      info "git already initialized: ${dir}/, skipping"
    fi
    cd "${SCRIPT_DIR}"
  done
}

# ─── Seed info ────────────────────────────────────────────────────────────────
print_seed_info() {
  echo ""
  echo -e "${BOLD}${CYAN}─── Demo Accounts ──────────────────────────────────${RESET}"
  echo -e "  ${BOLD}Admin${RESET}    admin@example.com    ${DIM}Admin@1234${RESET}"
  echo -e "  ${BOLD}Premium${RESET}  premium@example.com  ${DIM}Premium@1234${RESET}"
  echo -e "  ${BOLD}User${RESET}     user@example.com     ${DIM}User@1234${RESET}"
  echo -e "${CYAN}────────────────────────────────────────────────────${RESET}"
  echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  print_banner
  check_prerequisites
  choose_frontend
  setup_backend
  setup_frontend
  init_git
  print_seed_info

  echo ""
  read -rp "$(echo -e "${BOLD}Setup complete. Start both servers now? [Y/n]: ${RESET}")" start_now
  echo ""

  if [[ "${start_now:-Y}" =~ ^[Yy]$ ]] || [[ -z "${start_now}" ]]; then
    exec "${SCRIPT_DIR}/start.sh"
  else
    echo -e "${DIM}To start later:${RESET}  ${CYAN}./start.sh${RESET}"
    echo -e "${DIM}To stop:${RESET}         ${CYAN}./stop.sh${RESET}"
    echo ""
  fi
}

main
