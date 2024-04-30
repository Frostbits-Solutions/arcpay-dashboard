<script lang="ts" setup>
import { useRoute } from 'vue-router'
import { onMounted, ref, computed } from 'vue'
import { getListingById } from '@/lib/supabase/listings'
import ButtonSpinner from '@/components/common/ButtonSpinner.vue'
import { supabase } from '@/lib/supabase/supabaseClient'
import { Client } from 'arcpay-sdk'

const route = useRoute()
const listingId = route.params.id as string
const listing = ref<any>(null)

const arcpay = new Client({
  client: supabase
})

const nftNavigatorLink = computed(() => {
  if(listing.value.asset_id?.split('/')?.[1]) {
    return `https://nftnavigator.xyz/collection/${listing.value.asset_id.split('/')[0]}/token/${listing.value.asset_id.split('/')[1]}`
  } else {
    return '#'
  }
})

function handleBuy() {
  if(listing.value?.id) {
    if (listing.value?.listing_type === 'auction') {
      return arcpay.bid(listing.value.id)
    } else {
      arcpay.buy(listing.value.id)
    }
  }
}

onMounted(async () => {
  if (listingId) {
    const { data, error } = await getListingById(listingId)
    if (data) {
      listing.value = data
    } else {
      console.error(error)
    }
  }
})
</script>

<template>
  <div class="flex justify-center items-center h-screen bg-gray-50">
    <div class="flex flex-col w-full max-w-sm">
      <div class="pb-4 w-72  m-auto text-center" v-if="listing">
        <div class="m-auto w-fit flex items-center relative ap-left-[20px]">
          <img class="w-8 h-8" src="/src/assets/logo.png" >
          <h1 class="ml-2 text-2xl dark:text-white">Arcpay</h1>
        </div>
      </div>
      <a :href="nftNavigatorLink" target="_blank"
         class="w-full max-w-sm px-12 py-8 bg-white border border-gray-200 rounded-lg shadow-sm dark:bg-gray-800 dark:border-gray-700 animate-slide-in-bottom" v-if="listing">
        <div class="flex justify-between items-center">
          <div class="flex items-baseline text-gray-900 dark:text-white">
            <span class="text-5xl font-extrabold tracking-tight">{{ listing.min_price || listing.asking_price }}</span>
            <span class="ms-1 text-xl font-normal text-gray-500 dark:text-gray-400">{{ listing.listing_currency === 0 ? `ARC200(${listing.listing_currency})`:'VOI' }}</span>
          </div>
          <div class="my-7">
            <span v-if="['pending'].includes(listing.status)" class="inline-flex items-center bg-gray-100 text-gray-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-gray-700 dark:text-gray-300">
                <span class="w-2 h-2 me-1 bg-gray-500 rounded-full"></span>
                {{ listing.status }}
              </span>
              <span v-if="['active'].includes(listing.status)" class="inline-flex items-center bg-purple-100 text-purple-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-purple-900 dark:text-purple-300">
                <span class="w-2 h-2 me-1 bg-purple-500 rounded-full"></span>
                {{ listing.status }}
              </span>
              <span v-if="['closed'].includes(listing.status)" class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">
                <span class="w-2 h-2 me-1 bg-green-500 rounded-full"></span>
                {{ listing.status }}
              </span>
              <span v-if="['cancelled'].includes(listing.status)" class="inline-flex items-center bg-red-100 text-red-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-red-900 dark:text-red-300">
                <span class="w-2 h-2 me-1 bg-red-500 rounded-full"></span>
                {{ listing.status }}
              </span>
          </div>
        </div>
        <div class="flex border rounded">
          <img :src="`https://prod.cdn.highforge.io/t/${listing.asset_id}.webp`" alt="Listing image" class="w-full object-cover rounded-lg">
          <img :src="`https://prod.cdn.highforge.io/t/${listing.asset_id}.png`" alt="Listing image" class="w-full object-cover rounded-lg">
          <img :src="`https://prod.cdn.highforge.io/t/${listing.asset_id}.jpg`" alt="Listing image" class="w-full object-cover rounded-lg">
        </div>
        <ul class="space-y-5 text-xs p-5" role="list">
          <li class="flex items-center">
            <span class="text-gray-400">Listing name:</span>
            <span class="font-normal leading-tight text-gray-500 dark:text-gray-400 ms-3 capitalize">{{ listing.listing_name }}</span>
          </li>
          <li class="flex items-center">
            <span class="text-gray-400">Listing type:</span>
            <span class="font-normal leading-tight text-gray-500 dark:text-gray-400 ms-3 capitalize">{{ listing.listing_type }}</span>
          </li>
          <li class="flex items-center">
            <span class="text-gray-400">Asset type:</span>
            <span class="font-normal leading-tight text-gray-500 dark:text-gray-400 ms-3 capitalize">{{ listing.asset_type }}</span>
          </li>
          <li class="flex items-center">
            <span class="text-gray-400">Asset ID:</span>
            <span class="font-normal leading-tight text-gray-500 dark:text-gray-400 ms-3 capitalize">{{ listing.asset_id }}</span>
          </li>
        </ul>
        <button @click.prevent="handleBuy()" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-200 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-900 font-medium rounded-lg text-sm px-5 py-2.5 inline-flex justify-center w-full text-center"
                type="button">
          Buy
        </button>
      </a>
      <div class="text-sm text-gray-400 text-center">
        ID: {{ listingId }}
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>