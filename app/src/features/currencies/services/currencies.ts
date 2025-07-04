import { supabase } from '@/lib/supabase/supabaseClient'

export async function getCurrencies(chain: string) {
    const { data, error } = await supabase.from('currencies').select('*').eq('chain_id', chain)
    return { data, error }
}
