<script setup lang="ts">
import { useNetworksStore } from '@/features/networks/stores/networks'
import OrganizationSettingsListingsCurrencies from './OrganizationSettingsListingsCurrencies.vue'
import OrganizationSettingsListingsSecondary from './OrganizationSettingsListingsSecondary.vue'
import { computed, ref } from 'vue'

const networks = useNetworksStore()
const selectedNetworkTab = ref(0)
const selectedNetwork = computed(() => networks.networks[selectedNetworkTab.value])
</script>

<template>
  <div>
    <h2 class="text-2xl font-bold dark:text-white">Listings</h2>
    <p class="text-sm text-muted-foreground">Enable third party listings and add custom currencies to your account.</p>
    <div class="mt-10 flex rounded-lg border border-border px-4">
      <button
        v-for="(network, index) in networks.networks"
        :key="network"
        @click="selectedNetworkTab = index"
        :class="['mx-4 border-b-2 py-4 text-sm', selectedNetworkTab === index ? 'border-b-primary text-primary' : 'border-b-transparent text-muted-foreground']"
      >
        {{ network }}
      </button>
    </div>
    <div class="relative">
      <OrganizationSettingsListingsSecondary class="mb-4" :selected-network="selectedNetwork" />
      <OrganizationSettingsListingsCurrencies :selected-network="selectedNetwork" />
    </div>
  </div>
</template>

<style scoped></style>
