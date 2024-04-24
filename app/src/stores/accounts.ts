import { ref } from 'vue'
import type { Ref } from 'vue'
import { defineStore } from 'pinia'
import { getAllAccounts } from '@/lib/supabase/accounts'
import { useSessionStore } from '@/stores/session'

type account = { id: number, name: string }

export const useAccountsStore = defineStore('accounts', () => {
  const all: Ref<account[]> = ref([])
  const active: Ref<account | null> = ref(null)

  async function fetchAll() {
    // fetch all accounts
    const session = useSessionStore()
    if (session?.user?.email) {
      const { data, error } = await getAllAccounts(session.user.email)
      if (error) {
        console.error(error)
      } else {
        console.log("Fetching accounts", data)
        all.value = data || []
        if (active.value == null && data?.[0]) {
          active.value =  data?.[0]
        }
      }
    } else {
      console.error("No user session")
    }
  }

  function selectAccount(id: number) {
    const account = all.value.find(a => a.id === id)
    if (account) {
      active.value = account
    }
  }

  return { all, active, fetchAll, selectAccount }
})
