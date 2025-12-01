import { supabase } from '@repo/supabase/client'
import { SupabaseClient } from '@supabase/supabase-js'
import type { Transaction } from '@repo/supabase/models'

export async function getTransactions(client: SupabaseClient, network: string, app_ids: string[]) {
  const { data, error } = await client.from('transactions').select('*').eq('network_id', network).in('app_id', app_ids).returns<Transaction[]>()
  return { data, error }
}

export async function getLastBidTx(supabase: SupabaseClient, network: string, app_id: number) {
  const { data, error } = await supabase
    .from('transactions')
    .select('*')
    .eq('network_id', network)
    .eq('app_id', app_id)
    .eq('type', 'bid')
    .order('created_at', { ascending: false })
    .limit(1)
    .returns<Transaction[]>()
  return { data, error }
}

export async function getTransactionsListings(account_id: string, network: string) {
  const { data, error } = await supabase.from('transactions').select('*, listings!inner( * )').eq('listings.account_id', account_id).eq('network_id', network).order('created_at', { ascending: false })
  return { data, error }
}

export async function getHourlyTransactionsCount(account_id: string, network: string) {
  const { data, error } = await supabase.rpc('get_hourly_transactions_timeseries', { account_id, network_id: network })
  return { data, error }
}

export async function getDailySalesVolume(account_id: string, network: string) {
  const { data, error } = await supabase.rpc('get_daily_sales_volume_timeseries', { account_id, network_id: network })
  return { data, error }
}
