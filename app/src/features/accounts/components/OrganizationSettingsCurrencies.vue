<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useNetworksStore } from '@/features/network/stores/networks'
import { Button } from '@/lib/ui/button'
import { Badge } from '@/lib/ui/badge'
import CurrencySelectionCombobox from '@/features/currencies/components/CurrencySelectionCombobox.vue'

const accounts = useAccountsStore()
const network = useNetworksStore()
const currencySelectorRef = ref<typeof CurrencySelectionCombobox | null>(null)

const hasProSubscription = computed(() => accounts.activeSettings.subscription_tiers?.allow_custom_currencies ?? false)
const chains = computed(() => network.networks)
const activeChainTab = ref(0)

//TODO
// Reuse the component from CurrencySelectionCombobox.vue
// to allow adding custom currencies for each chain
// Import only the files not already present in the repo
// in the table display all public currencies and allow adding private currencies
// added private currencies can be deleted
// add an emit in the CurrencySelectionCombobox.vue to emit the selected currency and import it
</script>
<template>
  <div>
    <h2 class="mb-6 text-2xl font-bold text-foreground dark:text-white">Currencies</h2>
    <div v-if="hasProSubscription">
      <div class="relative rounded-lg border border-border bg-muted/50 p-8 text-left">
        <h2 class="mb-2 flex justify-between text-lg font-semibold text-foreground dark:text-white">
          Manage currencies
          <Badge variant="gradient">PRO</Badge>
        </h2>
        <p class="mb-6 text-sm text-muted-foreground">List of all supported chains for your organization. You can add currencies for each chain.</p>
        <div class="mb-4 flex border-b border-border">
          <button
            v-for="(chain, index) in chains"
            :key="chain"
            @click="activeChainTab = index"
            :class="['px-4 py-2 text-sm', activeChainTab === index ? 'border-b-2 border-primary text-primary' : 'text-muted-foreground']"
          >
            {{ chain }}
          </button>
        </div>
        <div class="overflow-hidden rounded-lg border border-border bg-background">
          <table class="w-full text-left text-sm text-muted-foreground rtl:text-right">
            <thead class="border-b text-xs text-muted-foreground/50">
              <tr>
                <th scope="col" class="px-6 py-3">Chain</th>
                <th scope="col" class="px-6 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="chains.length" v-for="(chain, index) in chains" :key="chain" v-show="activeChainTab === index">
                <td class="px-6 py-4">{{ chain }}</td>
                <td class="px-6 py-4"><CurrencySelectionCombobox ref="currencySelectorRef" /></td>
              </tr>
              <tr v-if="!chains.length">
                <td colspan="2" class="px-6 py-4 text-center text-muted-foreground">No chains available</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div v-else>
      <div class="relative rounded-lg border border-border bg-muted/50 p-8 text-left">
        <div class="flex items-center justify-between">
          <h4 class="mb-2 flex items-center gap-2 text-lg font-semibold">
            Add custom currencies
            <Badge variant="gradient">PRO</Badge>
          </h4>
          <Button variant="gradient" class="mt-2">Upgrade to Pro</Button>
        </div>
        <p class="mb-6 text-sm text-muted-foreground">This feature is available exclusively for PRO subscribers.</p>
        <div class="mb-4 flex border-b border-border">
          <button
            v-for="(chain, index) in chains.slice(0, 2)"
            :key="chain"
            :class="['px-4 py-2 text-sm', activeChainTab === index ? 'border-b-2 border-primary text-primary' : 'text-muted-foreground']"
            @click="activeChainTab = index"
            disabled
          >
            {{ chain }}
          </button>
        </div>
        <div class="pointer-events-none mb-4 w-full select-none opacity-60 blur-[1px]">
          <table class="w-full text-left text-sm text-muted-foreground rtl:text-right">
            <thead class="border-b text-xs text-muted-foreground/50">
              <tr>
                <th scope="col" class="px-6 py-3">Chain</th>
                <th scope="col" class="px-6 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(chain, index) in chains" :key="chain" v-show="activeChainTab === index">
                <td class="px-6 py-4">{{ chain }}</td>
                <td class="px-6 py-4">
                  <Button variant="outline" disabled>Add currency</Button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <p class="pt-4 text-sm text-muted-foreground">Upgrade to PRO to manage currencies for your organization.</p>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
