import { supabase } from '@repo/supabase/client'
import type { CompositeListing, ListingDetail, SupaPromise } from '@repo/supabase/models'

export async function getListings(account_id: string, network: string): SupaPromise<ListingDetail[]> {
  const { data, error } = await supabase
    .from('listings')
    .select('*, auctions( * ), sales( * ), dutch_auctions( * )')
    .eq('account_id', account_id)
    .eq('network_id', network)
    .order('created_at', { ascending: false })
  return { data, error }
}

export async function getListingById(listing_id: string): SupaPromise<CompositeListing> {
  const { data, error } = await supabase.rpc('get_listing_by_id', { listing_id })
  return { data, error }
}
