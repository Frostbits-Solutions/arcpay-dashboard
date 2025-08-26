<script setup lang="ts">
import { useNetworksStore } from '@/features/networks/stores/networks'
import OrganizationSettingsCurrencies from './OrganizationSettingsCurrencies.vue'
import OrganizationSettingsListingsSecondary from './OrganizationSettingsListingsSecondary.vue'
import { computed, ref } from 'vue'

const networks = useNetworksStore()
const chains = computed(() => networks.networks)
const activeChainTab = ref(0)
const activeChain = computed(() => chains.value[activeChainTab.value])
</script>

<template>
  <div>
    <h2 class="text-2xl font-bold dark:text-white">Listings</h2>
    <p class="text-sm text-muted-foreground">Enable third party listings and add custom currencies to your account.</p>
    <div class="mt-4 flex border-b border-border">
      <button
        v-for="(chain, index) in chains"
        :key="chain"
        @click="activeChainTab = index"
        :class="['px-4 py-2 text-sm', activeChainTab === index ? 'border-b-2 border-primary text-primary' : 'text-muted-foreground']"
      >
        {{ chain }}
      </button>
    </div>
    <div class="relative">
      <OrganizationSettingsListingsSecondary class="mb-4" :active-chain="activeChain" />
      <OrganizationSettingsCurrencies :active-chain="activeChain" />
    </div>
  </div>
</template>

<style scoped></style>
