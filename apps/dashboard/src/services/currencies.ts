import type { Currency, SupaPromise } from '@repo/supabase/models'
import { supabase } from '@repo/supabase/client'

export async function getCurrencies(network: string): SupaPromise<Currency[]> {
  const { data, error } = await supabase.from('currencies').select('*').eq('network_id', network)
  return { data, error }
}
