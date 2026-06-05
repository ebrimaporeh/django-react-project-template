# System Architecture

## Overview

```
Browser → React Frontend (Vite) → Axios API Layer → Django REST API → Database
                                       ↓
                              JWT Token in localStorage
                              Refresh on 401 response
```

## Backend Layers (bottom → top)

```
Database
  └── Models (apps/*/models.py)
        └── Serializers (apps/*/serializers.py)
              └── Services (services/*.py)       ← Business logic lives here
                    └── Views (apps/*/views.py)  ← Thin, delegates to services
                          └── URLs (apps/*/urls.py)
                                └── config/urls.py
```

## Frontend Layers (top → bottom)

```
Pages
  └── Layouts (PublicLayout, AuthenticatedLayout, AdminLayout)
        └── Features (features/*/components)
              └── Hooks (hooks/, features/*/hooks/)  ← Wraps React Query
                    └── API Functions (src/api/)     ← Only place with fetch/axios
                          └── Axios Client (src/api/client.js|ts)
```

## Authentication Flow

1. User submits credentials → `authApi.login()`
2. Backend returns `{ access, refresh }` tokens
3. Tokens stored in localStorage (`access_token`, `refresh_token`)
4. Every request: axios interceptor attaches `Authorization: Bearer <access>`
5. On 401: axios interceptor calls refresh endpoint → retries original request
6. On refresh failure: clear tokens → redirect to `/login`

## Key Design Decisions

- **Services layer**: business logic never in views
- **Thin views**: views only validate input, call service, return response
- **Hooks layer**: components never call API functions directly
- **Feature folders**: co-locate components, hooks, and utils per domain
- **Split settings**: base / development / production / testing
- **Custom User model**: defined from day one in `apps/users/`

## Directory Map

```
project-template/
├── backend/
│   ├── apps/           # Django applications
│   ├── config/         # Django project config (urls, wsgi, asgi)
│   ├── services/       # Business logic
│   ├── permissions/    # DRF permission classes
│   ├── pagination/     # DRF pagination
│   ├── throttling/     # Rate limiting
│   ├── constants/      # App-wide constants
│   ├── utils/          # Utility functions
│   ├── emails/         # Email service
│   ├── signals/        # Django signals
│   ├── management/     # Management commands
│   ├── templates/      # Email HTML templates
│   ├── tests/          # Test suite
│   └── settings/       # Split settings
├── frontend-js/        # React JS app
│   └── src/
│       ├── api/        # API functions only
│       ├── hooks/      # Global React Query hooks
│       ├── components/ # ui/ + custom/
│       ├── features/   # Domain features
│       ├── layouts/    # Page shells
│       ├── pages/      # Route-level pages
│       ├── routes/     # TanStack Router
│       ├── utils/      # Generic helpers
│       ├── constants/  # App-wide constants
│       └── settings/   # Frontend config
└── frontend-ts/        # React TS app (same structure + types/)
```
