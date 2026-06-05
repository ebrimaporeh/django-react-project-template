# Project Template — AI Operating Instructions

## Project Overview

This is a production-ready SaaS/application starter template with:
- `backend/` — Django 4.2 + Django REST Framework
- `frontend-js/` — React 19 + Vite (JavaScript)
- `frontend-ts/` — React 19 + Vite (TypeScript)

Each sub-project has its own `.claude/` folder with domain-specific rules.

## Architecture Docs

Read these files before making changes:

- `.claude/architecture.md` — System architecture and data flow
- `.claude/backend-rules.md` — Backend coding rules
- `.claude/frontend-rules.md` — Frontend coding rules
- `.claude/security-rules.md` — Security requirements
- `.claude/coding-standards.md` — Code style conventions
- `.claude/services-pattern.md` — Services layer pattern
- `.claude/api-pattern.md` — API layer pattern

## General Rules

1. Read relevant `.claude/` docs before modifying code.
2. Never place business logic in views or components — use services/hooks.
3. Never hardcode secrets — use `.env` files.
4. Always follow the feature-based folder structure.
5. All API calls must go through the `src/api/` layer.
6. Settings must be environment-variable driven.
7. Run migrations after any model change.
8. Use the established serializer/hook pattern for new features.

## Development Workflow

### First-time setup (one command)
```bash
./init.sh
```
Interactive — asks JS or TS, installs everything, starts both servers.

### Manual start after init
```bash
# Backend
cd backend && source venv/bin/activate && python manage.py runserver

# Frontend JS
cd frontend-js && npm run dev

# Frontend TS
cd frontend-ts && npm run dev
```
