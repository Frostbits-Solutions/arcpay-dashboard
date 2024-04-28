<script setup lang="ts">
import { nextTick, onMounted, ref } from 'vue'
import { createClient, getListings, buy } from 'arcpay-sdk'
import type { QueryData } from '@supabase/supabase-js'

const listings = ref<QueryData<any> | null>(null)


onMounted(() => {
  nextTick(async () => {
    /* const client = createClient('e95d6aac-db69-481b-8e40-9a5c8830459f')
    const { data, error } = await getListings(client)
    if (data) {
      listings.value = data
    } else {
      console.log(error)
    }

     */
  })
})
</script>

<template>
    <main>
      Listings
      <ul>
        <li v-for="listing in listings" :key="listing.id">
          {{ listing.id }} - {{ listing.listing_type }} - {{ listing.status}}
        </li>
      </ul>
      <button @click="buy">Buy</button>
    </main>
</template>

<style scoped>
main {
    text-align: center;
}
</style>
