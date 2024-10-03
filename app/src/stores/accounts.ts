import { h, ref } from 'vue'
import { defineStore } from 'pinia'
import {
  getAccount,
  getAccountAddresses,
  getAccountApiKeys, getAccountSubscription,
  getAccountUsers,
  getAllAccounts
} from '@/lib/supabase/accounts'
import { useSessionStore } from '@/stores/session'
import type { Database } from '@/lib/supabase/database.types'
import ToastError from '@/components/ui/toast/ToastError.vue'
import { useToast } from '@/components/ui/toast'

type Account = { id: number, name: string }
interface AccountSettings{
  settings?: Database["public"]["Tables"]["accounts"]["Row"] | undefined
  subscription?: Database["public"]["Tables"]["subscription_tiers"]["Row"] | undefined
  users?: {
    role: Database["public"]["Tables"]["accounts_users_association"]["Row"]["role"],
    user_email: Database["public"]["Tables"]["accounts_users_association"]["Row"]["user_email"],
    created_at: Database["public"]["Tables"]["accounts_users_association"]["Row"]["created_at"],
  }[] | undefined
  keys?: Database["public"]["Tables"]["accounts_api_keys"]["Row"][] | undefined
  addresses?: Database["public"]["Tables"]["accounts_addresses"]["Row"][] | undefined
}

export const useAccountsStore = defineStore('accounts', () => {
  const {toast} = useToast()
  const all = ref<Account[]>([])
  const loading = ref(false)
  const active = ref<Account | undefined>()
  const activeSettings = ref<AccountSettings>({})

  async function fetchAll() {
    // fetch all accounts
    const session = useSessionStore()
    if (session?.user?.email) {
      const { data, error } = await getAllAccounts(session.user.email)
      if (error) {
        console.error(error)
        toast({
          title: 'Error fetching organizations',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError)
        })
      } else {
        all.value = data || []
        if (active.value == null && data?.[0]) {
          await selectAccount(data?.[0].id)
        }
      }
    } else {
      toast({
        title: 'No user session',
        description: 'Please login and try again',
        variant: 'destructive',
        action: h(ToastError)
      })
    }
  }

  function selectAccount(id: number) {
    const account = all.value.find(a => a.id === id)
    if (account) {
      loading.value = true
      active.value = account
      Promise.allSettled([
        fetchAccountSettings(account.id),
        fetchAccountUsers(account.id),
        fetchAccountAddresses(account.id),
        fetchAccountKeys(account.id),
        fetchAccountSubscription(account.id)
      ]).then(() => {
        loading.value = false
      })
    }
  }

  async function fetchAccountSettings(accountId: number) {
    const { data: settings, error } = await getAccount(accountId)
    if (!settings || error) {
      console.error(error)
      toast({
        title: 'Error fetching account organization',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      activeSettings.value.settings = settings
    }
  }

  async function fetchAccountSubscription(accountId: number) {
    const { data, error } = await getAccountSubscription(accountId)
    if (!data || error) {
      console.error(error)
      toast({
        title: 'Error fetching account subscription',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      activeSettings.value.subscription = data
    }
  }

  async function fetchAccountUsers(accountId: number) {
    const { data: users, error } = await getAccountUsers(accountId)
    if (!users || error) {
      console.error(error)
      toast({
        title: 'Error fetching account users',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      activeSettings.value.users = users
    }
  }

  async function fetchAccountKeys(accountId: number) {
    const { data: keys, error } = await getAccountApiKeys(accountId)
    if (!keys || error) {
      console.error(error)
      toast({
        title: 'Error fetching account api keys',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      activeSettings.value.keys = keys
    }
  }

  async function fetchAccountAddresses(accountId: number) {
    const { data: addresses, error } = await getAccountAddresses(accountId)
    if (!addresses || error) {
      console.error(error)
      toast({
        title: 'Error fetching account addresses',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      activeSettings.value.addresses = addresses
    }
  }

  return { all, active, activeSettings, loading, fetchAll, fetchAccountSettings, fetchAccountUsers, fetchAccountKeys, fetchAccountAddresses, selectAccount }
})
