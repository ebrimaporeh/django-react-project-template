import type { UserRole } from '@/types'

export const ROLES: Record<string, UserRole> = {
  ADMIN: 'admin',
  USER: 'user',
  PREMIUM: 'premium',
}

export const ROUTES = {
  HOME: '/',
  LOGIN: '/login',
  REGISTER: '/register',
  FORGOT_PASSWORD: '/forgot-password',
  DASHBOARD: '/dashboard',
  PROFILE: '/profile',
  SETTINGS: '/settings',
  ADMIN_USERS: '/admin/users',
} as const

export const QUERY_STALE_TIME = {
  SHORT: 1000 * 30,
  MEDIUM: 1000 * 60 * 5,
  LONG: 1000 * 60 * 60,
} as const
