<script setup lang="ts">

import { onMounted, computed } from 'vue'
import { useAccountsStore } from '@/stores/accounts'
import { useListingsStore } from '@/stores/listings'
import type { CompositeListing } from '@/models'
import { columns } from '@/components/listings-table/columns'
import { DataTable } from '@/components/ui/data-table'

const listingsStore = useListingsStore()
const accounts = useAccountsStore()

const listings = computed<CompositeListing[]>(() => listingsStore.list || [])
const primaryAddresses = computed<string[]>(() => accounts.activeSettings.addresses?.map(a => a.address) || [])

const primaryListings = computed(() => listings.value.filter(listing => primaryAddresses.value.includes(listing.seller_address)))
const secondaryListings = computed(() => listings.value.filter(listing => !primaryAddresses.value.includes(listing.seller_address)))


onMounted(async () => {
  await listingsStore.fetchListings()
})

</script>

<template>
  <main class="min-h-dvh pl-16 pt-16">
    <div class="max-w-screen-xl mx-auto p-10">
      <h4 class="text-2xl font-bold text-foreground">Listings</h4>
      <h2 class="mb-2 text-lg font-semibold text-foreground dark:text-white flex justify-between mt-10">
        Primary listings
        <!--
        <span class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-1 rounded-[10px] dark:bg-green-900 dark:text-green-300">
            <span class="w-2 h-2 me-2 bg-green-500 rounded-full relative">
              <span class="w-2 h-2 bg-green-500 rounded-full animate-ping absolute"></span>
            </span>
            Real time
        </span>
        -->
      </h2>
      <DataTable :columns="columns" :data="primaryListings"/>

      <h2 class="mb-2 text-lg font-semibold text-foreground flex justify-between mt-10">
        Secondary listings
        <!--
        <span class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-1 rounded-[10px] dark:bg-green-900 dark:text-green-300">
            <span class="w-2 h-2 me-2 bg-green-500 rounded-full relative">
              <span class="w-2 h-2 bg-green-500 rounded-full animate-ping absolute"></span>
            </span>
            Real time
        </span>
        -->
      </h2>
      <DataTable :columns="columns" :data="secondaryListings"/>
    </div>
  </main>
</template>

<style scoped>

</style>