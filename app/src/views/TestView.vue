<script setup lang="ts">
import { nextTick, onMounted, ref } from 'vue'
import { Client, modal } from 'arcpay-sdk'
import type { QueryData } from '@supabase/supabase-js'

const listings = ref<QueryData<any> | null>(null)
const arcpay = new Client({apiKey: '54db68b9-7dfa-47fa-93ae-bd694ca5ba25'})

onMounted(() => {
  nextTick(async () => {
    const { data, error } = await arcpay.getListings()
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
          {{ listing }} <button @click="arcpay.buy(listing.id)" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">Buy</button>
        </li>
      </ul>
    </main>
</template>

<style scoped>
main {
    text-align: center;
}
</style>
