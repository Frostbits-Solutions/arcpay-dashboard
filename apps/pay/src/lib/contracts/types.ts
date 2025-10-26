import type { AssetMetadata } from '@/types'
import type { Currency } from '@/lib/supabase/models'

export type ListingType = 'sale' | 'auction' | 'dutch' | 'offchain'

export interface SaleCreationParams {
  type: 'sale'
  asset: AssetMetadata
  price: number
  currency: Currency | undefined
}

export interface AuctionCreationParams {
  type: 'auction'
  asset: AssetMetadata
  price: number
  duration: number
  currency: Currency | undefined
}

export interface DutchCreationParams {
  type: 'dutch'
  asset: AssetMetadata
  priceMin: number
  priceMax: number
  duration: number
  currency: Currency | undefined
}

export type CreationParams = SaleCreationParams | AuctionCreationParams | DutchCreationParams
