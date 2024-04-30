<script setup lang="ts">

import { onMounted, ref, watch, computed } from 'vue'
import { getListings } from '@/lib/supabase/listings'
import type { Database } from '@/lib/supabase/database.types'
import ListingCard from '@/components/dashboard/ListingCard.vue'
import { useAccountsStore } from '@/stores/accounts'
import { getAccountAddresses } from '@/lib/supabase/accounts'

type Listing = Database["public"]["Tables"]["listings"]["Row"] & {
  sales: Database["public"]["Tables"]["sales"]["Row"][],
  auctions: Database["public"]["Tables"]["auctions"]["Row"][]
}

const listings = ref<Listing[]>([])
const account = useAccountsStore()
const primaryAddresses = ref<string[]>([])
const primaryListings = computed(() => listings.value.filter(listing => primaryAddresses.value.includes(listing.seller_address)))
const secondaryListings = computed(() => listings.value.filter(listing => !primaryAddresses.value.includes(listing.seller_address)))

async function fetchListings() {
  const {data, error} = await getListings()
  if (error) {
    console.error(error)
  } else {
    listings.value = data || []
  }
}

async function fetchPrimaryAddresses() {
  if (!account.active) return
  const {data, error} = await getAccountAddresses(account?.active?.id)
  if (data) {
    primaryAddresses.value = data.map((address: any) => address.address)
  } else {
    console.error(error)
  }
}

watch(() => account.active, async () => {
  await fetchListings()
  await fetchPrimaryAddresses()
})

onMounted(async () => {
  await fetchListings()
  await fetchPrimaryAddresses()
})

</script>

<template>
  <main class="min-h-dvh pl-16 pt-16">
    <div class="max-w-screen-xl mx-auto p-10">
      <h4 class="text-2xl font-bold dark:text-white">Listings</h4>
      <div class="mt-12 w-full rounded-lg border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800">
        <h2 class="mb-2 text-lg font-semibold text-gray-900 dark:text-white flex justify-between">
          Primary listings
          <span class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">
            <span class="w-2 h-2 me-1 bg-green-500 rounded-full animate-pulse"></span>
            Real time
          </span>
        </h2>
        <ul class="mt-10">
          <li v-for="(listing, index) in primaryListings" :key="listing.id">
            <ListingCard :listing="listing" :style="`animation-delay: ${index * 100}ms; animation-fill-mode: both`"/>
          </li>
          <li v-if="!primaryListings?.length">
            <span class="flex justify-start items-center py-4 mb-5 border border-gray-100 text-gray-700 dark:text-gray-100 rounded-lg hover:shadow-lg dark:hover:bg-gray-700 animate-slide-in-bottom dark:border-gray-700">
              <div class="max-w-80 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Id</div>
                <div class="w-72 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-32 px-5 border-l border-gray-100">
                <div class="w-12 h-5 bg-gray-200 rounded-full dark:bg-gray-700 mx-auto"></div>
              </div>
              <div class="w-24 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Type</div>
                <div class="w-12 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">App id</div>
                <div class="w-16 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-40 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Asset id</div>
                <div class="w-32 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Asset type</div>
                <div class="w-16 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="max-w-64 border-l px-5 border-gray-100 text-sm grow dark:border-gray-700">
                <div class="text-gray-400 text-xs">Name</div>
                <div class="w-42 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
            </span>
          </li>
        </ul>
      </div>
      <div class="mt-12 w-full rounded-lg border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800">
        <h2 class="mb-2 text-lg font-semibold text-gray-900 dark:text-white flex justify-between">
          Secondary listings
          <span class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">
            <span class="w-2 h-2 me-1 bg-green-500 rounded-full animate-pulse"></span>
            Real time
          </span>
        </h2>
        <ul class="mt-10">
          <li v-for="(listing, index) in secondaryListings" :key="listing.id">
            <ListingCard :listing="listing" :style="`animation-delay: ${index * 100}ms; animation-fill-mode: both`"/>
          </li>
          <li v-if="!secondaryListings?.length">
            <span class="flex justify-start items-center py-4 mb-5 border border-gray-100 text-gray-700 dark:text-gray-100 rounded-lg hover:shadow-lg dark:hover:bg-gray-700 animate-slide-in-bottom dark:border-gray-700">
              <div class="max-w-80 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Id</div>
                <div class="w-72 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-32 px-5 border-l border-gray-100">
                <div class="w-12 h-5 bg-gray-200 rounded-full dark:bg-gray-700 mx-auto"></div>
              </div>
              <div class="w-24 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Type</div>
                <div class="w-12 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">App id</div>
                <div class="w-16 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-40 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Asset id</div>
                <div class="w-32 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-400 text-xs">Asset type</div>
                <div class="w-16 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="max-w-64 border-l px-5 border-gray-100 text-sm grow dark:border-gray-700">
                <div class="text-gray-400 text-xs">Name</div>
                <div class="w-42 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
            </span>
          </li>
        </ul>
      </div>
    </div>
  </main>
</template>

<style scoped>

</style>