<script setup lang="ts">

import type { Database } from '@/lib/supabase/database.types'
import type { PropType } from 'vue'
import IconCurrency from '@/components/icons/IconCurrency.vue'

const props = defineProps({
  transaction: {
    type: Object as PropType<Database["public"]["Tables"]["transactions"]["Row"]>,
    required: true
  }
})
</script>

<template>
  <a :href="`https://voi.observer/explorer/transaction/${props.transaction.id}`" target="_blank" class="flex justify-start items-center py-4 mb-5 border border-gray-100 text-gray-700 dark:text-gray-100 rounded-lg hover:shadow dark:hover:bg-gray-700 animate-slide-in-bottom dark:border-gray-700">
    <div class="max-w-80 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-500 text-xs">Tx id</div>
      <div class="truncate">{{ props.transaction.id }}</div>
    </div>
    <div class="w-24 px-5 text-sm border-l border-gray-100">
        <span v-if="['create', 'fund'].includes(props.transaction.type)" class="inline-flex items-center bg-purple-100 text-purple-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-purple-900 dark:text-purple-300">
          <span class="w-2 h-2 me-1 bg-purple-500 rounded-full"></span>
          {{ props.transaction.type }}
        </span>
      <span v-if="['bid', 'buy'].includes(props.transaction.type)" class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">
          <span class="w-2 h-2 me-1 bg-green-500 rounded-full"></span>
          {{ props.transaction.type }}
        </span>
      <span v-if="['cancel'].includes(props.transaction.type)" class="inline-flex items-center bg-red-100 text-red-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-red-900 dark:text-red-300">
          <span class="w-2 h-2 me-1 bg-red-500 rounded-full"></span>
          {{ props.transaction.type }}
        </span>
    </div>
    <div class="max-w-80 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-500 text-xs">From</div>
      <div class="truncate">{{ props.transaction.from_address }}</div>
    </div>
    <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
      <div class="text-gray-500 text-xs">Amount</div>
      <div class="truncate">
        {{ props.transaction.amount }}
      </div>
    </div>
    <div class="max-w-64 border-l px-5 border-gray-100 text-sm grow dark:border-gray-700">
      <div class="text-gray-500 text-xs">Listing</div>
      <div class="truncate">{{ props.transaction.listings[0].listing_name }}</div>
    </div>
  </a>
</template>

<style scoped>

</style>