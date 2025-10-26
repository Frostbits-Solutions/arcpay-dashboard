import type { SupabaseClient } from '@supabase/supabase-js'

export default async function getContract(supabase: SupabaseClient, network: string, tag: string, version: string) {
  const { data, error } = await supabase.from('contracts').select('byte_code').eq('network_id', network).eq('tag', tag).eq('version', version).returns<{ contracts: { byte_code: string } }[]>()
  return { data, error }
}
