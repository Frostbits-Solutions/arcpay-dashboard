<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useNetworksStore } from '@/features/networks/stores/networks'
import { Trash2 } from 'lucide-vue-next'
import { Button } from '@/lib/ui/button'
import { Badge } from '@/lib/ui/badge'
import CurrencySelectionCombobox from '@/features/currencies/components/CurrencySelectionCombobox.vue'
import { type Database } from '@/lib/supabase/database.types'
import { useCurrenciesStore } from '@/features/currencies/stores/currencies'

type Currency = Database['public']['Tables']['currencies']['Row']

const props = defineProps({
  activeChain: {
    type: String,
    required: true,
  },
})

const accounts = useAccountsStore()
const networks = useNetworksStore()
const currencySelectorRef = ref<typeof CurrencySelectionCombobox | null>(null)
const currencyStore = useCurrenciesStore()
const hasProSubscription = computed(() => accounts.activeSettings.subscription_tiers?.allow_custom_currencies ?? false)

const listedPublicCurrencies = computed(() => {
  return currencyStore.list.filter((currency: Currency) => {
    return props.activeChain === currency.chain_id && currency.is_public
  })
})

const listedPrivateCurrencies = computed(() => {
  return currencyStore.list.filter((currency: Currency) => {
    return props.activeChain === currency.chain_id && currency.is_public
  })
})

watch(
  () => props,
  () => {
    console.log('Active chain tab changed:', props.activeChain)
    currencyStore.fetchCurrencies()
    console.log('Listed currencies:', currencyStore.list)
  },
  { immediate: true, deep: true }
)

//TODO
// Reuse the component from CurrencySelectionCombobox.vue
// to allow adding custom currencies for each chain
// Import only the files not already present in the repo
// in the table display all public currencies and allow adding private currencies
// added private currencies can be deleted
// add an emit in the CurrencySelectionCombobox.vue to emit the selected currency and import it
</script>
<template>
  <div v-if="hasProSubscription">
    <div class="relative rounded-lg border border-border bg-muted/50 p-8 text-left">
      <h4 class="text-md mb-2 flex items-center gap-2 font-normal">
        Add custom currencies
        <Badge variant="gradient">PRO</Badge>
      </h4>
      <p class="mb-6 text-sm text-muted-foreground">List of all supported chains for your organization. You can add currencies for each chain.</p>
      <CurrencySelectionCombobox :active-chain="props.activeChain" ref="currencySelectorRef" />

      <div class="overflow-hidden rounded-lg border border-border bg-background">
        <table class="w-full text-left text-sm text-muted-foreground rtl:text-right">
          <thead class="border-b text-xs text-muted-foreground/50">
            <tr>
              <th scope="col" class="px-6 py-3">Icon</th>
              <th scope="col" class="px-6 py-3">Chain</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(currency, index) in listedPublicCurrencies" :key="currency.id">
              <td class="px-6 py-4"><img :src="currency.icon" alt="Icone" width="24" height="24" /></td>
              <td class="px-6 py-4">{{ currency.name }}</td>
              <td class="px-6 py-4 text-center">
                <div class="flex items-center justify-center gap-2">
                  <span class="rounded-md bg-muted px-2 py-1 text-xs font-medium text-muted-foreground"> Default </span>
                </div>
              </td>
            </tr>
            <tr v-for="(currency, index) in listedPrivateCurrencies" :key="currency.id">
              <td class="px-6 py-4"><img :src="currency.icon" alt="Icone" width="24" height="24" /></td>
              <td class="px-6 py-4">{{ currency.name }}</td>
              <td class="px-6 py-4 text-center">
                <div class="flex items-center justify-center gap-2">
                  <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="">
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
