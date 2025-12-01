<script setup lang="ts">
import { ref, computed, watch, h } from 'vue'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { Trash2 } from 'lucide-vue-next'
import { Button } from '@repo/ui/button'
import { Badge } from '@repo/ui/badge'
import CurrencySelectionCombobox from '@/features/currencies/components/CurrencySelectionCombobox.vue'
import { addAccountCurrency, removeAccountCurrency } from '@/services/accounts'
import { toast } from '@repo/ui/toast'
import { ToastCheck } from '@repo/ui/toast'
import { getCurrencies } from '@/services/currencies'
import { errorHandler } from '@/lib/errorHandler'
import DefautCurrencyIcon from '@repo/ui/assets/currency.svg'
import { type Currency } from '@repo/supabase/models'

const props = defineProps({
  selectedNetwork: {
    type: String,
    required: true,
  },
})

const accounts = useAccountsStore()
const canImport = ref(false)
const networkCurrencies = ref<Currency[]>([])
const currencySelected = ref<Currency | null>(null)
const hasProSubscription = computed(() => accounts.activeSettings.subscription_tiers?.allow_custom_currencies ?? false)

const listedPublicCurrencies = computed(() => {
  return networkCurrencies.value.filter((currency: Currency) => {
    return currency.is_public
  })
})

const listedPrivateCurrencies = computed(() => {
  return networkCurrencies.value.filter((currency: Currency) => {
    return !currency.is_public && accounts.activeSettings.currencies?.some((c) => c.currency === currency.id)
  })
})

const listedPrivateCurrenciesIds = computed(() => {
  return listedPrivateCurrencies.value?.map((currency: Currency) => currency.id)
})

async function fetchCurrencies() {
  const { data, error } = await getCurrencies(props.selectedNetwork)
  if (!data || error) {
    errorHandler(error, `Unable to fetch currencies for ${props.selectedNetwork}.`)
  } else {
    networkCurrencies.value = data
  }
}

async function addCurrencyToAccount() {
  if (!accounts.active || !currencySelected.value) return
  await addAccountCurrency(accounts.active.id, currencySelected.value.id, props.selectedNetwork)
    .then(async () => {
      resetCurrencySettings()
      await fetchCurrencies()
      // Show success toast
      toast({
        title: `Successfully imported currency`,
        action: h(ToastCheck),
      })
    })
    .catch((error) => errorHandler(error, `Error importing currency`))
}

async function removeCurrencyFromAccount(currencyId: number) {
  if (!accounts.active) return
  await removeAccountCurrency(accounts.active.id, currencyId, props.selectedNetwork)
    .then(async () => {
      resetCurrencySettings()
      await fetchCurrencies()
      // Show success toast
      toast({
        title: `Successfully removed currency`,
        action: h(ToastCheck),
      })
    })
    .catch((error) => errorHandler(error, `Error removing currency`))
}

function handleCurrencySelect(currency: Currency) {
  currencySelected.value = currency
  canImport.value = true
}

function resetCurrencySettings() {
  if (!accounts.active) return
  accounts.fetchAccountCurrencies(accounts.active.id)
  currencySelected.value = null
  canImport.value = false
}

watch(
  () => props.selectedNetwork,
  () => {
    resetCurrencySettings()
    fetchCurrencies()
  },
  { immediate: true }
)
</script>
<template>
  <div class="mt-6">
    <div class="rounded-lg border border-border bg-muted/50 p-4">
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-md font-normal">Custom currencies <Badge variant="gradient">PRO</Badge></h4>
          <p class="text-sm text-muted-foreground">
            Choose which currencies users can use to create listings. <br />
            <template v-if="!hasProSubscription || accounts.loading">Upgrade to PRO to enable custom currencies.</template>
          </p>
        </div>
      </div>
    </div>
    <div v-if="hasProSubscription && !accounts.loading" class="mt-2 rounded-lg border border-border p-4" v-motion-fade>
      <div class="flex items-center justify-between">
        <label class="text-sm font-medium text-muted-foreground">Import currency</label>
        <div class="flex items-center gap-2">
          <CurrencySelectionCombobox :network="props.selectedNetwork" :exclude-currency-ids="listedPrivateCurrenciesIds" @select="handleCurrencySelect" />
          <Button variant="outline" :disabled="!canImport" @click="addCurrencyToAccount">Import</Button>
        </div>
      </div>
    </div>
    <div v-if="hasProSubscription && !accounts.loading" class="mt-2 rounded-lg border border-border p-4" v-motion-fade>
      <table class="w-full text-left text-sm text-muted-foreground rtl:text-right">
        <thead class="border-b text-xs text-muted-foreground/50">
          <tr>
            <th scope="col" class="px-6 py-3">Id</th>
            <th scope="col" class="w-full px-6 py-3">Currency</th>
            <th scope="col" class="px-6 py-3">Ticker</th>
            <th scope="col" class="px-6 py-3"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="currency in listedPublicCurrencies" :key="currency.id">
            <td class="px-6 py-4">{{ currency.id }}</td>
            <td class="flex w-full items-center gap-2 px-6 py-4 capitalize"><img :src="currency.icon ?? DefautCurrencyIcon" alt="icon" class="size-5" />{{ currency.name }}</td>
            <td class="px-6 py-4 uppercase">{{ currency.ticker }}</td>
            <td class="px-6 py-4 text-center text-muted-foreground">-</td>
          </tr>
          <tr v-for="currency in listedPrivateCurrencies" :key="currency.id">
            <td class="px-6 py-4">{{ currency.id }}</td>
            <td class="flex w-full items-center gap-2 px-6 py-4 capitalize"><img :src="currency.icon ?? DefautCurrencyIcon" alt="icon" class="size-5" />{{ currency.name }}</td>
            <td class="px-6 py-4 uppercase">{{ currency.ticker }}</td>
            <td class="px-6 py-4 text-center">
              <div class="flex items-center justify-center gap-2">
                <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="removeCurrencyFromAccount(currency.id)">
                  <Trash2 class="size-4 text-destructive" />
                </Button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped></style>
