<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useNetworksStore } from '@/features/networks/stores/networks'
import ChartHourlyTransactions from '@/features/dashboard/components/ChartHourlyTransactions.vue'
import ChartDailySalesVolume from '@/features/dashboard/components/ChartDailySalesVolume.vue'
import { useTransactionsStore } from '@/features/transactions/stores/transactions'
import { DataTable } from '@/lib/ui/data-table'
import { columns } from '@/features/transactions/components/transactions-table/columns'
import { Button } from '@/lib/ui/button'
import { RefreshCw } from 'lucide-vue-next'

const networks = useNetworksStore()
const transactions = useTransactionsStore()
const pollingInterval = ref<NodeJS.Timeout>()
const lastUpdated = ref<string>()

async function fetchTransactions() {
  await transactions.fetchAll(true)
  lastUpdated.value = new Date().toLocaleString()
}

onMounted(async () => {
  const defaultNet = localStorage.getItem('defaultNetwork')
  await networks.fetchNetworks()
  if (defaultNet) {
    networks.setActive(defaultNet)
  } else {
    networks.setActive('algo:mainnet')
  }
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
      <div class="mb-4 mt-16 flex items-center justify-between">
        <h2 class="text-lg font-semibold text-foreground">Latest transactions</h2>
        <div class="flex items-center gap-2">
          <span v-if="lastUpdated" class="text-xs text-muted-foreground" :key="lastUpdated" v-motion-slide-right>Last updated {{ lastUpdated }}</span>
          <Button size="sm" class="group" @click="fetchTransactions">
            <RefreshCw class="mr-1 h-4 w-4 group-hover:animate-spin" />
            Refresh
          </Button>
        </div>
      </div>

      <DataTable :columns="columns" :data="transactions.list" />
    </div>
  </main>
</template>

<style scoped></style>
