<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useListingsStore } from '@/features/listings/stores/listings'
import type { ListingDetail } from '@repo/supabase/models'
import { columns } from '@/features/listings/components/listings-table/columns'
import { DataTable } from '@repo/ui/data-table'

const listingsStore = useListingsStore()
const accounts = useAccountsStore()

const listings = computed<ListingDetail[]>(() => listingsStore.list || [])
const primaryAddresses = computed<string[]>(() => accounts.activeSettings.addresses?.map((a) => a.address) || [])

const primaryListings = computed(() => listings.value.filter((listing) => primaryAddresses.value.includes(listing.creator_address)))
const secondaryListings = computed(() => listings.value.filter((listing) => !primaryAddresses.value.includes(listing.creator_address)))

onMounted(async () => {
  await listingsStore.fetchListings()
})
</script>

<template>
  <main class="min-h-dvh pl-16 pt-16">
    <div class="mx-auto max-w-screen-xl p-10">
      <h4 class="text-2xl font-bold text-foreground">Listings</h4>
      <h2 class="mb-2 mt-10 flex justify-between text-lg font-semibold text-foreground dark:text-white">
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
      <DataTable :columns="columns" :data="primaryListings" />

      <h2 class="mb-2 mt-10 flex justify-between text-lg font-semibold text-foreground">
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
      <DataTable :columns="columns" :data="secondaryListings" />
    </div>
  </main>
</template>

<style scoped></style>
