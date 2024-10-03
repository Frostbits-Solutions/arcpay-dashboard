import { h, ref, watch } from 'vue'
import { defineStore } from 'pinia'
import type { Database } from '@/lib/supabase/database.types'
import { getCurrencies } from '@/lib/supabase/currencies'
import ToastError from '@/components/ui/toast/ToastError.vue'
import { useToast } from '@/components/ui/toast'
import { useNetworksStore } from '@/stores/networks'

type Currency = Database['public']['Tables']['currencies']['Row']

const { toast } = useToast()

export const useCurrenciesStore = defineStore('currencies', () => {
  const list = ref<Currency[]>([])
  const networks = useNetworksStore()

  async function fetchCurrencies() {
    if (networks.activeNetwork) {
      const {data, error} = await getCurrencies(networks.activeNetwork)
      if (!data || error) {
        console.error(error)
        toast({
          title: 'Unable to fetch currencies data',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError)
        })
      } else {
        list.value = data
      }
    }
  }

  watch(() => networks.activeNetwork, fetchCurrencies)

  return { list, fetchCurrencies }
})
