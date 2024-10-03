import { h, ref, watch } from 'vue'
import { defineStore } from 'pinia'
import ToastError from '@/components/ui/toast/ToastError.vue'
import { useToast } from '@/components/ui/toast'
import { useAccountsStore } from '@/stores/accounts'
import { useNetworksStore } from '@/stores/networks'
import { getListings } from '@/lib/supabase/listings'
import type { CompositeListing } from '@/models'



const { toast } = useToast()

export const useListingsStore = defineStore('listings', () => {
  const accounts = useAccountsStore()
  const networks = useNetworksStore()
  const loading = ref(false)
  const list = ref<CompositeListing[]>([])

  async function fetchListings() {
    if (accounts.active && networks.activeNetwork) {
      loading.value = true
      const { data, error } = await getListings(accounts.active.id, networks.activeNetwork)
      if (!data || error) {
        console.error(error)
        toast({
          title: 'Error fetching listings',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError)
        })
      } else {
        list.value = data as CompositeListing[]
      }
      loading.value = false
    }
  }

  watch(() => networks.activeNetwork, () => {fetchListings()})
  watch(() => accounts.active, () => {fetchListings()})

  return { loading, list, fetchListings }
})
