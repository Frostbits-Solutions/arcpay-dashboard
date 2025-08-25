import { toast } from '@/lib/ui/toast'
import ToastError from '@/lib/ui/toast/ToastError.vue'
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
