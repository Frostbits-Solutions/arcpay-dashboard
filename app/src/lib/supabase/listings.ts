import { supabase } from '@/lib/supabase/supabaseClient'
import type { Database } from '@/lib/supabase/database.types'

export async function createAuction(
    account_id: Database["public"]["Tables"]["listings"]["Row"]["account_id"],
    app_id: Database["public"]["Tables"]["listings"]["Row"]["app_id"],
    asset_creator: Database["public"]["Tables"]["listings"]["Row"]["asset_creator"],
    asset_id: Database["public"]["Tables"]["listings"]["Row"]["asset_id"],
    asset_qty: Database["public"]["Tables"]["listings"]["Row"]["asset_qty"],
    asset_thumbnail: Database["public"]["Tables"]["listings"]["Row"]["asset_thumbnail"],
    asset_type: Database["public"]["Enums"]["assets_types"],
    chain: Database["public"]["Enums"]["chains"],
    listing_currency: Database["public"]["Tables"]["listings"]["Row"]["listing_currency"],
    listing_name: Database["public"]["Tables"]["listings"]["Row"]["listing_name"],
    seller_address: Database["public"]["Tables"]["listings"]["Row"]["seller_address"],
    tags: Database["public"]["Tables"]["listings"]["Row"]["tags"],
    duration: Database["public"]["Tables"]["auctions"]["Row"]["duration"],
    increment: Database["public"]["Tables"]["auctions"]["Row"]["increment"],
    min_price: Database["public"]["Tables"]["auctions"]["Row"]["min_price"],
    max_price: Database["public"]["Tables"]["auctions"]["Row"]["max_price"],
    type: Database["public"]["Enums"]["auctions_type"]
) {
    const { data: listingData, error: listingError } = await supabase
        .from('listings')
        .insert({
            account_id,
            seller_address,
            listing_currency,
            app_id,
            asset_id,
            listing_name,
            asset_thumbnail,
            asset_type,
            asset_qty,
            asset_creator,
            tags,
            chain,
            listing_type: 'auction',
            status: 'pending',
        })
        .select()

    const listingId = listingData?.[0].id
    if (listingError || !listingId) return { data: null, listingError }

    const { data, error } = await supabase
        .from('auctions')
        .insert({
            listing_id: listingId,
            min_price,
            max_price,
            increment,
            duration,
            type,
        })
        .select()
    return { data, error }
}

export async function getAuctions(account_id: number) {
    const { data, error } = await supabase
        .from('auctions')
        .select('*, listings( * )')
        .eq('account_id', account_id)
    return { data, error }
}

export async function createSale(
    account_id: Database["public"]["Tables"]["listings"]["Row"]["account_id"],
    app_id: Database["public"]["Tables"]["listings"]["Row"]["app_id"],
    asset_creator: Database["public"]["Tables"]["listings"]["Row"]["asset_creator"],
    asset_id: Database["public"]["Tables"]["listings"]["Row"]["asset_id"],
    asset_qty: Database["public"]["Tables"]["listings"]["Row"]["asset_qty"],
    asset_thumbnail: Database["public"]["Tables"]["listings"]["Row"]["asset_thumbnail"],
    asset_type: Database["public"]["Enums"]["assets_types"],
    chain: Database["public"]["Enums"]["chains"],
    listing_currency: Database["public"]["Tables"]["listings"]["Row"]["listing_currency"],
    listing_name: Database["public"]["Tables"]["listings"]["Row"]["listing_name"],
    seller_address: Database["public"]["Tables"]["listings"]["Row"]["seller_address"],
    tags: Database["public"]["Tables"]["listings"]["Row"]["tags"],
    asking_price: Database["public"]["Tables"]["sales"]["Row"]["asking_price"]
) {
    const { data: listingData, error: listingError } = await supabase
        .from('listings')
        .insert({
            account_id,
            seller_address,
            listing_currency,
            app_id,
            asset_id,
            listing_name,
            asset_thumbnail,
            asset_type,
            asset_qty,
            asset_creator,
            tags,
            chain,
            listing_type: 'sale',
            status: 'pending',
        })
        .select()

    const listingId = listingData?.[0].id
    if (listingError || !listingId) return { data: null, listingError }

    const { data, error } = await supabase
        .from('sales')
        .insert({
            listing_id: listingId,
            asking_price,
        })
        .select()
    return { data, error }
}

export async function getSales(account_id: number) {
    const { data, error } = await supabase
        .from('sales')
        .select('*, listings( * )')
        .eq('account_id', account_id)
    return { data, error }
}

export async function cancelListing(listing_id: string) {
    const { data, error } = await supabase
        .from('listings')
        .update({ status: 'closed' })
        .eq('id', listing_id)
    return { data, error }
}

export async function getListingsTransactions() {
    const { data, error } = await supabase
        .from('listings')
        .select('*, transactions( * )')
    return { data, error }
}

export async function getListingById(listing_id: string) {
  const { data, error } = await supabase.rpc('get_listing_by_id', { listing_id })
  return { data, error }
}
