# Frontend TS — AI Operating Instructions

## Stack

- React 19, Vite, TypeScript (TSX)
- TanStack Router for routing (fully type-safe)
- TanStack Query for server state
- Axios for HTTP
- TailwindCSS + shadcn/ui for styling

## Key Differences from frontend-js

- All files are `.ts` / `.tsx` instead of `.js` / `.jsx`
- `src/types/` contains all shared TypeScript interfaces
- `tsconfig.app.json` enforces strict mode
- API functions are generically typed: `apiClient.get<User>('/users/me/')`
- Hooks use typed parameters and return values
- Router module augmentation in `src/routes/rootRoute.ts` provides type-safe navigation

## Type Location Rules

- API response types → `src/types/api.ts`
- User/auth types → `src/types/user.ts`, `src/types/auth.ts`
- Feature-specific types → `src/features/<name>/types.ts`
- Component prop types → inline in the component file (interface Props)

## Key Patterns

1. **API calls**: ONLY in `src/api/`. Use typed `apiClient`.
2. **Types**: Import from `@/types` — don't re-declare existing types.
3. **Hooks**: Wrap API calls in typed React Query hooks.
4. **Routes**: Fully typed via TanStack Router module augmentation.

## Commands

```bash
npm install
npm run dev
npm run typecheck
npm run build
npm run lint
```

## Adding a New Feature

1. Add types to `src/types/` or `src/features/<name>/types.ts`
2. Create typed API functions in `src/api/<name>Api.ts`
3. Add query keys to `src/api/queryKeys.ts`
4. Create typed hooks in `src/hooks/use<Name>.ts`
5. Build components in `src/features/<name>/components/`
6. Add page + route
