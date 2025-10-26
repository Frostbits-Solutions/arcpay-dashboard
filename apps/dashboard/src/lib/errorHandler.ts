import { toast } from '@repo/ui/toast'
import { ToastError } from '@repo/ui/toast'
import { h } from 'vue'

export function errorHandler(error: any, title?: string) {
  if (error) console.error(error)
  toast({
    title: title || 'Error',
    description: error?.message || 'Unexpected error',
    variant: 'destructive',
    action: h(ToastError),
  })
}
