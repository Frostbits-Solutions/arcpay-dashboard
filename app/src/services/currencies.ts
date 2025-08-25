import { supabase } from '@/lib/supabase/supabaseClient'

export async function getCurrencies(network: string) {
  const { data, error } = await supabase.from('currencies').select('*').eq('network_id', network)
  return { data, error }
}
