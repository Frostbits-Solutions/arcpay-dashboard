import { h, ref } from 'vue'
import { defineStore } from 'pinia'
import {
  getAccount,
  getAccountAddresses,
  getAccountSecrets,
  getAccountChainsParameters, getAccountSubscription,
  getAccountUsers,
  getAllAccounts,
} from '@/features/accounts/services/accounts'
import { useSessionStore } from '@/features/auth/stores/session'
import type { Tables } from '@/lib/supabase/database.types'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import { useToast } from '@/lib/ui/toast'
import type { Account, AccountAddress, AccountCurrency, AccountMembership, AccountChainParameter, AccountSecret, AccountUser, SubscriptionTier } from '@/models'

interface AccountSettings{
  settings?: Account | null
  subscription_id?: number;
  subscription_expiration_date?: string | null;
  subscription_tiers?: Partial<SubscriptionTier> | null
  users?: Omit<AccountUser, 'account_id'>[]
  secrets?: AccountSecret[]
  addresses?: AccountAddress[]
  chainsParameters?: AccountChainParameter[]
  currencies?: AccountCurrency[]
}

export const useAccountsStore = defineStore('accounts', () => {
  const {toast} = useToast()
  const all = ref<AccountMembership[]>([])
  const loading = ref(false)
  const active = ref<AccountMembership | undefined>()
  const activeSettings = ref<AccountSettings>({})

  async function fetchAll() {
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

  function selectAccount(id: string) {
    const account = all.value.find(a => a.id === id)
    if (account) {
      loading.value = true
      active.value = account
      Promise.allSettled([
        fetchAccountSettings(account.id),
        fetchAccountUsers(account.id),
        fetchAccountAddresses(account.id),
        fetchAccountSubscription(account.id),
        fetchAccountSecrets(account.id),
        fetchAccountChainsParameters(account.id),
      ]).then(() => {
        loading.value = false
      })
    }
  }

  async function fetchAccountSettings(accountId: string) {
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

  async function fetchAccountSubscription(accountId: string) {
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
      activeSettings.value.subscription_id = data.subscription_id
      activeSettings.value.subscription_expiration_date = data.subscription_expiration_date
      activeSettings.value.subscription_tiers = data.subscription_tiers
    }
  }

  async function fetchAccountUsers(accountId: string) {
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

  async function fetchAccountAddresses(accountId: string) {
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

  async function fetchAccountSecrets(accountId: string) {
    const { data: secrets, error } = await getAccountSecrets(accountId)
    if (!secrets || error) {
      console.error(error)
      toast({
        title: 'Error fetching account secrets',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      activeSettings.value.secrets = secrets
    }
  }
  
  async function fetchAccountChainsParameters(accountId: string) {
    const { data: chainsParameters, error } = await getAccountChainsParameters(accountId)
    if (error) {
      console.error(error)
      toast({
        title: 'Error fetching account chains paramaters',
        description: error?.message || 'Unexpected error',
        variant: 'destructive',
        action: h(ToastError)
      })
    } else {
      activeSettings.value.chainsParameters = chainsParameters ?? []
    }
  }

  
  return { all, active, activeSettings, loading, fetchAll, fetchAccountSettings, fetchAccountUsers, fetchAccountAddresses, fetchSubscriptionChainsParameters: fetchAccountChainsParameters, fetchAccountSecrets, selectAccount }
})
