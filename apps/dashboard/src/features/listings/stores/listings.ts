import { ref, watch } from 'vue'
import { defineStore } from 'pinia'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useNetworksStore } from '@/features/networks/stores/networks'
import { getListings } from '@/services/listings'
import type { Listing } from '@repo/supabase/models'
import { errorHandler } from '@/lib/errorHandler'

export const useListingsStore = defineStore('listings', () => {
  const accounts = useAccountsStore()
  const networks = useNetworksStore()
  const loading = ref(false)
  const list = ref<Listing[]>([])

  async function fetchListings() {
    if (accounts.active && networks.activeNetwork) {
      loading.value = true
      const { data, error } = await getListings(accounts.active.id, networks.activeNetwork.id)
      if (!data || error) {
        errorHandler(error, 'Error fetching listings')
      } else {
        list.value = data
      }
      loading.value = false
    }
  }

  watch(
    () => networks.activeNetwork?.id,
    () => {
      fetchListings()
    }
  )
  watch(
    () => accounts.active,
    () => {
      fetchListings()
    }
  )

  return { loading, list, fetchListings }
})
