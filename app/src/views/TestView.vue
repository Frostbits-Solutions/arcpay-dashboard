<script setup lang="ts">
import { nextTick, onMounted, ref } from 'vue'
import { createClient, getListings, buy } from 'arcpay-sdk'
import type { QueryData } from '@supabase/supabase-js'

const listings = ref<QueryData<any> | null>(null)
const client = createClient('e95d6aac-db69-481b-8e40-9a5c8830459f')

onMounted(() => {
  nextTick(async () => {
    const { data, error } = await getListings(client)
    if (data) {
      listings.value = data
    } else {
      console.log(error)
    }
  })
})
</script>

<template>
    <main>
      Listings
      <ul>
        <li v-for="listing in listings" :key="listing.id">
          {{ listing }} <button @click="buy(client, listing.id)" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">Buy</button>
        </li>
      </ul>
    </main>
</template>

<style scoped>
main {
    text-align: center;
}
</style>
