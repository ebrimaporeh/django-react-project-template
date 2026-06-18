export function formatDate(dateString: string, options: Intl.DateTimeFormatOptions = {}): string {
  if (!dateString) return ''
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric', month: 'short', day: 'numeric', ...options,
  }).format(new Date(dateString))
}

export function formatDateTime(dateString: string): string {
  return formatDate(dateString, { hour: '2-digit', minute: '2-digit' })
}

export function formatCurrency(amount: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(amount)
}

export function truncate(str: string, length = 100): string {
  if (!str || str.length <= length) return str
  return str.slice(0, length) + '...'
}

export function capitalize(str: string): string {
  if (!str) return ''
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase()
}

export function initials(name: string): string {
  if (!name) return '??'
  return name.split(' ').map((n) => n[0]).join('').toUpperCase().slice(0, 2)
}
