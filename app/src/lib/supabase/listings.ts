import { supabase } from '@/lib/supabase/supabaseClient'

export async function createAuction(
    account_id: number,
    asset_creator: string | null,
    asset_id: string,
    asset_name: string,
    asset_qty: number,
    asset_thumbnail: string | null,
    asset_type: 'ARC72' | 'OFFCHAIN',
    contract_address: string,
    listing_currency: string,
    seller_address: string,
    tags: string | null,
    start_price: number,
    min_increment: number,
    duration: number,
    type: string
) {
    const { data: listingData, error: listingError } = await supabase
        .from('listings')
        .insert({
            account_id,
            seller_address,
            listing_currency,
            contract_address,
            asset_id,
            asset_name,
            asset_thumbnail,
            asset_type,
            asset_qty,
            asset_creator,
            tags,
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
            start_price,
            min_increment,
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
    account_id: number,
    asset_creator: string | null,
    asset_id: string,
    asset_name: string,
    asset_qty: number,
    asset_thumbnail: string | null,
    asset_type: 'ARC72' | 'OFFCHAIN',
    contract_address: string,
    listing_currency: string,
    seller_address: string,
    tags: string | null,
    asking_price: number
) {
    const { data: listingData, error: listingError } = await supabase
        .from('listings')
        .insert({
            account_id,
            seller_address,
            listing_currency,
            contract_address,
            asset_id,
            asset_name,
            asset_thumbnail,
            asset_type,
            asset_qty,
            asset_creator,
            tags,
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
