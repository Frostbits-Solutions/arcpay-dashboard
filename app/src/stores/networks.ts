import { computed, h, ref } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase/supabaseClient'
import { createClient } from 'arcpay-sdk'
import type { Chain } from '@/models'
import { useDark } from '@vueuse/core'
import { getChains } from '@/lib/supabase/network'
import { toast } from '@/components/ui/toast'
import ToastError from '@/components/ui/toast/ToastError.vue'

export const useNetworksStore = defineStore('networks', () => {
  const clients = ref<Record<string, any>>({})
  const activeNetwork = ref<Chain | undefined>()
  const networks = ref<Chain[]>([])

  const activeClient = computed(() => {
    if (activeNetwork.value) return clients.value[activeNetwork.value]
    else return undefined
  })

  const isDark = useDark({
    onChanged(dark: boolean) {
      if (activeClient.value) {
        activeClient.value.toggleDarkMode(dark)
      }
    }
  })

  function setActive(network: Chain) {
    if (!clients.value[network]) {
      clients.value[network] = createClient(network, {
        //@ts-ignore
        client: supabase,
        darkMode: isDark.value
      })
    }
    activeNetwork.value = network
    localStorage.setItem("defaultNetwork", network)
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
      networks.value = data
    }
  }

  return { activeNetwork, activeClient, networks, fetchChains, setActive }
})
