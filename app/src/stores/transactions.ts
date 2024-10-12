import { h, ref, watch } from 'vue'
import { defineStore } from 'pinia'
import dayjs from 'dayjs'
import {
  getDailySalesVolume,
  getHourlyTransactionsCount,
  getTransactionsListings,
  subscribeToTransactions
} from '@/lib/supabase/transaction'
import ToastError from '@/components/ui/toast/ToastError.vue'
import { useToast } from '@/components/ui/toast'
import { useAccountsStore } from '@/stores/accounts'
import { useNetworksStore } from '@/stores/networks'
import utc from 'dayjs/plugin/utc'
import type { TransactionWithListings } from '@/models'
import type { RealtimeChannel } from '@supabase/supabase-js'
import { getAccountActiveListingsAppids } from '@/lib/supabase/accounts'
import {supabase} from '@/lib/supabase/supabaseClient'

type HourlyTransactionsTimeseries = {time: string, transactions: number}[]
type DailySalesVolumeTimeseries = Record<string, string|number>[]

const { toast } = useToast()

export const useTransactionsStore = defineStore('transactions', () => {
  const accounts = useAccountsStore()
  const networks = useNetworksStore()
  const loading = ref(false)
  const list = ref<TransactionWithListings[]>([])
  const totalSalesVolumes = ref<Record<string, number>>({})
  const top5CurrenciesByVolume = ref<string[]>([])
  const hourlyTransactionsTimeseries = ref<HourlyTransactionsTimeseries>([])
  const dailySalesVolumeTimeseries = ref<DailySalesVolumeTimeseries>([])
  const realtimeChannel = ref<RealtimeChannel | undefined>()

  async function fetchTransactions() {
    if (accounts.active && networks.activeNetwork) {
      const { data, error } = await getTransactionsListings(accounts.active.id, networks.activeNetwork)
      if (!data || error) {
        console.error(error)
        toast({
          title: 'Error fetching hourly transaction count',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError)
        })
      } else {
        list.value = data
      }
    }
  }

  async function fetchHourlyTransactionsCount() {
    if (accounts.active && networks.activeNetwork) {
      const tm = []
      const { data, error } = await getHourlyTransactionsCount(accounts.active.id, networks.activeNetwork)
      if (!data || error) {
        console.error(error)
        toast({
          title: 'Error fetching hourly transaction count',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError)
        })
      } else {
        if (data.length) {
          dayjs.extend(utc)
          for (let i = 0; i < 168; i++) {
            const time = dayjs().utc().subtract(i, 'hour').format('YYYY-MM-DDTHH')
            const dataPoint = data.find((item) => item.time?.includes(time))
            tm.push(dataPoint?{time: new Date(`${time}:00:00Z`).toLocaleString(), transactions: dataPoint?.count || 0}:{time: new Date(`${time}:00:00Z`).toLocaleString(), transactions: 0})
          }
          hourlyTransactionsTimeseries.value = tm.reverse()
        }
        else hourlyTransactionsTimeseries.value = []
      }
    }
  }

  async function fetchDailySalesVolume() {
    if (accounts.active && networks.activeNetwork) {
      const tm = []
      const { data, error } = await getDailySalesVolume(accounts.active.id, networks.activeNetwork)
      if (!data || error) {
        console.error(error)
        toast({
          title: 'Error fetching daily sales volume',
          description: error?.message || 'Unexpected error',
          variant: 'destructive',
          action: h(ToastError)
        })
      } else {
        if (data.length) {
          dayjs.extend(utc)
          const totalVolumes: Record<string, number> = {}
          data.forEach(dp => {
            if (dp.currency_ticker && dp.volume) {
              if (totalVolumes[dp.currency_ticker]) totalVolumes[dp.currency_ticker] += dp.volume
              else totalVolumes[dp.currency_ticker] = dp.volume
            }
          })
          totalSalesVolumes.value = totalVolumes
          top5CurrenciesByVolume.value = Object.entries(totalVolumes).sort((a, b) => b[1] - a[1]).slice(0,5).map(i => i[0])
          for (let i = 0; i < 30; i++) {
            const time = dayjs().utc().subtract(i, 'day').format('YYYY-MM-DD')
            const dataPoint: Record<string, string|number> = { time: new Date(time).toLocaleDateString() }
            top5CurrenciesByVolume.value.forEach(currency => {
              dataPoint[currency] = 0
            })
            const dataPoints: Record<string, string|number|null>[] = data.filter((item: any) => item.time.includes(time))
            dataPoints.forEach((point: any) => {
              dataPoint[point.currency_ticker] = point.volume
            })
            tm.push(dataPoint)
          }
          dailySalesVolumeTimeseries.value = tm.reverse()
        }
        else {
          dailySalesVolumeTimeseries.value = []
          totalSalesVolumes.value = {}
          top5CurrenciesByVolume.value = []
        }
      }
    }
  }

  async function fetchAll(toggleLoading:boolean = true) {
    loading.value = toggleLoading
    await Promise.allSettled([
      await fetchTransactions(),
      await fetchDailySalesVolume(),
      await fetchHourlyTransactionsCount()
    ])
    loading.value = false
  }

  async function subscribe() {
    if (accounts.active && networks.activeNetwork) {
      console.log('subribing to transactions')
      const {data, error} = await getAccountActiveListingsAppids(accounts.active.id, networks.activeNetwork)
      if (data && data.length) {
        const appIds = data.map((item: {app_id: number}) => item.app_id)
        realtimeChannel.value = subscribeToTransactions(supabase, appIds, () => {
          fetchAll(false)
        })
      }
    }
  }

  async function unsubscribe() {
    if (realtimeChannel.value) {
      await realtimeChannel.value.unsubscribe()
    }
  }

  watch(() => networks.activeNetwork, () => {fetchAll(true)})
  watch(() => accounts.active, () => {fetchAll(true)})

  return { loading, list, totalSalesVolumes, top5CurrenciesByVolume, hourlyTransactionsTimeseries, dailySalesVolumeTimeseries, fetchAll, subscribe, unsubscribe }
})
