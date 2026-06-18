export type UserRole = 'admin' | 'user' | 'premium'

export interface User {
  id: string
  email: string
  first_name: string
  last_name: string
  full_name: string
  role: UserRole
  avatar: string | null
  phone: string
  email_verified: boolean
  created_at: string
}

export interface UpdateUserRequest {
  first_name?: string
  last_name?: string
  phone?: string
  avatar?: File
}
