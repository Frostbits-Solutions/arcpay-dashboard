<script setup lang="ts">
import { ref, computed, watch, h } from 'vue'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useNetworksStore } from '@/features/networks/stores/networks'
import { Trash2 } from 'lucide-vue-next'
import { Button } from '@/lib/ui/button'
import { Badge } from '@/lib/ui/badge'
import CurrencySelectionCombobox from '@/features/currencies/components/CurrencySelectionCombobox.vue'
import { type Database } from '@/lib/supabase/database.types'
import { useCurrenciesStore } from '@/features/currencies/stores/currencies'
import { addAccountCurrency, removeAccountCurrency } from '../services/accounts'
import { toast } from '@/lib/ui/toast'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import ToastError from '@/lib/ui/toast/ToastError.vue'

type Currency = Database['public']['Tables']['currencies']['Row']

const props = defineProps({
  activeChain: {
    type: String,
    required: true,
  },
})

const accounts = useAccountsStore()
const networks = useNetworksStore()
const currencyStore = useCurrenciesStore()
const currencySelected = ref<Currency | null>(null)
const hasProSubscription = computed(() => accounts.activeSettings.subscription_tiers?.allow_custom_currencies ?? false)

const listedPublicCurrencies = computed(() => {
  return currencyStore.list.filter((currency: Currency) => {
    return props.activeChain === currency.chain_id && currency.is_public
  })
})

const listedPrivateCurrencies = computed(() => {
  return currencyStore.list.filter((currency: Currency) => {
    return props.activeChain === currency.chain_id && !currency.is_public && accounts.activeSettings.currencies?.some((c) => c.currency === currency.id)
  })
})

const listedPrivateCurrenciesIds = computed(() => {
  return listedPrivateCurrencies.value.map((currency: Currency) => currency.id)
})

function AddCurrencyToUser() {
  if (!accounts.active || !currencySelected.value) return

  addAccountCurrency(accounts.active.id, currencySelected.value.id, props.activeChain)
    .then(() => {
      resetCurrencySettings()
      // Show success toast
      toast({
        title: `Successfully imported currency`,
        action: h(ToastCheck),
      })
    })
    .catch((error) => {
      // Show error toast
      toast({
        title: `Error importing currency`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError),
      })
    })
}

function removeCurrencyToUser(currencyId: number) {
  console.log('Removing currency with ID:', currencyId)
  if (!accounts.active) return

  removeAccountCurrency(accounts.active.id, currencyId, props.activeChain)
    .then(() => {
      resetCurrencySettings()
      // Show success toast
      toast({
        title: `Successfully removed currency`,
        action: h(ToastCheck),
      })
    })
    .catch((error) => {
      toast({
        title: `Error removing currency`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError),
      })
    })
}

function handleCurrencySelect(currency: Currency) {
  currencySelected.value = currency
  canImport.value = true
  // You can do anything with the selectedCurrency object here
}

function resetCurrencySettings() {
  if (!accounts.active) return

  accounts.fetchAccountCurrencies(accounts.active.id)
  currencyStore.fetchCurrencies(props.activeChain)
  currencySelected.value = null
  canImport.value = false
}

const canImport = ref(false)

watch(
  () => props,
  () => {
    resetCurrencySettings()
  },
  { immediate: true, deep: true }
)
</script>
<template>
  <div v-if="hasProSubscription">
    <div class="relative rounded-lg border border-border bg-muted/50 p-8 text-left">
      <h4 class="text-md mb-2 flex items-center gap-2 font-normal">
        Add custom currencies
        <Badge variant="gradient">PRO</Badge>
      </h4>
      <p class="mb-4 text-sm text-muted-foreground">List of all supported chains for your organization. You can add currencies for each chain.</p>
      <div class="mb-4 flex items-center justify-between">
        <label class="text-sm font-medium text-muted-foreground">Select a currency to import:</label>
        <div class="flex items-center gap-2">
          <CurrencySelectionCombobox :active-chain="props.activeChain" :exclude-currency-ids="listedPrivateCurrenciesIds" @select="handleCurrencySelect" />
          <Button variant="outline" :disabled="!canImport" @click="AddCurrencyToUser">Import</Button>
        </div>
      </div>
      <div class="mt-4 overflow-hidden rounded-lg border border-border bg-background">
        <table class="w-full text-left text-sm text-muted-foreground rtl:text-right">
          <thead class="border-b text-xs text-muted-foreground/50">
            <tr>
              <th scope="col" class="px-6 py-3">Icon</th>
              <th scope="col" class="px-6 py-3">Name</th>
              <th scope="col" class="px-6 py-3">Ticker</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(currency, index) in listedPublicCurrencies" :key="currency.id">
              <td class="px-6 py-4"><img :src="currency.icon" alt="Icone" width="24" height="24" /></td>
              <td class="px-6 py-4">{{ currency.name }}</td>
              <td class="px-6 py-4">{{ currency.ticker }}</td>
              <td class="px-6 py-4 text-center">
                <div class="flex items-center justify-center gap-2">
                  <span class="rounded-md bg-muted px-2 py-1 text-xs font-medium text-muted-foreground"> Default </span>
                </div>
              </td>
            </tr>
            <tr v-for="(currency, index) in listedPrivateCurrencies" :key="currency.id">
              <td class="px-6 py-4"><img :src="currency.icon" alt="Icone" width="24" height="24" /></td>
              <td class="px-6 py-4">{{ currency.name }}</td>
              <td class="px-6 py-4">{{ currency.ticker }}</td>
              <td class="px-6 py-4 text-center">
                <div class="flex items-center justify-center gap-2">
                  <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="removeCurrencyToUser(currency.id)">
                    <Trash2 class="size-4 text-destructive" />
                  </Button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
  <div v-else>
    <div class="relative rounded-lg border border-border bg-muted/50 p-4 text-left">
      <div class="flex items-center justify-between">
        <h4 class="text-md mb-2 flex items-center gap-2 font-normal">
          Add custom currencies
          <Badge variant="gradient">PRO</Badge>
        </h4>
      </div>
      <p class="mb-6 text-sm text-muted-foreground">This feature is available exclusively for PRO subscribers.</p>
    </div>
  </div>
</template>

<style scoped></style>
