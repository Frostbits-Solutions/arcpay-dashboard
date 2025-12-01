import type { SupabaseClient } from '@supabase/supabase-js'
import type { AssetType, Auction, CompositeListing, DutchAuction, Listing, Sale, SupaPromise } from '@repo/supabase/models'

export async function getListings(client: SupabaseClient, account_id: string, network: string): SupaPromise<Listing[]> {
  const { data, error } = await client
    .from('listings')
    .select('*, auctions( * ), sales( * ), dutch_auctions( * )')
    .eq('account_id', account_id)
    .eq('network_id', network)
    .order('created_at', { ascending: false })
  return { data, error }
}

export async function getListingById(client: SupabaseClient, listing_id: string): SupaPromise<CompositeListing> {
  const { data, error } = await client.rpc('get_listing_by_id', { listing_id })
  return { data, error }
}

export async function createAuction(
  client: SupabaseClient,
  account_id: Listing['account_id'],
  creator_address: Listing['creator_address'],
  name: Listing['name'],
  currency: Listing['currency'],
  app_id: Listing['app_id'],
  asset_id: Listing['asset_id'],
  asset_thumbnail: Listing['asset_thumbnail'],
  asset_type: AssetType,
  asset_qty: Listing['asset_qty'],
  metadata: Listing['metadata'],
  network_id: Listing['network_id'],
  contract_version: Listing['contract_version'],
  duration: Auction['duration'],
  start_price: Auction['start_price'],
  increment: Auction['increment']
): SupaPromise<Auction[]> {
  const { data: listingData, error: listingError } = await client
    .from('listings')
    .insert({
      account_id,
      status: 'pending',
      creator_address,
      name,
      currency,
      type: 'auction',
      app_id,
      asset_id,
      asset_thumbnail,
      asset_type,
      asset_qty,
      metadata,
      network_id,
      contract_version,
    })
    .select()
  const listingId = listingData?.[0].id
  if (listingError || !listingId) return { data: null, error: listingError }

  const { data, error } = await client
    .from('auctions')
    .insert({
      listing_id: listingId,
      start_price,
      increment,
      duration,
    })
    .select()
  return { data, error }
}

export async function createDutchAuction(
  client: SupabaseClient,
  account_id: Listing['account_id'],
  creator_address: Listing['creator_address'],
  name: Listing['name'],
  currency: Listing['currency'],
  app_id: Listing['app_id'],
  asset_id: Listing['asset_id'],
  asset_thumbnail: Listing['asset_thumbnail'],
  asset_type: AssetType,
  asset_qty: Listing['asset_qty'],
  metadata: Listing['metadata'],
  network_id: Listing['network_id'],
  contract_version: Listing['contract_version'],
  duration: DutchAuction['duration'],
  min_price: DutchAuction['min_price'],
  max_price: DutchAuction['max_price']
): SupaPromise<DutchAuction[]> {
  const { data: listingData, error: listingError } = await client
    .from('listings')
    .insert({
      account_id,
      status: 'pending',
      creator_address,
      name,
      currency,
      type: 'dutch',
      app_id,
      asset_id,
      asset_thumbnail,
      asset_type,
      asset_qty,
      metadata,
      network_id,
      contract_version,
    })
    .select()

  const listingId = listingData?.[0].id
  if (listingError || !listingId) return { data: null, error: listingError }

  const { data, error } = await client
    .from('dutch_auctions')
    .insert({
      listing_id: listingId,
      min_price,
      max_price,
      duration,
    })
    .select()
  return { data, error }
}

export async function createSale(
  client: SupabaseClient,
  account_id: Listing['account_id'],
  creator_address: Listing['creator_address'],
  name: Listing['name'],
  currency: Listing['currency'],
  app_id: Listing['app_id'],
  asset_id: Listing['asset_id'],
  asset_thumbnail: Listing['asset_thumbnail'],
  asset_type: AssetType,
  asset_qty: Listing['asset_qty'],
  metadata: Listing['metadata'],
  network_id: Listing['network_id'],
  contract_version: Listing['contract_version'],
  price: Sale['price']
): SupaPromise<Sale[]> {
  const { data: listingData, error: listingError } = await client
    .from('listings')
    .insert({
      account_id,
      status: 'pending',
      creator_address,
      name,
      currency,
      type: 'sale',
      app_id,
      asset_id,
      asset_thumbnail,
      asset_type,
      asset_qty,
      metadata,
      network_id,
      contract_version,
    })
    .select()

  const listingId = listingData?.[0].id
  if (listingError || !listingId) return { data: null, error: listingError }

  const { data, error } = await client
    .from('sales')
    .insert({
      listing_id: listingId,
      price,
    })
    .select()
  return { data, error }
}
