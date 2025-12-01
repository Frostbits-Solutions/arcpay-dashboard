import type { Database } from "./database.types";
import type { PostgrestError } from "@supabase/supabase-js";
export type SupaPromise<T> = Promise<{
  data: T | null;
  error: PostgrestError | null;
}>;
export type Account = Database["public"]["Tables"]["accounts"]["Row"];
export type AccountAddress =
  Database["public"]["Tables"]["accounts_addresses"]["Row"];
export type AccountNetworkParameter =
  Database["public"]["Tables"]["accounts_networks_parameters"]["Row"];
export type AccountCurrency =
  Database["public"]["Tables"]["accounts_currencies"]["Row"];
export type AccountMembership = {
  id: string;
  name: string;
  role: MembershipRole;
};
export type AccountSecret =
  Database["public"]["Tables"]["accounts_secrets"]["Row"];
export type AccountUser =
  Database["public"]["Tables"]["accounts_users_association"]["Row"];
export type AssetType = Database["public"]["Enums"]["assets_types"];
export type Auction = {
  start_price: number;
  increment: number;
  duration: number;
};
export type Network = Database["public"]["Tables"]["networks"]["Row"];
export type Contract = Database["public"]["Tables"]["contracts"]["Row"];
export type ContractVersion =
  Database["public"]["Tables"]["contracts_versions"]["Row"];
export type Currency = Database["public"]["Tables"]["currencies"]["Row"];
export type DutchAuction = {
  min_price: number;
  max_price: number;
  duration: number;
};
export type MembershipRole =
  Database["public"]["Enums"]["accounts_users_roles"];
export type Listing = Database["public"]["Tables"]["listings"]["Row"];
export type Sale = {
  price: number;
};
export type SubscriptionTier =
  Database["public"]["Tables"]["subscription_tiers"]["Row"];
export type SubscriptionNetworkParameters =
  Database["public"]["Tables"]["subscriptions_networks_parameters"]["Row"];
export type Transaction = Database["public"]["Tables"]["transactions"]["Row"];
export type TransactionListing = Transaction & {
  listings: Listing;
};
export type TransactionsCount =
  Database["public"]["CompositeTypes"]["transactions_count"];
export type TransactionsVolumne =
  Database["public"]["CompositeTypes"]["transactions_volume"];
export type CompositeListing =
  Database["public"]["CompositeTypes"]["composite_listing"];
