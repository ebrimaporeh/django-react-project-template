# Security Rules

## Authentication Security

- JWT access tokens expire in 15 minutes (production)
- JWT refresh tokens expire in 7 days
- Rotate refresh tokens on each use (`ROTATE_REFRESH_TOKENS = True`)
- Blacklist old refresh tokens (`BLACKLIST_AFTER_ROTATION = True`)
- Store tokens in localStorage (acceptable for SPA) — never in cookies without Secure + HttpOnly flags
- Always validate token claims server-side

## Password Security

- Minimum 8 characters, require uppercase + lowercase + digit
- Use Django's built-in password validators
- Hash with PBKDF2 (default) — never store plain passwords
- Rate limit login endpoint (5 attempts / 15 min)
- Invalidate all sessions on password change

## API Security

- All endpoints require explicit `permission_classes`
- Unauthenticated access only for: login, register, password reset
- Use `IsAuthenticated` as default guard
- Owner-level permissions for resource access
- Admin endpoints require `IsAdminUser`

## Input Validation

- Validate all input at serializer level
- Sanitize user-generated content before storage
- Never use `eval()`, `exec()`, or `os.system()` with user input
- Parameterize all database queries (ORM does this — never use raw SQL with f-strings)

## CORS

- In production: set `CORS_ALLOWED_ORIGINS` to exact frontend URL
- Never use `CORS_ALLOW_ALL_ORIGINS = True` in production
- Only allow necessary HTTP methods and headers

## Headers

- Enable `SECURE_BROWSER_XSS_FILTER`
- Enable `X_FRAME_OPTIONS = 'DENY'`
- Enable `SECURE_CONTENT_TYPE_NOSNIFF`
- Use HTTPS in production: `SECURE_SSL_REDIRECT = True`
- Set `SECURE_HSTS_SECONDS` in production

## File Uploads

- Validate file type by content (not extension)
- Set maximum file size limits
- Never store uploaded files in `MEDIA_ROOT` under web-accessible path without auth check
- Use Pillow to re-encode images (strips EXIF/metadata)

## Environment Variables

- All secrets in `.env` files — never committed to git
- `.env.example` committed with placeholder values
- Use `python-decouple` to read env vars with type casting
- Separate `.env` per environment (dev, test, prod)

## Rate Limiting

- Anonymous endpoints: 100 requests / hour
- Authenticated endpoints: 1000 requests / hour  
- Login/register: 10 requests / 15 min
- Configurable via `API_RATE_LIMIT_ANON` and `API_RATE_LIMIT_USER` env vars

## Secrets Checklist

Before any commit, confirm:
- [ ] No `SECRET_KEY` hardcoded
- [ ] No DB credentials in code
- [ ] No API keys in source
- [ ] `.env` is in `.gitignore`
- [ ] `DEBUG = False` in production settings
- [ ] `ALLOWED_HOSTS` is not `['*']` in production
