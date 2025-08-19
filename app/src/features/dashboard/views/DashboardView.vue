<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useNetworksStore } from '@/features/networks/stores/networks'
import ChartHourlyTransactions from '@/features/dashboard/components/ChartHourlyTransactions.vue'
import ChartDailySalesVolume from '@/features/dashboard/components/ChartDailySalesVolume.vue'
import { useTransactionsStore } from '@/features/transactions/stores/transactions'
import { DataTable } from '@/lib/ui/data-table'
import { columns } from '@/features/transactions/components/transactions-table/columns'

const networks = useNetworksStore()
const transactions = useTransactionsStore()
const pollingInterval = ref<NodeJS.Timeout>()

onMounted(async () => {
  const defaultNet = localStorage.getItem('defaultNetwork')
  networks.fetchChains()
  if (defaultNet) {
    networks.setActive(defaultNet)
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
    <div class="mx-auto max-w-screen-xl p-10">
      <h4 class="text-2xl font-bold dark:text-white">Dashboard</h4>
      <div class="my-8 flex gap-8">
        <ChartDailySalesVolume />
        <ChartHourlyTransactions />
      </div>
      <h2 class="mb-4 mt-16 flex justify-between text-lg font-semibold text-foreground">
        Latests transactions
        <span class="inline-flex items-center rounded-[10px] bg-green-100 px-2.5 py-1 text-xs font-medium text-green-800 dark:bg-green-900 dark:text-green-300">
          <span class="relative me-2 h-2 w-2 rounded-full bg-green-500">
            <span class="absolute h-2 w-2 animate-ping rounded-full bg-green-500"></span>
          </span>
          Real time
        </span>
      </h2>
      <DataTable :columns="columns" :data="transactions.list" />
    </div>
  </main>
</template>

<style scoped></style>
