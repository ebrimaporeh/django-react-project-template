# Backend Rules

## Project Structure Rules

- All Django apps live in `apps/`
- Each app has: `models.py`, `serializers.py`, `views.py`, `urls.py`, `apps.py`
- Larger apps split into sub-packages: `views/`, `serializers/`
- Business logic MUST live in `services/`, never in views or models

## Model Rules

- Always inherit from `apps.core.models.BaseModel` (provides `id`, `created_at`, `updated_at`)
- Use `UUID` as primary key
- Never use `auto_now_add=True` on custom fields — use `BaseModel`
- Soft delete: add `is_deleted = models.BooleanField(default=False)` if needed

## View Rules

- Views must be thin: validate → call service → return response
- Use DRF `APIView` or `GenericAPIView` — avoid function-based views
- Use `drf-spectacular` `@extend_schema` on all views
- Always set `permission_classes` explicitly — never rely on defaults

## Serializer Rules

- Use `ModelSerializer` for CRUD, `Serializer` for custom inputs
- Separate serializers for read and write operations when they differ significantly
- Never expose sensitive fields (passwords, tokens) in response serializers

## Service Rules

- One service file per domain: `user_service.py`, `auth_service.py`
- Service functions are plain Python functions (not classes) unless state is needed
- Services can call other services
- Services raise `ValidationError`, `PermissionDenied`, or custom exceptions
- Services never import from `views/` or `serializers/` — only from `models/`

## URL Rules

- Each app defines its own `urls.py`
- All app URLs mounted under `config/urls.py` with `api/v1/` prefix
- Use router for ViewSets, manual patterns for APIViews

## Settings Rules

- Never import directly from `django.conf.settings` in app code
- Use `from django.conf import settings` only in services/utils
- All secrets come from environment variables via `python-decouple`

## Test Rules

- Test files live in `tests/`
- Name tests: `test_<feature>.py`
- Test all service functions, not just views
- Use `APITestCase` for endpoint tests
- Always test happy path + error cases

## Error Response Format

All errors must return:
```json
{
  "success": false,
  "message": "Human-readable message",
  "errors": {}
}
```

All success responses must return:
```json
{
  "success": true,
  "message": "Optional message",
  "data": {}
}
```
