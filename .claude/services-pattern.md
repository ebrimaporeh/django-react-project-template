# Services Pattern

## Why Services

Views handle HTTP. Services handle business logic. Keeping them separate means:
- Business logic is testable without HTTP
- Views stay thin and readable
- Logic can be reused across views, management commands, celery tasks

## Structure

```
services/
├── auth_service.py
├── user_service.py
└── notification_service.py
```

## Service Function Template

```python
# services/user_service.py

from django.core.exceptions import ValidationError, PermissionDenied
from apps.users.models import User


def get_user_by_id(user_id: str) -> User:
    try:
        return User.objects.get(id=user_id, is_active=True)
    except User.DoesNotExist:
        raise ValidationError(f"User {user_id} not found.")


def create_user(email: str, password: str, **kwargs) -> User:
    if User.objects.filter(email=email).exists():
        raise ValidationError("A user with this email already exists.")
    
    user = User(email=email, **kwargs)
    user.set_password(password)
    user.save()
    return user


def update_user(user: User, **data) -> User:
    allowed_fields = {'first_name', 'last_name', 'phone', 'avatar'}
    for field, value in data.items():
        if field in allowed_fields:
            setattr(user, field, value)
    user.save(update_fields=list(data.keys()))
    return user


def deactivate_user(user: User, requesting_user: User) -> None:
    if not requesting_user.is_staff:
        raise PermissionDenied("Only admins can deactivate users.")
    user.is_active = False
    user.save(update_fields=['is_active'])
```

## Calling Services from Views

```python
# apps/users/views.py

class UserDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        return user_service.get_user_by_id(self.kwargs['pk'])
    
    def perform_update(self, serializer):
        user_service.update_user(self.get_object(), **serializer.validated_data)
```

## Calling Services from Celery Tasks

```python
# tasks.py
from celery import shared_task
from services import user_service

@shared_task
def send_welcome_email(user_id):
    user = user_service.get_user_by_id(user_id)
    notification_service.send_welcome_email(user)
```

## Rules

1. Services import from `models/` only — never from `views/` or `serializers/`
2. Services raise Django exceptions (`ValidationError`, `PermissionDenied`) or custom ones
3. Views catch those exceptions and convert to HTTP responses
4. Services are plain functions unless statefulness requires a class
5. One file per business domain — keep files focused
