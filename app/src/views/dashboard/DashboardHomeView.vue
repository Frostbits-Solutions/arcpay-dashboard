<script setup lang="ts">

import ChartTransactionHistory from '@/components/dashboard/ChartTransactionHistory.vue'
import ChartRevenuesDonut from '@/components/dashboard/ChartRevenuesDonut.vue'
</script>

<template>
  <main class="min-h-dvh pl-16 pt-16">
    <div class="max-w-screen-xl mx-auto p-10">
      <h4 class="text-2xl font-bold dark:text-white">Dashboard</h4>
      <div class="flex my-8 gap-8">
        <div class="w-full bg-white rounded-lg  dark:bg-gray-800 p-4 md:p-6 border dark:border-gray-700"></div>
        <ChartTransactionHistory/>
      </div>
      <div class="mt-12 w-full rounded-lg border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-900">
        <h2 class="mb-2 text-lg font-semibold text-gray-900 dark:text-white flex justify-between">
          Latests transactions
          <span class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">
            <span class="w-2 h-2 me-1 bg-green-500 rounded-full animate-pulse"></span>
            Real time
          </span>
        </h2>
      </div>
    </div>
  </main>
</template>

<style scoped>

</style>