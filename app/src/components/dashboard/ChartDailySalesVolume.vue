<script setup lang="ts">
import { BarChart } from '@/components/ui/chart-bar'
import { computed} from 'vue'
import { useNetworksStore } from '@/stores/networks'
import CountUp from "vue-countup-v3";
import { useTransactionsStore } from '@/stores/transactions'

const networks = useNetworksStore()
const transactions = useTransactionsStore()
const timeseries = computed(() => transactions.dailySalesVolumeTimeseries)
const chainCurrency = computed(() => networks.activeNetwork?.split(':')[0] || 'algo')
const volume = computed(() => transactions.totalSalesVolumes[chainCurrency.value] || 0)
const categories = computed(() => transactions.top5CurrenciesByVolume)

</script>

<template>
  <div class="w-full rounded-lg border border-border p-6 relative flex items-end">
    <div class="flex justify-between absolute top-6 left-6">
      <div>
        <h5 class="leading-none text-3xl font-bold text-foreground flex items-baseline gap-1">
          <count-up :decimalPlaces="0" :duration="1" :end-val="volume"></count-up>
          <span class="text-lg uppercase text-muted-foreground">{{ chainCurrency }}</span>
        </h5>
        <p class="text-base font-normal text-muted-foreground">Monthly volume</p>
      </div>
    </div>
    <BarChart
        class="h-[175px] w-full border-b border-border"
        index="time"
        :data="timeseries"
        :categories="categories"
        :rounded-corners="20"
        :show-grid-line="false"
        :show-y-axis="false"
        :show-x-axis="false"
        :colors="['#50e991', '#0080ff', '#0060ff', '#0040ff', '#0020ff', '#0010d9', '#0000b3', '#009fff', '#00bfff', '#00ffff']"
        type="stacked"
        :key="categories.join(',')"
    />
  </div>
</template>