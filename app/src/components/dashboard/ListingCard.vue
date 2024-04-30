<script setup lang="ts">
import type { Database } from '@/lib/supabase/database.types'
import type { PropType } from 'vue'


type Listing = Database["public"]["Tables"]["listings"]["Row"] & {
  sales: Database["public"]["Tables"]["sales"]["Row"][],
  auctions: Database["public"]["Tables"]["auctions"]["Row"][]
}

const props = defineProps({
  listing: {
    type: Object as PropType<Listing>,
    required: true
  }
})
</script>

<template>
  <a :href="`./listing/${listing.id}`" target="_blank" class="flex justify-start items-center py-4 mb-5 border border-gray-100 text-gray-700 dark:text-gray-100 rounded-lg hover:shadow dark:hover:bg-gray-700 animate-slide-in-bottom dark:border-gray-700">
    <div class="max-w-80 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-400 text-xs">Id</div>
      <div class="truncate">{{ listing.id }}</div>
    </div>
    <div class="w-32 px-5 text-sm border-l border-gray-100 dark:border-gray-700 text-center">
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
    <div class="w-24 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-400 text-xs">Type</div>
      <div class="truncate capitalize">{{ listing.listing_type }}</div>
    </div>
    <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-400 text-xs">App id</div>
      <div class="truncate">{{ listing.app_id }}</div>
    </div>
    <div class="w-40 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-400 text-xs">Asset id</div>
      <div class="truncate">{{ listing.asset_id }}</div>
    </div>
    <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-400 text-xs">Asset type</div>
      <div class="truncate">{{ listing.asset_type }}</div>
    </div>
    <div class="max-w-64 border-l px-5 border-gray-100 text-sm grow dark:border-gray-700">
      <div class="text-gray-400 text-xs">Name</div>
      <div class="truncate">{{ listing.listing_name }}</div>
    </div>
  </a>
</template>

<style scoped>

</style>