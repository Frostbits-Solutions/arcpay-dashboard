import { h, ref, watch } from 'vue'
import { defineStore } from 'pinia'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import { useToast } from '@/lib/ui/toast'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useNetworksStore } from '@/features/networks/stores/networks'
import { getListings } from '@/services/listings'
import type { CompositeListing } from '@/lib/supabase/models'
import { supabase } from '@/lib/supabase/supabaseClient'

const { toast } = useToast()

export const useListingsStore = defineStore('listings', () => {
  const accounts = useAccountsStore()
  const networks = useNetworksStore()
  const loading = ref(false)
  const list = ref<CompositeListing[]>([])

  async function fetchListings() {
    if (accounts.active && networks.activeNetwork) {
      loading.value = true
      const { data, error } = await getListings(supabase, accounts.active.id, networks.activeNetwork.id)
      if (!data || error) {
        console.error(error)
        toast({
          title: 'Error fetching listings',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError),
        })
      } else {
        list.value = data as CompositeListing[]
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
