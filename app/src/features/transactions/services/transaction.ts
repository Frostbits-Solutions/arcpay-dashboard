import { supabase } from '@/lib/supabase/supabaseClient'
import type { Chain } from '@/models'
import { type RealtimePostgresInsertPayload, SupabaseClient } from '@supabase/supabase-js'

export async function getTransactions(app_ids: string[], chain: Chain) {
    const { data, error } = await supabase
      .from('transactions')
      .select('*')
      .eq('chain', chain)
      .in('app_id', app_ids)
    return { data, error }
}

export async function getTransactionsListings(account_id: number, chain: Chain){
  const { data, error } = await supabase
    .from('transactions')
    .select('*, listings!inner( * )')
    .eq('listings.account_id', account_id)
    .eq('chain', chain)
    .order('created_at', { ascending: false })
  return { data, error }
}

export function subscribeToTransactions(
  supabase: SupabaseClient,
  app_ids: number[],
  callback: (payload: RealtimePostgresInsertPayload<{ [p: string]: any }>) => void
) {
  const room = supabase.channel(`changes`)
  room.on(
    'postgres_changes',
    {event: 'INSERT', schema: 'public', table: 'transactions', filter: `app_id=in.(${app_ids.join(',')})`},
    (payload) => {
      console.log('update', payload)
      callback(payload)
    }
  ).subscribe(async (status) => {
    if (status !== 'SUBSCRIBED') {
      console.log(status)
      return
    }
    await room.track({
      online_at: new Date().toISOString(),
    })
    console.log('subscribed')
  })
  return room
}
export async function getHourlyTransactionsCount(account_id: number, chain: Chain){
  const { data, error } = await supabase.rpc('get_hourly_transactions_timeseries', {account_id, chain})
  return { data, error }
}

export async function getDailySalesVolume(account_id: number, chain: Chain){
  const { data, error } = await supabase.rpc('get_daily_sales_volume_timeseries', {account_id, chain})
  return { data, error }
}
