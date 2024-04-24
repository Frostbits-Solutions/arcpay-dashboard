import { supabase } from '@/lib/supabase/supabaseClient'

export async function getTransactions(contract_address: string) {
    const { data, error } = await supabase
        .from('transactions')
        .select('*')
        .eq('contract_address', contract_address)
    return { data, error }
}
