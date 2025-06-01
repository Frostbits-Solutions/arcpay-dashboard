export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      accounts: {
        Row: {
          authenticate_clients: boolean
          created_at: string
          id: number
          name: string
          owner_email: string
          subscription_expiration_date: string | null
          subscription_id: number
        }
        Insert: {
          authenticate_clients?: boolean
          created_at?: string
          id?: number
          name: string
          owner_email: string
          subscription_expiration_date?: string | null
          subscription_id?: number
        }
        Update: {
          authenticate_clients?: boolean
          created_at?: string
          id?: number
          name?: string
          owner_email?: string
          subscription_expiration_date?: string | null
          subscription_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "public_accounts_subscription_id_fkey"
            columns: ["subscription_id"]
            isOneToOne: false
            referencedRelation: "subscription_tiers"
            referencedColumns: ["id"]
          },
        ]
      }
      accounts_addresses: {
        Row: {
          account_id: number
          address: string
          created_at: string
          name: string | null
        }
        Insert: {
          account_id: number
          address: string
          created_at?: string
          name?: string | null
        }
        Update: {
          account_id?: number
          address?: string
          created_at?: string
          name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "public_accounts_addresses_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      accounts_chains_parameters: {
        Row: {
          account_id: number
          chain_id: string
          created_at: string
          enable_secondary: boolean
          secondary_fee_address: string | null
          secondary_percentage_fee: number
        }
        Insert: {
          account_id: number
          chain_id: string
          created_at?: string
          enable_secondary?: boolean
          secondary_fee_address?: string | null
          secondary_percentage_fee?: number
        }
        Update: {
          account_id?: number
          chain_id?: string
          created_at?: string
          enable_secondary?: boolean
          secondary_fee_address?: string | null
          secondary_percentage_fee?: number
        }
        Relationships: [
          {
            foreignKeyName: "accounts_chains_parameters_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "accounts_chains_parameters_chain_id_fkey"
            columns: ["chain_id"]
            isOneToOne: false
            referencedRelation: "chains"
            referencedColumns: ["id"]
          },
        ]
      }
      accounts_currencies: {
        Row: {
          account_id: number
          chain_id: string
          created_at: string
          currency: string
        }
        Insert: {
          account_id: number
          chain_id: string
          created_at?: string
          currency: string
        }
        Update: {
          account_id?: number
          chain_id?: string
          created_at?: string
          currency?: string
        }
        Relationships: [
          {
            foreignKeyName: "accounts_currencies_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "accounts_currencies_chain_id_fkey"
            columns: ["currency", "chain_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id", "chain_id"]
          },
        ]
      }
      accounts_secrets: {
        Row: {
          account_id: number
          created_at: string
          name: string
          secret: string
        }
        Insert: {
          account_id?: number
          created_at?: string
          name: string
          secret?: string
        }
        Update: {
          account_id?: number
          created_at?: string
          name?: string
          secret?: string
        }
        Relationships: [
          {
            foreignKeyName: "accounts_secrets_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      accounts_users_association: {
        Row: {
          account_id: number
          created_at: string
          role: Database["public"]["Enums"]["accounts_users_roles"]
          updated_at: string | null
          user_email: string
        }
        Insert: {
          account_id: number
          created_at?: string
          role?: Database["public"]["Enums"]["accounts_users_roles"]
          updated_at?: string | null
          user_email: string
        }
        Update: {
          account_id?: number
          created_at?: string
          role?: Database["public"]["Enums"]["accounts_users_roles"]
          updated_at?: string | null
          user_email?: string
        }
        Relationships: [
          {
            foreignKeyName: "public_accounts_users_association_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      auctions: {
        Row: {
          created_at: string
          duration: number
          id: number
          increment: number
          listing_id: string
          start_price: number
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          duration: number
          id?: number
          increment: number
          listing_id: string
          start_price: number
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          duration?: number
          id?: number
          increment?: number
          listing_id?: string
          start_price?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "public_auctions_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
        ]
      }
      chains: {
        Row: {
          created_at: string
          fee_proxy_app_id: number | null
          id: string
          last_indexed_at: string | null
        }
        Insert: {
          created_at?: string
          fee_proxy_app_id?: number | null
          id: string
          last_indexed_at?: string | null
        }
        Update: {
          created_at?: string
          fee_proxy_app_id?: number | null
          id?: string
          last_indexed_at?: string | null
        }
        Relationships: []
      }
      contracts: {
        Row: {
          byte_code: string
          chain_id: string
          created_at: string
          tag: Database["public"]["Enums"]["contract_tag_enum"]
          version: number
        }
        Insert: {
          byte_code: string
          chain_id: string
          created_at?: string
          tag: Database["public"]["Enums"]["contract_tag_enum"]
          version: number
        }
        Update: {
          byte_code?: string
          chain_id?: string
          created_at?: string
          tag?: Database["public"]["Enums"]["contract_tag_enum"]
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "contracts_version_fkey"
            columns: ["version", "chain_id"]
            isOneToOne: false
            referencedRelation: "contracts_versions"
            referencedColumns: ["version", "chain_id"]
          },
        ]
      }
      contracts_versions: {
        Row: {
          chain_id: string
          created_at: string
          version: number
        }
        Insert: {
          chain_id: string
          created_at?: string
          version: number
        }
        Update: {
          chain_id?: string
          created_at?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "contracts_versions_chain_id_fkey"
            columns: ["chain_id"]
            isOneToOne: false
            referencedRelation: "chains"
            referencedColumns: ["id"]
          },
        ]
      }
      currencies: {
        Row: {
          chain_id: string
          created_at: string
          decimals: number
          icon: string | null
          id: string
          is_public: boolean
          name: string
          ticker: string
          type: Database["public"]["Enums"]["currency_type"]
          updated_at: string | null
        }
        Insert: {
          chain_id: string
          created_at?: string
          decimals: number
          icon?: string | null
          id: string
          is_public?: boolean
          name: string
          ticker: string
          type: Database["public"]["Enums"]["currency_type"]
          updated_at?: string | null
        }
        Update: {
          chain_id?: string
          created_at?: string
          decimals?: number
          icon?: string | null
          id?: string
          is_public?: boolean
          name?: string
          ticker?: string
          type?: Database["public"]["Enums"]["currency_type"]
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "currencies_chain_id_fkey"
            columns: ["chain_id"]
            isOneToOne: false
            referencedRelation: "chains"
            referencedColumns: ["id"]
          },
        ]
      }
      dutch_auctions: {
        Row: {
          created_at: string
          duration: number
          id: number
          listing_id: string
          max_price: number | null
          min_price: number
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          duration: number
          id?: number
          listing_id: string
          max_price?: number | null
          min_price: number
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          duration?: number
          id?: number
          listing_id?: string
          max_price?: number | null
          min_price?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "public_dutch_auctions_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
        ]
      }
      listings: {
        Row: {
          account_id: number
          app_id: number
          asset_creator: string | null
          asset_id: string
          asset_qty: number
          asset_thumbnail: string | null
          asset_type: Database["public"]["Enums"]["assets_types"]
          chain_id: string
          contract_version: number | null
          created_at: string
          currency: string
          id: string
          name: string
          seller_address: string
          status: Database["public"]["Enums"]["listings_statuses"]
          tags: string | null
          type: Database["public"]["Enums"]["listings_types"]
          updated_at: string | null
          transactions:
            | Database["public"]["Tables"]["transactions"]["Row"]
            | null
        }
        Insert: {
          account_id: number
          app_id: number
          asset_creator?: string | null
          asset_id: string
          asset_qty?: number
          asset_thumbnail?: string | null
          asset_type: Database["public"]["Enums"]["assets_types"]
          chain_id: string
          contract_version?: number | null
          created_at?: string
          currency: string
          id?: string
          name: string
          seller_address: string
          status: Database["public"]["Enums"]["listings_statuses"]
          tags?: string | null
          type: Database["public"]["Enums"]["listings_types"]
          updated_at?: string | null
        }
        Update: {
          account_id?: number
          app_id?: number
          asset_creator?: string | null
          asset_id?: string
          asset_qty?: number
          asset_thumbnail?: string | null
          asset_type?: Database["public"]["Enums"]["assets_types"]
          chain_id?: string
          contract_version?: number | null
          created_at?: string
          currency?: string
          id?: string
          name?: string
          seller_address?: string
          status?: Database["public"]["Enums"]["listings_statuses"]
          tags?: string | null
          type?: Database["public"]["Enums"]["listings_types"]
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "listings_chain_id_fkey"
            columns: ["chain_id"]
            isOneToOne: false
            referencedRelation: "chains"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listings_contract_version_chain_id_fkey"
            columns: ["contract_version", "chain_id"]
            isOneToOne: false
            referencedRelation: "contracts_versions"
            referencedColumns: ["version", "chain_id"]
          },
          {
            foreignKeyName: "public_listings_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      sales: {
        Row: {
          created_at: string
          id: number
          listing_id: string
          price: number
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          id?: number
          listing_id: string
          price: number
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          id?: number
          listing_id?: string
          price?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "public_sales_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
        ]
      }
      subscription_tiers: {
        Row: {
          allow_custom_currencies: boolean
          allow_secondary_listings: boolean
          created_at: string
          duration: number | null
          id: number
          name: string
        }
        Insert: {
          allow_custom_currencies?: boolean
          allow_secondary_listings?: boolean
          created_at?: string
          duration?: number | null
          id?: number
          name: string
        }
        Update: {
          allow_custom_currencies?: boolean
          allow_secondary_listings?: boolean
          created_at?: string
          duration?: number | null
          id?: number
          name?: string
        }
        Relationships: []
      }
      subscriptions_chains_parameters: {
        Row: {
          chain_id: string
          created_at: string
          flat_fees: number
          sales_fees: number
          secondary_flat_fees: number
          secondary_sales_fees: number
          subscription_id: number
        }
        Insert: {
          chain_id: string
          created_at?: string
          flat_fees?: number
          sales_fees?: number
          secondary_flat_fees?: number
          secondary_sales_fees?: number
          subscription_id: number
        }
        Update: {
          chain_id?: string
          created_at?: string
          flat_fees?: number
          sales_fees?: number
          secondary_flat_fees?: number
          secondary_sales_fees?: number
          subscription_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "subscriptions_chains_parameters_chain_id_fkey"
            columns: ["chain_id"]
            isOneToOne: false
            referencedRelation: "chains"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "subscriptions_chains_parameters_subscription_id_fkey"
            columns: ["subscription_id"]
            isOneToOne: false
            referencedRelation: "subscription_tiers"
            referencedColumns: ["id"]
          },
        ]
      }
      transactions: {
        Row: {
          amount: number | null
          app_id: number
          chain_id: string
          created_at: string
          currency: string | null
          from_address: string
          group_id: string | null
          id: string
          note: string | null
          type: Database["public"]["Enums"]["transaction_type"]
          listings: Database["public"]["Tables"]["listings"]["Row"] | null
        }
        Insert: {
          amount?: number | null
          app_id: number
          chain_id: string
          created_at?: string
          currency?: string | null
          from_address: string
          group_id?: string | null
          id: string
          note?: string | null
          type: Database["public"]["Enums"]["transaction_type"]
        }
        Update: {
          amount?: number | null
          app_id?: number
          chain_id?: string
          created_at?: string
          currency?: string | null
          from_address?: string
          group_id?: string | null
          id?: string
          note?: string | null
          type?: Database["public"]["Enums"]["transaction_type"]
        }
        Relationships: [
          {
            foreignKeyName: "transactions_chain_id_fkey"
            columns: ["chain_id"]
            isOneToOne: false
            referencedRelation: "chains"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      get_account_subscription: {
        Args: { account_id: number }
        Returns: {
          allow_custom_currencies: boolean
          allow_secondary_listings: boolean
          created_at: string
          duration: number | null
          id: number
          name: string
        }
      }
      get_daily_sales_volume_timeseries: {
        Args: {
          account_id: number
          chain: Database["public"]["Enums"]["chains_enum"]
        }
        Returns: Database["public"]["CompositeTypes"]["transactions_volume"][]
      }
      get_hourly_transactions_timeseries: {
        Args: {
          account_id: number
          chain: Database["public"]["Enums"]["chains_enum"]
        }
        Returns: Database["public"]["CompositeTypes"]["transactions_count"][]
      }
      get_key_account_id: {
        Args: { key: string; origin: string }
        Returns: number
      }
      get_listing_by_id: {
        Args: { listing_id: string }
        Returns: Database["public"]["CompositeTypes"]["composite_listing"]
      }
      listings: {
        Args: { "": Database["public"]["Tables"]["transactions"]["Row"] }
        Returns: {
          account_id: number
          app_id: number
          asset_creator: string | null
          asset_id: string
          asset_qty: number
          asset_thumbnail: string | null
          asset_type: Database["public"]["Enums"]["assets_types"]
          chain_id: string
          contract_version: number | null
          created_at: string
          currency: string
          id: string
          name: string
          seller_address: string
          status: Database["public"]["Enums"]["listings_statuses"]
          tags: string | null
          type: Database["public"]["Enums"]["listings_types"]
          updated_at: string | null
        }[]
      }
      transactions: {
        Args: { "": Database["public"]["Tables"]["listings"]["Row"] }
        Returns: {
          amount: number | null
          app_id: number
          chain_id: string
          created_at: string
          currency: string | null
          from_address: string
          group_id: string | null
          id: string
          note: string | null
          type: Database["public"]["Enums"]["transaction_type"]
        }[]
      }
      verify_arcpay_jwt_request: {
        Args: Record<PropertyKey, never>
        Returns: undefined
      }
    }
    Enums: {
      accounts_users_roles: "admin" | "moderator" | "member"
      assets_types: "arc72" | "offchain" | "asa"
      chains_enum:
        | "voi:testnet"
        | "voi:mainnet"
        | "algo:testnet"
        | "algo:mainnet"
      contract_tag_enum:
        | "clear"
        | "algo_asa_auction_approval"
        | "algo_asa_dutch_approval"
        | "algo_asa_sale_approval"
        | "algo_offchain_sale_approval"
        | "asa_asa_auction_approval"
        | "asa_asa_dutch_approval"
        | "asa_asa_sale_approval"
        | "asa_offchain_sale_approval"
        | "arc200_arc72_auction_approval"
        | "arc200_arc72_dutch_approval"
        | "arc200_arc72_sale_approval"
        | "arc200_offchain_sale_approval"
        | "voi_arc72_auction_approval"
        | "voi_arc72_dutch_approval"
        | "voi_arc72_sale_approval"
        | "voi_offchain_sale_approval"
      currency_type: "algo" | "asa" | "voi" | "arc200"
      listings_statuses: "pending" | "active" | "closed" | "cancelled"
      listings_types: "sale" | "auction" | "dutch"
      transaction_type:
        | "create"
        | "fund"
        | "buy"
        | "bid"
        | "close"
        | "update"
        | "cancel"
    }
    CompositeTypes: {
      composite_listing: {
        id: string | null
        created_at: string | null
        updated_at: string | null
        status: Database["public"]["Enums"]["listings_statuses"] | null
        chain: Database["public"]["Enums"]["chains_enum"] | null
        seller_address: string | null
        name: string | null
        type: Database["public"]["Enums"]["listings_types"] | null
        app_id: number | null
        currency: string | null
        currency_name: string | null
        currency_ticker: string | null
        currency_icon: string | null
        currency_type: Database["public"]["Enums"]["currency_type"] | null
        currency_decimals: number | null
        asset_id: string | null
        asset_thumbnail: string | null
        asset_type: Database["public"]["Enums"]["assets_types"] | null
        asset_qty: number | null
        asset_creator: string | null
        tags: string | null
        sale_price: number | null
        auction_start_price: number | null
        auction_increment: number | null
        auction_duration: number | null
        dutch_min_price: number | null
        dutch_max_price: number | null
        dutch_duration: number | null
      }
      transactions_count: {
        time: string | null
        count: number | null
      }
      transactions_volume: {
        time: string | null
        volume: number | null
        currency_id: string | null
        currency_ticker: string | null
      }
    }
  }
}

type DefaultSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof (Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? (Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      accounts_users_roles: ["admin", "moderator", "member"],
      assets_types: ["arc72", "offchain", "asa"],
      chains_enum: [
        "voi:testnet",
        "voi:mainnet",
        "algo:testnet",
        "algo:mainnet",
      ],
      contract_tag_enum: [
        "clear",
        "algo_asa_auction_approval",
        "algo_asa_dutch_approval",
        "algo_asa_sale_approval",
        "algo_offchain_sale_approval",
        "asa_asa_auction_approval",
        "asa_asa_dutch_approval",
        "asa_asa_sale_approval",
        "asa_offchain_sale_approval",
        "arc200_arc72_auction_approval",
        "arc200_arc72_dutch_approval",
        "arc200_arc72_sale_approval",
        "arc200_offchain_sale_approval",
        "voi_arc72_auction_approval",
        "voi_arc72_dutch_approval",
        "voi_arc72_sale_approval",
        "voi_offchain_sale_approval",
      ],
      currency_type: ["algo", "asa", "voi", "arc200"],
      listings_statuses: ["pending", "active", "closed", "cancelled"],
      listings_types: ["sale", "auction", "dutch"],
      transaction_type: [
        "create",
        "fund",
        "buy",
        "bid",
        "close",
        "update",
        "cancel",
      ],
    },
  },
} as const
