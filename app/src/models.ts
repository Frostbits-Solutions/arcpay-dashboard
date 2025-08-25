import type { Database } from '@/lib/supabase/database.types'

export type Account = Database['public']['Tables']['accounts']['Row']
export type AccountAddress = Database['public']['Tables']['accounts_addresses']['Row']
export type AccountNetworkParameter = Database['public']['Tables']['accounts_networks_parameters']['Row']
export type AccountCurrency = Database['public']['Tables']['accounts_currencies']['Row']
export type AccountMembership = { id: string; name: string; role: MembershipRole }
export type AccountSecret = Database['public']['Tables']['accounts_secrets']['Row']
export type AccountUser = Database['public']['Tables']['accounts_users_association']['Row']
export type Auction = Database['public']['Tables']['auctions']['Row']
export type Network = Database['public']['Tables']['networks']['Row']
export type Contract = Database['public']['Tables']['contracts']['Row']
export type ContractVersion = Database['public']['Tables']['contracts_versions']['Row']
export type Currency = Database['public']['Tables']['currencies']['Row']
export type DutchAuction = Database['public']['Tables']['dutch_auctions']['Row']
export type MembershipRole = Database['public']['Enums']['accounts_users_roles']
export type Listing = Database['public']['Tables']['listings']['Row']
export type Sale = Database['public']['Tables']['sales']['Row']
export type SubscriptionTier = Database['public']['Tables']['subscription_tiers']['Row']
export type SubscriptionNetworkParameters = Database['public']['Tables']['subscriptions_networks_parameters']['Row']
export type Transaction = Database['public']['Tables']['transactions']['Row']
export type CompositeListing = Database['public']['Tables']['listings']['Row'] & {
  auctions: Database['public']['Tables']['auctions']['Row']
  sales: Database['public']['Tables']['sales']['Row']
  dutch_auctions: Database['public']['Tables']['dutch_auctions']['Row']
}
