import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'
import { queryKeys } from '@/api/queryKeys'
import { authApi } from '@/api/authApi'
import { userApi } from '@/api/userApi'
import type { LoginRequest, RegisterRequest, ChangePasswordRequest } from '@/types'

export function useMe() {
  return useQuery({
    queryKey: queryKeys.auth.me(),
    queryFn: userApi.getMe,
    retry: false,
  })
}

export function useLogin() {
  const queryClient = useQueryClient()
  const navigate = useNavigate()

  return useMutation({
    mutationFn: (data: LoginRequest) => authApi.login(data),
    onSuccess: (data) => {
      localStorage.setItem('access_token', data.data.tokens.access)
      localStorage.setItem('refresh_token', data.data.tokens.refresh)
      queryClient.setQueryData(queryKeys.auth.me(), data.data.user)
      navigate({ to: '/dashboard' })
    },
  })
}

export function useRegister() {
  const queryClient = useQueryClient()
  const navigate = useNavigate()

  return useMutation({
    mutationFn: (data: RegisterRequest) => authApi.register(data),
    onSuccess: (data) => {
      localStorage.setItem('access_token', data.data.tokens.access)
      localStorage.setItem('refresh_token', data.data.tokens.refresh)
      queryClient.setQueryData(queryKeys.auth.me(), data.data.user)
      navigate({ to: '/dashboard' })
    },
  })
}

export function useLogout() {
  const queryClient = useQueryClient()
  const navigate = useNavigate()

  return useMutation({
    mutationFn: () => {
      const refresh = localStorage.getItem('refresh_token') || ''
      return authApi.logout(refresh)
    },
    onSettled: () => {
      localStorage.removeItem('access_token')
      localStorage.removeItem('refresh_token')
      queryClient.clear()
      navigate({ to: '/login' })
    },
  })
}

export function useChangePassword() {
  return useMutation({
    mutationFn: (data: ChangePasswordRequest) => authApi.changePassword(data),
  })
}
