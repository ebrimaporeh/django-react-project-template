import { apiClient } from './client'
import type { User, UpdateUserRequest, PaginatedResponse, PaginationParams, ApiResponse } from '@/types'

export const userApi = {
  getMe: () => apiClient.get<User>('/users/me/').then((r) => r.data),
  updateMe: (data: UpdateUserRequest) =>
    apiClient.patch<ApiResponse<User>>('/users/me/', data).then((r) => r.data),
  getUsers: (params?: PaginationParams) =>
    apiClient.get<PaginatedResponse<User>>('/users/', { params }).then((r) => r.data),
  getUser: (id: string) =>
    apiClient.get<ApiResponse<User>>(`/users/${id}/`).then((r) => r.data),
  updateUser: (id: string, data: Partial<User>) =>
    apiClient.patch<ApiResponse<User>>(`/users/${id}/`, data).then((r) => r.data),
  deleteUser: (id: string) =>
    apiClient.delete<ApiResponse>(`/users/${id}/`).then((r) => r.data),
}
