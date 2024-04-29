<script setup lang="ts">

import ChartTransactionHistory from '@/components/dashboard/ChartTransactionHistory.vue'
import { nextTick, onMounted, ref, watch } from 'vue'
import { getTransactionsListings } from '@/lib/supabase/transaction'
import TransactionCard from '@/components/dashboard/TransactionCard.vue'
import type { Database } from '@/lib/supabase/database.types'
import { useAccountsStore } from '@/stores/accounts'

const transactions = ref<Database["public"]["Tables"]["transactions"]["Row"][]>([])
const account = useAccountsStore()

function formatDate(date: string) {
  const d = new Date(date)
  return `${d.toLocaleDateString()} ${d.toLocaleTimeString()}`
}

async function fetchTransactions() {
  if (!account.active) return
  const { data, error } = await getTransactionsListings(account.active?.id)
  if (data) {
    transactions.value = data
  } else {
    console.log(error)
  }
}

watch(() => account.active, async () => {
  await fetchTransactions()
})

onMounted(async () => {
  await fetchTransactions()
})
</script>

<template>
  <main class="min-h-dvh pl-16 pt-16">
    <div class="max-w-screen-xl mx-auto p-10">
      <h4 class="text-2xl font-bold dark:text-white">Dashboard</h4>
      <div class="flex my-8 gap-8">
        <div class="w-full bg-white rounded-lg  dark:bg-gray-800 p-4 md:p-6 border dark:border-gray-700"></div>
        <ChartTransactionHistory/>
      </div>
      <div class="mt-12 w-full rounded-lg border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-800">
        <h2 class="mb-2 text-lg font-semibold text-gray-900 dark:text-white flex justify-between">
          Latests transactions
          <span class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">
            <span class="w-2 h-2 me-1 bg-green-500 rounded-full animate-pulse"></span>
            Real time
          </span>
        </h2>
        <ul class="mt-10">
          <li v-for="(transaction, index) in transactions" :key="transaction.id">
            <span class="pl-2 text-xs text-gray-300 dark:text-gray-600">{{ formatDate(transaction.created_at) }}</span>
            <TransactionCard :transaction="transaction" :style="`animation-delay: ${index * 100}ms; animation-fill-mode: both`"/>
          </li>
          <li v-if="!transactions?.length">
            <span class="flex justify-start items-center py-4 mb-5 border border-gray-100 text-gray-700 dark:text-gray-100 rounded-lg hover:shadow-lg dark:hover:bg-gray-700 animate-slide-in-bottom dark:border-gray-700">
              <div class="max-w-80 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-500 text-xs">Tx id</div>
                <div class="w-72 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-28 px-5 border-l border-gray-100">
                <div class="w-12 h-5 bg-gray-200 rounded-full dark:bg-gray-700 mx-auto"></div>
              </div>
              <div class="max-w-80 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-500 text-xs">From</div>
                <div class="w-72 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="w-28 border-l border-gray-100 px-5 text-sm dark:border-gray-700">
                <div class="text-gray-500 text-xs">Amount</div>
                <div class="w-12 h-3 my-0.5 bg-gray-200 rounded-full dark:bg-gray-700"></div>
              </div>
              <div class="max-w-64 border-l px-5 border-gray-100 text-sm grow dark:border-gray-700">
                <div class="text-gray-500 text-xs">Listing</div>
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
