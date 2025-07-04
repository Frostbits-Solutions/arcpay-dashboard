import type { Database } from '@/lib/supabase/database.types'

export type Transaction = Database['public']['Tables']['transactions']['Row']
export type CompositeListing = Database['public']['Tables']['listings']['Row'] & {
  auctions: Database['public']['Tables']['auctions']['Row'],
  sales: Database['public']['Tables']['sales']['Row'],
  dutch_auctions: Database['public']['Tables']['dutch_auctions']['Row']
}

export type Chain = Database['public']['Tables']['chains']['Row']
export type AccountsChainsParameter = Database['public']['Tables']['accounts_chains_parameters']['Row']