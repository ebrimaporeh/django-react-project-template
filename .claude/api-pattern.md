# API Layer Pattern

## Frontend API Pattern

The `src/api/` directory is the ONLY place that makes HTTP requests.

### File Structure

```
src/api/
├── client.js       # axios instance with interceptors
├── queryKeys.js    # React Query key factory
├── authApi.js      # auth endpoints
└── userApi.js      # user endpoints
```

### client.js — Axios Instance

The client handles:
- Base URL from environment
- Auth token injection
- Token refresh on 401
- Standard error formatting

### queryKeys.js — Key Factory

```js
export const queryKeys = {
  auth: {
    me: () => ['auth', 'me'],
  },
  users: {
    all: () => ['users'],
    list: (params) => ['users', 'list', params],
    detail: (id) => ['users', 'detail', id],
  },
}
```

Keys are arrays so React Query can invalidate at any level:
- Invalidate `['users']` → invalidates all user queries
- Invalidate `['users', 'list', params]` → only that filtered list

### API Function File

```js
// src/api/userApi.js
import { apiClient } from './client'

export const userApi = {
  getUsers: (params) => apiClient.get('/users/', { params }).then(r => r.data),
  getUser: (id) => apiClient.get(`/users/${id}/`).then(r => r.data),
  createUser: (data) => apiClient.post('/users/', data).then(r => r.data),
  updateUser: (id, data) => apiClient.patch(`/users/${id}/`, data).then(r => r.data),
  deleteUser: (id) => apiClient.delete(`/users/${id}/`).then(r => r.data),
}
```

### Hook Consuming the API

```js
// src/hooks/useUsers.js
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { queryKeys } from '@/api/queryKeys'
import { userApi } from '@/api/userApi'

export function useUsers(params = {}) {
  return useQuery({
    queryKey: queryKeys.users.list(params),
    queryFn: () => userApi.getUsers(params),
  })
}

export function useCreateUser() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: userApi.createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.users.all() })
    },
  })
}
```

### Component Using the Hook

```jsx
// src/features/users/components/UserList.jsx
import { useUsers } from '@/hooks/useUsers'

export function UserList() {
  const { data: users, isLoading, isError } = useUsers()
  
  if (isLoading) return <LoadingSpinner />
  if (isError) return <ErrorMessage />
  
  return users.results.map(user => <UserCard key={user.id} user={user} />)
}
```

## Backend API Pattern

### URL Structure

```
/api/v1/auth/register/
/api/v1/auth/login/
/api/v1/auth/logout/
/api/v1/auth/refresh/
/api/v1/auth/password-reset/
/api/v1/auth/verify-email/
/api/v1/users/
/api/v1/users/me/
/api/v1/users/{id}/
```

### Standard Response Shape

```json
// Success (list)
{
  "success": true,
  "count": 100,
  "total_pages": 10,
  "page": 1,
  "page_size": 10,
  "next": "http://...",
  "previous": null,
  "results": []
}

// Success (single)
{
  "success": true,
  "data": {}
}

// Error
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "email": ["This field is required."]
  }
}
```
