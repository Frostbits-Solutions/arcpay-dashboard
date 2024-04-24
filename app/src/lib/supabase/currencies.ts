import { supabase } from '@/lib/supabase/supabaseClient'

export async function getCurrencies() {
    const { data, error } = await supabase.from('currencies').select('*')
    return { data, error }
}
