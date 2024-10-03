import { supabase } from '@/lib/supabase/supabaseClient'
import type { Chain } from '@/models'

export async function getCurrencies(chain: Chain) {
    const { data, error } = await supabase.from('currencies').select('*').eq('chain', chain)
    return { data, error }
}
