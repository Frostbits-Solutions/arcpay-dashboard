import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatDate(date: string) {
  const d = new Date(date)
  return `${d.toLocaleDateString()} ${d.toLocaleTimeString()}`
}

export function formatAmountToDecimals(amount: number, decimals: number = 6) {
  return amount * 10 ** decimals
}

export function formatAmountFromDecimals(amount: number, decimals: number = 6) {
  return amount / 10 ** decimals
}

export function formatPrice(price: number = 0, decimals: number = 0) {
  return parseFloat(price.toFixed(decimals))
}
