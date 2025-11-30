import { ref } from 'vue'
import { defineStore } from 'pinia'
import { getAccount, getAccountAddresses, getAccountSecrets, getAccountNetworksParameters, getAccountCurrencies, getAccountSubscription, getAccountUsers, getAllAccounts } from '@/services/accounts'
import { useSessionStore } from '@/features/auth/stores/session'
import { useToast } from '@repo/ui/toast'
import type { Account, AccountAddress, AccountCurrency, AccountMembership, AccountNetworkParameter, AccountSecret, AccountUser, SubscriptionTier } from '@repo/supabase/models'
import { errorHandler } from '@/lib/errorHandler'

interface AccountSettings {
  settings?: Account | null
  subscription_id?: number
  subscription_expiration_date?: string | null
  subscription_tiers?: Partial<SubscriptionTier> | null
  users?: Omit<AccountUser, 'account_id'>[]
  secrets?: AccountSecret[]
  addresses?: AccountAddress[]
  networksParameters?: AccountNetworkParameter[]
  currencies?: AccountCurrency[]
}

export const useAccountsStore = defineStore('accounts', () => {
  const { toast } = useToast()
  const all = ref<AccountMembership[]>([])
  const loading = ref(false)
  const active = ref<AccountMembership | undefined>()
  const activeSettings = ref<AccountSettings>({})

  async function fetchAll() {
    const session = useSessionStore()
    if (session?.user?.email) {
      const { data, error } = await getAllAccounts(session.user.email)
      if (error) {
        errorHandler(error, 'Error fetching organizations')
      } else {
        all.value = data || []
        if (active.value == null && data?.[0]) {
          await selectAccount(data?.[0].id)
        }
      }
    } else {
      errorHandler(new Error('Please login and try again'), 'No user session')
    }
  }

  function selectAccount(id: string) {
    const account = all.value.find((a) => a.id === id)
    if (account) {
      loading.value = true
      active.value = account
      Promise.allSettled([
        fetchAccountSettings(account.id),
        fetchAccountUsers(account.id),
        fetchAccountCurrencies(account.id),
        fetchAccountAddresses(account.id),
        fetchAccountSubscription(account.id),
        fetchAccountSecrets(account.id),
        fetchAccountNetworksParameters(account.id),
      ]).then(() => {
        loading.value = false
      })
    }
  }

  async function fetchAccountSettings(accountId: string) {
    const { data: settings, error } = await getAccount(accountId)
    if (!settings || error) {
      errorHandler(error, 'Error fetching organization settings')
    } else {
      activeSettings.value.settings = settings
    }
  }

  async function fetchAccountSubscription(accountId: string) {
    const { data, error } = await getAccountSubscription(accountId)
    if (!data || error) {
      errorHandler(error, 'Error fetching organization subscription')
    } else {
      activeSettings.value.subscription_id = data.subscription_id
      activeSettings.value.subscription_expiration_date = data.subscription_expiration_date
      activeSettings.value.subscription_tiers = data.subscription_tiers
    }
  }

  async function fetchAccountUsers(accountId: string) {
    const { data: users, error } = await getAccountUsers(accountId)
    if (!users || error) {
      errorHandler(error, 'Error fetching organization users')
    } else {
      activeSettings.value.users = users
    }
  }

  async function fetchAccountAddresses(accountId: string) {
    const { data: addresses, error } = await getAccountAddresses(accountId)
    if (!addresses || error) {
      errorHandler(error, 'Error fetching organization addresses')
    } else {
      activeSettings.value.addresses = addresses
    }
  }

  async function fetchAccountSecrets(accountId: string) {
    const { data: secrets, error } = await getAccountSecrets(accountId)
    if (!secrets || error) {
      errorHandler(error, 'Error fetching organization secrets')
    } else {
      activeSettings.value.secrets = secrets
    }
  }

  async function fetchAccountNetworksParameters(accountId: string) {
    const { data: networksParameters, error } = await getAccountNetworksParameters(accountId)
    if (error) {
      errorHandler(error, 'Error fetching organization networks parameters')
    } else {
      activeSettings.value.networksParameters = networksParameters ?? []
    }
  }

  async function fetchAccountCurrencies(accountId: string) {
    const { data: currencies, error } = await getAccountCurrencies(accountId)
    if (!currencies || error) {
      errorHandler(error, 'Error fetching organization currencies')
    } else {
      activeSettings.value.currencies = currencies
    }
  }

  return {
    all,
    active,
    activeSettings,
    loading,
    fetchAll,
    fetchAccountSettings,
    fetchAccountUsers,
    fetchAccountAddresses,
    fetchSubscriptionNetworksParameters: fetchAccountNetworksParameters,
    fetchAccountSecrets,
    selectAccount,
    fetchAccountCurrencies,
  }
})
