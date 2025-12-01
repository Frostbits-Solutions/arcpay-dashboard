import { supabase } from '@repo/supabase/client'

export async function getNetworks() {
  const { data, error } = await supabase.from('networks').select('*')
  return { data, error }
}
