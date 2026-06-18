import { createRouter, createRootRoute, createRoute, redirect } from '@tanstack/react-router'
import { queryClient } from '@/api/client'
import { queryKeys } from '@/api/queryKeys'
import { userApi } from '@/api/userApi'
import { PublicLayout } from '@/layouts/PublicLayout'
import { AuthenticatedLayout } from '@/layouts/AuthenticatedLayout'
import { LoginPage } from '@/pages/public/LoginPage'
import { DashboardPage } from '@/pages/authenticated/DashboardPage'
import { ROLES, ROUTES } from '@/constants'
import type { User } from '@/types'

const rootRoute = createRootRoute()

async function requireAuth() {
  const token = localStorage.getItem('access_token')
  if (!token) throw redirect({ to: ROUTES.LOGIN })
  try {
    await queryClient.fetchQuery({ queryKey: queryKeys.auth.me(), queryFn: userApi.getMe })
  } catch {
    throw redirect({ to: ROUTES.LOGIN })
  }
}

async function requireAdmin() {
  await requireAuth()
  const user = queryClient.getQueryData<User>(queryKeys.auth.me())
  if (user?.role !== ROLES.ADMIN) throw redirect({ to: ROUTES.DASHBOARD })
}

const publicLayout = createRoute({ getParentRoute: () => rootRoute, id: 'public', component: PublicLayout })

const loginRoute = createRoute({
  getParentRoute: () => publicLayout,
  path: ROUTES.LOGIN,
  component: LoginPage,
})

const authLayout = createRoute({
  getParentRoute: () => rootRoute,
  id: 'auth',
  component: AuthenticatedLayout,
  beforeLoad: requireAuth,
})

const dashboardRoute = createRoute({
  getParentRoute: () => authLayout,
  path: ROUTES.DASHBOARD,
  component: DashboardPage,
})

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  beforeLoad: () => { throw redirect({ to: ROUTES.DASHBOARD }) },
})

const routeTree = rootRoute.addChildren([
  indexRoute,
  publicLayout.addChildren([loginRoute]),
  authLayout.addChildren([dashboardRoute]),
])

export const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
