import { supabase } from '@/lib/supabase/supabaseClient'

export async function getChains() {
    const { data, error } = await supabase.from('chains').select('*')
    return { data, error }
  }
  