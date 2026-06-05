# Frontend Rules

## Folder Rules

- `src/api/` — ONLY place where HTTP requests are made. No fetch/axios elsewhere.
- `src/hooks/` — Global hooks used across features (useAuth, useUser)
- `src/features/` — Domain-specific code: components, hooks, utils per feature
- `src/components/ui/` — shadcn/ui components (do not modify)
- `src/components/custom/` — Project-specific reusable components
- `src/layouts/` — Page shell components (header, sidebar, footer)
- `src/pages/` — Route-level components (thin, compose feature components)
- `src/routes/` — TanStack Router route definitions and guards
- `src/utils/` — Generic, framework-agnostic utility functions
- `src/constants/` — App-wide string/number constants
- `src/settings/` — Frontend configuration (site name, feature flags, etc.)
- `src/types/` — (TypeScript only) Shared type definitions

## Component Rules

- Functional components only — no class components
- Props destructured in function signature
- Components under 150 lines — split if larger
- No direct API calls in components — use hooks
- No business logic in components — delegate to hooks/utils

## API Layer Rules

- One file per domain: `authApi.js`, `userApi.js`
- Every function returns a Promise with typed response
- Only call `apiClient` — never import axios directly in features
- Query key definitions live in `queryKeys.js`

## Hooks Rules

- One hook per feature operation: `useLogin`, `useUsers`, `useProfile`
- Hooks use React Query `useMutation` or `useQuery`
- Hooks handle loading/error states — components just read them
- Custom hooks prefixed with `use`

## Routing Rules

- Route definitions live in `src/routes/`
- Route guards enforce authentication/role access
- Never use `window.location.href` for navigation — use TanStack Router
- Public routes accessible without auth
- Authenticated routes redirect to `/login` if not logged in
- Admin routes redirect to `/dashboard` if not admin

## State Management Rules

- Server state: React Query (`useQuery`, `useMutation`)
- UI state: `useState` / `useReducer` (local)
- Global UI state: Zustand (theme, sidebar open)
- Never use Redux or Context for server data

## Styling Rules

- TailwindCSS for all styling
- shadcn/ui components as the base UI system
- Dark mode via `dark:` Tailwind prefix
- No inline styles unless truly dynamic

## Error Handling Rules

- Display user-friendly error messages (not raw API errors)
- Use toast notifications for mutation success/failure
- Log errors to console in development only

## Naming Conventions

- Components: `PascalCase` (e.g., `UserProfile.jsx`)
- Hooks: `camelCase` with `use` prefix (e.g., `useUsers.js`)
- API functions: `camelCase` (e.g., `getUsers`, `createUser`)
- Constants: `SCREAMING_SNAKE_CASE`
- Util functions: `camelCase`
