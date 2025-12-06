import type { SupabaseClient } from '@supabase/supabase-js'
import type { Currency } from '@repo/supabase/models'

export async function getCurrencies(client: SupabaseClient, network: string) {
  const { data, error } = await client.from('currencies').select('*').eq('network_id', network).returns<Currency[]>()
  return { data, error }
}

export async function getCurrency(client: SupabaseClient, network: string, id: string) {
  const { data, error } = await client.from('currencies').select('*').eq('network_id', network).eq('id', id).returns<Currency[]>()
  return { data, error }
}
