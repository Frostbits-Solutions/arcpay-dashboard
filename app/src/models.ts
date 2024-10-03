import type { Database } from '@/lib/supabase/database.types'

type Transaction = Database['public']['Tables']['transactions']['Row']
export interface TransactionWithListings extends Transaction {
  listings: Database['public']['Tables']['listings']['Row'][]
}

export type CompositeListing = Database['public']['Tables']['listings']['Row'] & {
  auctions: Database['public']['Tables']['auctions']['Row'][],
  sales: Database['public']['Tables']['sales']['Row'][],
  dutch_auctions: Database['public']['Tables']['dutch_auctions']['Row'][]
}

export type Chain = Database['public']['Enums']['chains']
