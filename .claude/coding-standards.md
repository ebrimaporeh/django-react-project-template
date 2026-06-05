# Coding Standards

## Backend (Python/Django)

### Formatting
- PEP 8 compliance
- Black formatter (line length 88)
- isort for import ordering

### Import Order
```python
# 1. Standard library
import os
from datetime import timedelta

# 2. Django
from django.db import models
from django.conf import settings

# 3. Third-party
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

# 4. Local apps
from apps.core.models import BaseModel
from services.user_service import get_user_by_email
```

### Naming
- Variables/functions: `snake_case`
- Classes: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Private methods: `_prefixed_with_underscore`

### Comments
- Write comments only when WHY is non-obvious
- No docstrings on obvious methods
- Short inline comments for workarounds

### Model Conventions
```python
class User(BaseModel):
    email = models.EmailField(unique=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'User'
        verbose_name_plural = 'Users'
    
    def __str__(self):
        return self.email
```

### Serializer Conventions
```python
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'first_name', 'last_name', 'created_at']
        read_only_fields = ['id', 'created_at']
```

### View Conventions
```python
class UserListView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return user_service.get_users()
```

## Frontend (JavaScript/TypeScript)

### Formatting
- Prettier (single quotes, 2-space indent, trailing comma)
- ESLint with React + hooks rules

### Naming
- Components: `PascalCase`
- Hooks: `camelCase` with `use` prefix
- Files: match the default export name
- CSS classes: kebab-case (Tailwind utility classes)

### Component Structure
```jsx
// 1. Imports
import { useState } from 'react'
import { useUsers } from '@/hooks/useUsers'
import { Button } from '@/components/ui/button'

// 2. Types (TS only)
// interface Props { ... }

// 3. Component
export function UserList() {
  // 3a. Hooks
  const { users, isLoading } = useUsers()
  
  // 3b. State
  const [search, setSearch] = useState('')
  
  // 3c. Handlers
  const handleSearch = (value) => setSearch(value)
  
  // 3d. Render
  if (isLoading) return <LoadingSpinner />
  
  return (
    <div>...</div>
  )
}
```

### Hook Structure
```js
export function useUsers(params = {}) {
  return useQuery({
    queryKey: queryKeys.users.list(params),
    queryFn: () => userApi.getUsers(params),
  })
}
```

### API Function Structure
```js
export const userApi = {
  getUsers: (params) => apiClient.get('/users/', { params }),
  getUser: (id) => apiClient.get(`/users/${id}/`),
  createUser: (data) => apiClient.post('/users/', data),
  updateUser: (id, data) => apiClient.patch(`/users/${id}/`, data),
  deleteUser: (id) => apiClient.delete(`/users/${id}/`),
}
```
