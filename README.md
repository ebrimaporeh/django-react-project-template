# Production-Ready Starter Template

A full-stack SaaS/application starter with Django REST Framework backend and two React frontends (JavaScript + TypeScript).

---

## Structure

```
project-template/
├── .claude/              ← AI instruction files for the whole project
├── backend/              ← Django 4.2 + DRF API
├── frontend-js/          ← React 19 + Vite (JavaScript)
└── frontend-ts/          ← React 19 + Vite (TypeScript)
```

Each sub-project also has its own `.claude/` folder with domain-specific AI instructions.

---

## Tech Stack

### Backend
| Package | Purpose |
|---|---|
| Django 4.2 | Web framework |
| Django REST Framework | API layer |
| SimpleJWT | JWT authentication |
| django-allauth | OAuth / email auth |
| drf-spectacular | OpenAPI docs |
| django-cors-headers | CORS |
| django-filter | Filtering & search |
| python-decouple | Environment config |
| WhiteNoise | Static file serving |
| Gunicorn | Production WSGI |

### Frontend (both JS and TS)
| Package | Purpose |
|---|---|
| React 19 | UI framework |
| Vite | Build tool |
| TanStack Router | Type-safe routing |
| TanStack Query | Server state management |
| Axios | HTTP client |
| TailwindCSS | Styling |
| shadcn/ui | Component library |
| Framer Motion | Animations |
| Recharts | Charts |
| Zustand | UI state |
| Lucide React | Icons |

---

## Quick Start

### One-command setup (recommended)

```bash
cd project-template
./init.sh
```

The script will:
1. Check that Python 3 and Node.js are installed
2. Ask whether you want the **JavaScript** or **TypeScript** frontend
3. Create the Python virtual environment and install dependencies
4. Copy `.env.example` → `.env` with a generated `SECRET_KEY`
5. Run database migrations and seed demo data
6. Offer to start both servers immediately

> **Windows users:** Run the steps in the [manual setup](#manual-setup) section below using Git Bash or WSL.

---

### Manual setup

#### Backend

```bash
cd backend

# 1. Create and activate virtual environment
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Copy environment file
cp .env.example .env
# Edit .env and set SECRET_KEY

# 4. Run migrations
python manage.py migrate

# 5. Seed development data
python manage.py seed_data

# 6. Start server
python manage.py runserver
```

Backend runs at: http://localhost:8000  
API docs: http://localhost:8000/api/docs/

### Frontend JS

```bash
cd frontend-js

npm install

cp .env.example .env

npm run dev
```

Runs at: http://localhost:5173

### Frontend TS

```bash
cd frontend-ts

npm install

cp .env.example .env

npm run dev
```

Runs at: http://localhost:5174

---

## Seed Users

After running `python manage.py seed_data`:

| Email | Password | Role |
|---|---|---|
| admin@example.com | Admin@1234 | Admin |
| premium@example.com | Premium@1234 | Premium |
| user@example.com | User@1234 | User |

---

## Architecture

### Backend

```
Request → URL → View (thin) → Service (logic) → Model → DB
                    ↓
              Serializer (validation / output)
```

- **Models** inherit from `apps.core.models.BaseModel` (UUID pk, timestamps)
- **Services** (`services/`) hold all business logic — views call services, not models
- **Permissions** (`permissions/base.py`) — `IsAdminUser`, `IsPremiumUser`, `IsOwnerOrAdmin`
- **Pagination** — standard `{count, total_pages, page, results}` format
- **Emails** go through `emails/service.py` — never call `send_mail` from views
- **Settings** split: `base.py` → `development.py` / `production.py` / `testing.py`

### Frontend

```
Page → Layout → Feature Component → Hook → API Function → Backend
                                      ↓
                               React Query Cache
```

- **`src/api/`** — ONLY place for HTTP requests
- **`src/hooks/`** — wrap API in React Query hooks
- **`src/features/`** — domain features with co-located components/hooks
- **`src/layouts/`** — `PublicLayout`, `AuthenticatedLayout`, `AdminLayout`
- **`src/routes/`** — route definitions + guards (`beforeLoad`)

---

## API Endpoints

```
POST   /api/v1/auth/register/
POST   /api/v1/auth/login/
POST   /api/v1/auth/logout/
POST   /api/v1/auth/refresh/
POST   /api/v1/auth/change-password/
POST   /api/v1/auth/verify-email/
POST   /api/v1/auth/password-reset/

GET    /api/v1/users/me/
PATCH  /api/v1/users/me/
GET    /api/v1/users/          (admin only)
GET    /api/v1/users/{id}/     (admin only)
PATCH  /api/v1/users/{id}/     (admin only)
DELETE /api/v1/users/{id}/     (admin only)

GET    /api/docs/
GET    /api/schema/
```

---

## User Roles

| Role | Access |
|---|---|
| `user` | Own profile only |
| `premium` | All user routes + premium features |
| `admin` | Full access including user management |

---

## Environment Variables

### Backend (`.env`)
```
SECRET_KEY=...
DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3
FRONTEND_URL=http://localhost:5173
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
JWT_ACCESS_TOKEN_LIFETIME_MINUTES=60
JWT_REFRESH_TOKEN_LIFETIME_DAYS=7
```

### Frontend (`.env`)
```
VITE_API_URL=http://localhost:8000/api/v1
VITE_SITE_NAME=My App
```

---

## Adding a New Feature

### Backend
1. Create `apps/myfeature/` with `models.py`, `serializers.py`, `views.py`, `urls.py`, `apps.py`
2. Add to `LOCAL_APPS` in `settings/base.py`
3. Mount in `config/urls.py`
4. Run `python manage.py makemigrations myfeature && python manage.py migrate`
5. Add service logic to `services/myfeature_service.py`

### Frontend
1. Add API functions to `src/api/myfeatureApi.js|ts`
2. Add query keys to `src/api/queryKeys.js|ts`
3. Create hooks in `src/hooks/useMyFeature.js|ts`
4. Build components in `src/features/myfeature/`
5. Add page to `src/pages/`
6. Add route to `src/routes/rootRoute.js|ts`

---

## Production Deployment

### Backend Checklist
- [ ] Set `DEBUG=False`
- [ ] Set `DJANGO_SETTINGS_MODULE=settings.production`
- [ ] Set exact `ALLOWED_HOSTS` (no `*`)
- [ ] Set exact `CORS_ALLOWED_ORIGINS` (no `CORS_ALLOW_ALL_ORIGINS`)
- [ ] Use PostgreSQL or MySQL (`DATABASE_URL`)
- [ ] Configure real email (`EMAIL_BACKEND=smtp`)
- [ ] Run `python manage.py collectstatic`
- [ ] Use Gunicorn: `gunicorn config.wsgi:application`

### Frontend Checklist
- [ ] Set `VITE_API_URL` to production API URL
- [ ] Run `npm run build` → deploy `dist/`
- [ ] Configure CDN or Nginx to serve `dist/`

---

## AI Operating Instructions

Read `.claude/CLAUDE.md` before making changes. Each sub-project also has its own `.claude/CLAUDE.md`.

Architecture, security, and coding rules are in `.claude/`:
- `architecture.md` — system design
- `backend-rules.md` — backend conventions
- `frontend-rules.md` — frontend conventions
- `security-rules.md` — security requirements
- `coding-standards.md` — code style
- `services-pattern.md` — service layer pattern
- `api-pattern.md` — API layer pattern
