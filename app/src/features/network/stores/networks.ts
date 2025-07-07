import { h, ref } from 'vue'
import { defineStore } from 'pinia'
import type { Chain } from '@/models'
import { getChains } from '@/features/network/services/network'
import { toast } from '@/lib/ui/toast'
import ToastError from '@/lib/ui/toast/ToastError.vue'

export const useNetworksStore = defineStore('networks', () => {
  const activeNetwork = ref<string | undefined>()
  const networks = ref<string[]>([])

  function setActive(chain_id: string) {
    activeNetwork.value = chain_id
    localStorage.setItem("defaultNetwork", chain_id)
  }

  async function fetchChains() {
    const { data, error } = await getChains()
    if (!data || error) {
      console.error(error)
      toast({
        title: 'Error fetching chains',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      networks.value = data.map((chain: Chain) => chain.id).sort((a, b) => a.localeCompare(b))
    }
  }

  return { activeNetwork, networks, fetchChains, setActive }
})
