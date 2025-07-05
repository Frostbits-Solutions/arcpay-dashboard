<script setup lang="ts">
import { ref, computed } from 'vue';
import { useAccountsStore } from '@/features/accounts/stores/accounts';
import { useNetworksStore } from '@/features/network/stores/networks';
import { Button } from '@/lib/ui/button';
import { Badge } from '@/lib/ui/badge';

const accounts = useAccountsStore();
const network = useNetworksStore();

const hasProSubscription = computed(() => accounts.activeSettings.subscription_tiers?.allow_custom_currencies ?? false);
const chains = computed(() => network.networks);
const activeChainTab = ref(0);
</script>

<template>
  <div>
    <h2 class="text-2xl font-bold text-foreground dark:text-white mb-6">Currencies</h2>
    <div v-if="hasProSubscription">
      <div class="border border-border bg-muted/50 rounded-lg p-8 text-left relative ">
        <h2 class="mb-2 text-lg font-semibold text-foreground dark:text-white flex justify-between">
          Manage currencies
          <Badge variant="gradient">PRO</Badge>
        </h2>
        <p class="text-sm text-muted-foreground mb-6">
          List of all supported chains for your organization. You can add currencies for each chain.
        </p>
        <div class="flex border-b border-border mb-4">
          <button
            v-for="(chain, index) in chains"
            :key="chain"
            @click="activeChainTab = index"
            :class="[
              'px-4 py-2 text-sm',
              activeChainTab === index ? 'border-b-2 border-primary text-primary' : 'text-muted-foreground',
            ]"
          >
            {{ chain }}
          </button>
        </div>
        <div class="rounded-lg border border-border overflow-hidden bg-background">
          <table class="w-full text-sm text-left rtl:text-right text-muted-foreground">
            <thead class="text-xs text-muted-foreground/50 border-b">
              <tr>
                <th scope="col" class="px-6 py-3">Chain</th>
                <th scope="col" class="px-6 py-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="chains.length" v-for="(chain, index) in chains" :key="chain" v-show="activeChainTab === index">
                <td class="px-6 py-4">{{ chain }}</td>
                <td class="px-6 py-4">
                  <Button variant="outline" disabled>Add currency (placeholder)</Button>
                </td>
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
      <div class="border border-border bg-muted/50 rounded-lg p-8 text-left relative ">
        <div class="flex items-center justify-between">
          <h4 class="text-lg font-semibold mb-2 flex items-center gap-2">
            Add custom currencies <Badge variant="gradient">PRO</Badge>
          </h4>
          <Button variant="gradient" class="mt-2">Upgrade to Pro</Button>
        </div>
        <p class="text-sm text-muted-foreground mb-6">
          This feature is available exclusively for PRO subscribers.
        </p>
        <div class="flex border-b border-border mb-4">
          <button
            v-for="(chain, index) in chains.slice(0, 2)"
            :key="chain"
            :class="[
              'px-4 py-2 text-sm',
              activeChainTab === index ? 'border-b-2 border-primary text-primary' : 'text-muted-foreground',
            ]"
            @click="activeChainTab = index"
            disabled
          >
            {{ chain }}
          </button>
        </div>
        <div class="opacity-60 blur-[1px] pointer-events-none select-none w-full mb-4">
          <table class="w-full text-sm text-left rtl:text-right text-muted-foreground">
            <thead class="text-xs text-muted-foreground/50 border-b">
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
        <p class="text-sm text-muted-foreground pt-4">
          Upgrade to PRO to manage currencies for your organization.
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
</style>
