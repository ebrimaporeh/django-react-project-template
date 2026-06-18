export interface Tokens {
  access: string
  refresh: string
}

export interface LoginRequest {
  email: string
  password: string
}

export interface RegisterRequest {
  email: string
  password: string
  password_confirm: string
  first_name?: string
  last_name?: string
}

export interface ChangePasswordRequest {
  old_password: string
  new_password: string
  new_password_confirm: string
}

export interface AuthResponse {
  success: boolean
  message: string
  data: {
    user: User
    tokens: Tokens
  }
}

import { User } from './user'
