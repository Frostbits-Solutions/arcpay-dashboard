import { supabase } from '@repo/supabase/client'
import type { SupaPromise, TransactionListing, TransactionsCount, TransactionsVolumne } from '@repo/supabase/models'

export async function getTransactionsListings(account_id: string, network: string): SupaPromise<TransactionListing[]> {
  const { data, error } = await supabase.from('transactions').select('*, listings!inner( * )').eq('listings.account_id', account_id).eq('network_id', network).order('created_at', { ascending: false })
  return { data, error }
}

export async function getHourlyTransactionsCount(account_id: string, network: string): SupaPromise<TransactionsCount[]> {
  const { data, error } = await supabase.rpc('get_hourly_transactions_timeseries', { account_id, network_id: network })
  return { data, error }
}

export async function getDailySalesVolume(account_id: string, network: string): SupaPromise<TransactionsVolumne[]> {
  const { data, error } = await supabase.rpc('get_daily_sales_volume_timeseries', { account_id, network_id: network })
  return { data, error }
}
