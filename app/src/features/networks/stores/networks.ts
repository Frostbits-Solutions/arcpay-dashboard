import { h, ref } from 'vue'
import { defineStore } from 'pinia'
import type { Chain, Currency } from '@/models'
import { getChains } from '@/services/networks'
import { toast } from '@/lib/ui/toast'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import { getCurrencies } from '@/services/currencies'

export const useNetworksStore = defineStore('networks', () => {
  const activeNetwork = ref<string | undefined>()
  const networks = ref<string[]>([])
  const activeNetworkCurrencies = ref<Currency[]>([])

  async function setActive(chain_id: string) {
    await fetchCurrencies()
    activeNetwork.value = chain_id
    localStorage.setItem('defaultNetwork', chain_id)
  }

  async function fetchChains() {
    const { data, error } = await getChains()
    if (!data || error) {
      console.error(error)
      toast({
        title: 'Error fetching chains',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError),
      })
    } else {
      networks.value = data.map((chain: Chain) => chain.id).sort((a, b) => a.localeCompare(b))
    }
  }

  async function fetchCurrencies() {
    if (activeNetwork.value) {
      const { data, error } = await getCurrencies(activeNetwork.value)
      if (!data || error) {
        console.error(error)
        toast({
          title: 'Unable to fetch currencies data',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError),
        })
      } else {
        activeNetworkCurrencies.value = data
      }
    }
  }

  return { activeNetwork, activeNetworkCurrencies, networks, fetchChains, setActive }
})
