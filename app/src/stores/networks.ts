import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase/supabaseClient'
import { createClient, type ArcpayClient } from 'arcpay-sdk'
import type { Chain } from '@/models'
import { useDark } from '@vueuse/core'

export const useNetworksStore = defineStore('networks', () => {
  const clients = ref<Record<string, ArcpayClient>>({})
  const activeNetwork = ref<Chain | undefined>()
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

  return { activeNetwork, activeClient, setActive }
})
