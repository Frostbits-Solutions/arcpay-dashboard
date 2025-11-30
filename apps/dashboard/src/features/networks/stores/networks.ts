import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import type { Network, Currency } from '@repo/supabase/models'
import { getNetworks } from '@/services/networks'
import { getCurrencies } from '@/services/currencies'
import { errorHandler } from '@/lib/errorHandler'
import { services } from '@/services/networks'
import { walletProviders } from '@/features/networks/walletProviders'
import { supabase } from '@repo/supabase/client'
import { type SupportedWallet, type NetworkId, WalletManager } from '@txnlab/use-wallet'

export const useNetworksStore = defineStore('networks', () => {
  const networks = ref<Record<string, Network>>({})
  const activeNetworkId = ref<string | undefined>()
  const activeNetworkCurrencies = ref<Currency[]>([])
  const activeNetworkWalletManager = ref<WalletManager>()

  const activeNetwork = computed(() => {
    if (!activeNetworkId.value || !activeNetworkWalletManager.value) return undefined
    return {
      ...networks.value[activeNetworkId.value],
      currencies: activeNetworkCurrencies.value,
      services: services[activeNetworkId.value],
      walletProvider: activeNetworkWalletManager.value,
    }
  })

  const supportedNetworkIds = computed(() => Object.keys(networks.value))

  async function setActive(networkId: string, setDefault?: boolean) {
    try {
      if (!networks.value[networkId]) throw new Error(`Network ${networkId} is not supported`)
      if (!services[networkId]) throw new Error(`Network ${networkId} not supported: Missing services`)
      if (!walletProviders[networkId]) throw new Error(`Network ${networkId} not supported: Missing wallet providers`)
      await fetchCurrencies(networkId)
      const walletManager = new WalletManager({
        wallets: walletProviders[networkId] as SupportedWallet[],
        algod: {
          token: networks.value[networkId].node_token || '',
          baseServer: networks.value[networkId].node_url,
          port: networks.value[networkId].node_port,
        },
      })
      await walletManager.setActiveNetwork(networks.value[networkId].id as NetworkId)
      await walletManager.resumeSessions()
      activeNetworkWalletManager.value = walletManager
      activeNetworkId.value = networkId
      if (setDefault !== false) localStorage.setItem('defaultNetwork', networkId)
    } catch (e) {
      errorHandler(e, 'Network error')
    }
  }

  async function fetchNetworks() {
    const { data, error } = await getNetworks()
    if (!data || error) {
      errorHandler(error, 'Failed to fetch networks')
    } else {
      data.sort((a, b) => a.id.localeCompare(b.id))
      data.forEach((network: Network) => {
        networks.value[network.id] = network
      })
    }
  }

  async function fetchCurrencies(networkId: string) {
    const { data, error } = await getCurrencies(supabase, networkId)
    if (!data || error) {
      throw new Error(`Unable to fetch currencies for ${networkId}. ${error?.message || ''}`)
    } else {
      activeNetworkCurrencies.value = data
    }
  }

  return { activeNetwork, networks: supportedNetworkIds, fetchNetworks, setActive }
})
