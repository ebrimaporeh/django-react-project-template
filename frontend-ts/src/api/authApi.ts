import { apiClient } from './client'
import type { LoginRequest, RegisterRequest, ChangePasswordRequest, AuthResponse, ApiResponse } from '@/types'

export const authApi = {
  register: (data: RegisterRequest) =>
    apiClient.post<AuthResponse>('/auth/register/', data).then((r) => r.data),
  login: (data: LoginRequest) =>
    apiClient.post<AuthResponse>('/auth/login/', data).then((r) => r.data),
  logout: (refresh: string) =>
    apiClient.post<ApiResponse>('/auth/logout/', { refresh }).then((r) => r.data),
  refresh: (refresh: string) =>
    apiClient.post<{ access: string }>('/auth/refresh/', { refresh }).then((r) => r.data),
  changePassword: (data: ChangePasswordRequest) =>
    apiClient.post<ApiResponse>('/auth/change-password/', data).then((r) => r.data),
  verifyEmail: (token: string) =>
    apiClient.post<ApiResponse>('/auth/verify-email/', { token }).then((r) => r.data),
  requestPasswordReset: (email: string) =>
    apiClient.post<ApiResponse>('/auth/password-reset/', { email }).then((r) => r.data),
  confirmPasswordReset: (data: { token: string; password: string }) =>
    apiClient.post<ApiResponse>('/auth/password-reset/confirm/', data).then((r) => r.data),
}
