export interface ApiResponse<T = unknown> {
  success: boolean
  message?: string
  data?: T
}

export interface PaginatedResponse<T> {
  success: boolean
  count: number
  total_pages: number
  page: number
  page_size: number
  next: string | null
  previous: string | null
  results: T[]
}

export interface ApiError {
  success: false
  message: string
  errors: Record<string, string[]>
}

export interface PaginationParams {
  page?: number
  page_size?: number
  search?: string
  ordering?: string
}
