<script setup lang="ts">
import { CurveType } from '@unovis/ts'
import { AreaChart } from '@/components/ui/chart-area'
import { computed } from 'vue'
import CountUp from "vue-countup-v3";
import { useTransactionsStore } from '@/stores/transactions'

const transactions = useTransactionsStore()
const timeseries = computed(() => transactions.hourlyTransactionsTimeseries)

const total = computed(() => {
  return timeseries.value.reduce((acc, item) => acc + item.transactions, 0)
})
</script>

<template>
  <div class="max-w-xs w-full rounded-lg border border-border p-6">
    <div class="flex justify-between">
      <div>
        <h5 class="leading-none text-3xl font-bold text-foreground">
          <count-up :decimalPlaces="0" :duration="1" :end-val="total"></count-up>
        </h5>
        <p class="text-base font-normal text-muted-foreground">Transactions this week</p>
      </div>
    </div>
    <AreaChart
      class="h-[175px] w-[272px] border-b border-border"
      index="time"
      :data="timeseries"
      :categories="['transactions']"
      :show-grid-line="false"
      :show-legend="false"
      :show-x-axis="false"
      :show-y-axis="false"
      :curve-type="CurveType.CatmullRom"
      :colors="['#0080ff']"
      :margin="{ top: 0, right: 2, bottom: 0, left: 0 }"
    />
  </div>
</template>