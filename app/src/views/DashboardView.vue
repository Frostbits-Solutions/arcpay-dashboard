<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { useNetworksStore } from '@/stores/networks'
import ChartHourlyTransactions from '@/components/dashboard/ChartHourlyTransactions.vue'
import ChartDailySalesVolume from '@/components/dashboard/ChartDailySalesVolume.vue'
import { useTransactionsStore } from '@/stores/transactions'
import { DataTable } from '@/components/ui/data-table'
import { columns } from '@/components/transactions-table/columns'
import { useCurrenciesStore } from '@/stores/currencies'
import type { PublicNetwork } from 'arcpay-sdk'

const networks = useNetworksStore()
const transactions = useTransactionsStore()
const currencies = useCurrenciesStore()
const pollingInterval = ref<NodeJS.Timeout>()


onMounted(async () => {
  const defaultNet = localStorage.getItem("defaultNetwork");
  if (defaultNet) {
    networks.setActive(defaultNet as PublicNetwork)
  } else {
    networks.setActive('algo:mainnet')
  }
  pollingInterval.value = setInterval(() => {
    transactions.fetchAll(false)
  }, 60000)
})

onBeforeUnmount(() => {
  clearInterval(pollingInterval.value)
})
</script>

<template>
  <main class="min-h-dvh pl-16 pt-16">
    <div class="max-w-screen-xl mx-auto p-10">
      <h4 class="text-2xl font-bold dark:text-white">Dashboard</h4>
      <div class="flex my-8 gap-8">
        <ChartDailySalesVolume/>
        <ChartHourlyTransactions/>
      </div>
      <h2 class="mt-16 mb-4 text-lg font-semibold text-foreground flex justify-between">
        Latests transactions
        <span class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-1 rounded-[10px] dark:bg-green-900 dark:text-green-300">
            <span class="w-2 h-2 me-2 bg-green-500 rounded-full relative">
              <span class="w-2 h-2 bg-green-500 rounded-full animate-ping absolute"></span>
            </span>
            Real time
        </span>
      </h2>
      <DataTable :columns="columns" :data="transactions.list"/>
    </div>
  </main>
</template>

<style scoped>

</style>
