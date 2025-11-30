export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "12.2.3 (519615d)"
  }
  public: {
    Tables: {
      accounts: {
        Row: {
          authorize_requests: boolean
          created_at: string
          id: string
          name: string
          subscription_expiration_date: string | null
          subscription_id: number
        }
        Insert: {
          authorize_requests?: boolean
          created_at?: string
          id?: string
          name: string
          subscription_expiration_date?: string | null
          subscription_id?: number
        }
        Update: {
          authorize_requests?: boolean
          created_at?: string
          id?: string
          name?: string
          subscription_expiration_date?: string | null
          subscription_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "accounts_subscription_id_fkey"
            columns: ["subscription_id"]
            isOneToOne: false
            referencedRelation: "subscription_tiers"
            referencedColumns: ["id"]
          },
        ]
      }
      accounts_addresses: {
        Row: {
          account_id: string
          address: string
          created_at: string
          name: string | null
        }
        Insert: {
          account_id: string
          address: string
          created_at?: string
          name?: string | null
        }
        Update: {
          account_id?: string
          address?: string
          created_at?: string
          name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "accounts_addresses_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      accounts_currencies: {
        Row: {
          account_id: string
          created_at: string
          currency: number
          network_id: string
        }
        Insert: {
          account_id: string
          created_at?: string
          currency: number
          network_id: string
        }
        Update: {
          account_id?: string
          created_at?: string
          currency?: number
          network_id?: string
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
            foreignKeyName: "accounts_currencies_currency_fkey"
            columns: ["currency", "network_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id", "network_id"]
          },
        ]
      }
      accounts_networks_parameters: {
        Row: {
          account_id: string
          created_at: string
          enable_secondary: boolean
          network_id: string
          secondary_fee_address: string | null
          secondary_percentage_fee: number
        }
        Insert: {
          account_id: string
          created_at?: string
          enable_secondary?: boolean
          network_id: string
          secondary_fee_address?: string | null
          secondary_percentage_fee?: number
        }
        Update: {
          account_id?: string
          created_at?: string
          enable_secondary?: boolean
          network_id?: string
          secondary_fee_address?: string | null
          secondary_percentage_fee?: number
        }
        Relationships: [
          {
            foreignKeyName: "accounts_networks_parameters_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "accounts_networks_parameters_network_id_fkey"
            columns: ["network_id"]
            isOneToOne: false
            referencedRelation: "networks"
            referencedColumns: ["id"]
          },
        ]
      }
      accounts_secrets: {
        Row: {
          account_id: string
          created_at: string
          name: string
          secret: string
        }
        Insert: {
          account_id: string
          created_at?: string
          name: string
          secret?: string
        }
        Update: {
          account_id?: string
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
          account_id: string
          created_at: string
          role: Database["public"]["Enums"]["accounts_users_roles"]
          user_email: string
        }
        Insert: {
          account_id: string
          created_at?: string
          role: Database["public"]["Enums"]["accounts_users_roles"]
          user_email: string
        }
        Update: {
          account_id?: string
          created_at?: string
          role?: Database["public"]["Enums"]["accounts_users_roles"]
          user_email?: string
        }
        Relationships: [
          {
            foreignKeyName: "accounts_users_association_account_id_fkey"
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
          increment: number
          listing_id: string
          start_price: number
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          duration: number
          increment: number
          listing_id: string
          start_price: number
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          duration?: number
          increment?: number
          listing_id?: string
          start_price?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "auctions_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: true
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
        ]
      }
      contracts: {
        Row: {
          byte_code: string
          created_at: string
          network_id: string
          tag: Database["public"]["Enums"]["contract_tag_enum"]
          version: string
        }
        Insert: {
          byte_code: string
          created_at?: string
          network_id: string
          tag: Database["public"]["Enums"]["contract_tag_enum"]
          version: string
        }
        Update: {
          byte_code?: string
          created_at?: string
          network_id?: string
          tag?: Database["public"]["Enums"]["contract_tag_enum"]
          version?: string
        }
        Relationships: [
          {
            foreignKeyName: "contracts_version_fkey"
            columns: ["version", "network_id"]
            isOneToOne: false
            referencedRelation: "contracts_versions"
            referencedColumns: ["version", "network_id"]
          },
        ]
      }
      contracts_versions: {
        Row: {
          created_at: string
          network_id: string
          version: string
        }
        Insert: {
          created_at?: string
          network_id: string
          version: string
        }
        Update: {
          created_at?: string
          network_id?: string
          version?: string
        }
        Relationships: [
          {
            foreignKeyName: "contracts_versions_network_id_fkey"
            columns: ["network_id"]
            isOneToOne: false
            referencedRelation: "networks"
            referencedColumns: ["id"]
          },
        ]
      }
      currencies: {
        Row: {
          created_at: string
          decimals: number
          icon: string | null
          id: number
          is_public: boolean
          name: string
          network_id: string
          ticker: string
          type: Database["public"]["Enums"]["currency_type"]
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          decimals: number
          icon?: string | null
          id: number
          is_public?: boolean
          name: string
          network_id: string
          ticker: string
          type: Database["public"]["Enums"]["currency_type"]
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          decimals?: number
          icon?: string | null
          id?: number
          is_public?: boolean
          name?: string
          network_id?: string
          ticker?: string
          type?: Database["public"]["Enums"]["currency_type"]
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "currencies_network_id_fkey"
            columns: ["network_id"]
            isOneToOne: false
            referencedRelation: "networks"
            referencedColumns: ["id"]
          },
        ]
      }
      dutch_auctions: {
        Row: {
          created_at: string
          duration: number
          listing_id: string
          max_price: number | null
          min_price: number
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          duration: number
          listing_id: string
          max_price?: number | null
          min_price: number
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          duration?: number
          listing_id?: string
          max_price?: number | null
          min_price?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "dutch_auctions_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: true
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
        ]
      }
      listings: {
        Row: {
          account_id: string
          app_id: number
          asset_id: number
          asset_qty: number
          asset_thumbnail: string | null
          asset_type: Database["public"]["Enums"]["assets_types"]
          contract_version: string
          created_at: string
          creator_address: string
          currency: number
          id: string
          metadata: Json
          name: string
          network_id: string
          status: Database["public"]["Enums"]["listings_statuses"]
          type: Database["public"]["Enums"]["listings_types"]
          updated_at: string | null
          transactions: unknown | null
        }
        Insert: {
          account_id: string
          app_id: number
          asset_id: number
          asset_qty?: number
          asset_thumbnail?: string | null
          asset_type: Database["public"]["Enums"]["assets_types"]
          contract_version: string
          created_at?: string
          creator_address: string
          currency: number
          id?: string
          metadata?: Json
          name: string
          network_id: string
          status: Database["public"]["Enums"]["listings_statuses"]
          type: Database["public"]["Enums"]["listings_types"]
          updated_at?: string | null
        }
        Update: {
          account_id?: string
          app_id?: number
          asset_id?: number
          asset_qty?: number
          asset_thumbnail?: string | null
          asset_type?: Database["public"]["Enums"]["assets_types"]
          contract_version?: string
          created_at?: string
          creator_address?: string
          currency?: number
          id?: string
          metadata?: Json
          name?: string
          network_id?: string
          status?: Database["public"]["Enums"]["listings_statuses"]
          type?: Database["public"]["Enums"]["listings_types"]
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "listings_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listings_contract_version_network_id_fkey"
            columns: ["contract_version", "network_id"]
            isOneToOne: false
            referencedRelation: "contracts_versions"
            referencedColumns: ["version", "network_id"]
          },
          {
            foreignKeyName: "listings_currency_network_id_fkey"
            columns: ["currency", "network_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id", "network_id"]
          },
          {
            foreignKeyName: "listings_network_id_fkey"
            columns: ["network_id"]
            isOneToOne: false
            referencedRelation: "networks"
            referencedColumns: ["id"]
          },
        ]
      }
      networks: {
        Row: {
          chain: string
          created_at: string
          fee_proxy_app_id: number | null
          id: string
          last_indexed_at: string | null
          netid: string
          node_port: number
          node_token: string | null
          node_url: string
        }
        Insert: {
          chain: string
          created_at?: string
          fee_proxy_app_id?: number | null
          id: string
          last_indexed_at?: string | null
          netid: string
          node_port: number
          node_token?: string | null
          node_url: string
        }
        Update: {
          chain?: string
          created_at?: string
          fee_proxy_app_id?: number | null
          id?: string
          last_indexed_at?: string | null
          netid?: string
          node_port?: number
          node_token?: string | null
          node_url?: string
        }
        Relationships: []
      }
      sales: {
        Row: {
          created_at: string
          listing_id: string
          price: number
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          listing_id: string
          price: number
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          listing_id?: string
          price?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sales_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: true
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
      subscriptions_networks_parameters: {
        Row: {
          created_at: string
          flat_fees: number
          network_id: string
          sales_fees: number
          secondary_flat_fees: number
          secondary_sales_fees: number
          subscription_id: number
        }
        Insert: {
          created_at?: string
          flat_fees?: number
          network_id: string
          sales_fees?: number
          secondary_flat_fees?: number
          secondary_sales_fees?: number
          subscription_id: number
        }
        Update: {
          created_at?: string
          flat_fees?: number
          network_id?: string
          sales_fees?: number
          secondary_flat_fees?: number
          secondary_sales_fees?: number
          subscription_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "subscriptions_networks_parameters_network_id_fkey"
            columns: ["network_id"]
            isOneToOne: false
            referencedRelation: "networks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "subscriptions_networks_parameters_subscription_id_fkey"
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
          created_at: string
          currency: number
          from_address: string
          id: string
          metadata: Json
          network_id: string
          type: Database["public"]["Enums"]["transaction_type"]
          listings: Database["public"]["Tables"]["listings"]["Row"] | null
        }
        Insert: {
          amount?: number | null
          app_id: number
          created_at?: string
          currency: number
          from_address: string
          id: string
          metadata?: Json
          network_id: string
          type: Database["public"]["Enums"]["transaction_type"]
        }
        Update: {
          amount?: number | null
          app_id?: number
          created_at?: string
          currency?: number
          from_address?: string
          id?: string
          metadata?: Json
          network_id?: string
          type?: Database["public"]["Enums"]["transaction_type"]
        }
        Relationships: [
          {
            foreignKeyName: "transactions_currency_fkey"
            columns: ["currency", "network_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id", "network_id"]
          },
          {
            foreignKeyName: "transactions_network_id_fkey"
            columns: ["network_id"]
            isOneToOne: false
            referencedRelation: "networks"
            referencedColumns: ["id"]
          },
        ]
      }
      transactions_2025_08_24: {
        Row: {
          amount: number | null
          app_id: number
          created_at: string
          currency: number
          from_address: string
          id: string
          metadata: Json
          network_id: string
          type: Database["public"]["Enums"]["transaction_type"]
        }
        Insert: {
          amount?: number | null
          app_id: number
          created_at?: string
          currency: number
          from_address: string
          id: string
          metadata?: Json
          network_id: string
          type: Database["public"]["Enums"]["transaction_type"]
        }
        Update: {
          amount?: number | null
          app_id?: number
          created_at?: string
          currency?: number
          from_address?: string
          id?: string
          metadata?: Json
          network_id?: string
          type?: Database["public"]["Enums"]["transaction_type"]
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      create_account: {
        Args: { account_name: string }
        Returns: string
      }
      get_account_subscription_params: {
        Args: { p_account_id: string; p_network_id: string }
        Returns: Database["public"]["CompositeTypes"]["network_subscription_parameters"]
      }
      get_daily_sales_volume_timeseries: {
        Args: { account_id: string; network_id: string }
        Returns: Database["public"]["CompositeTypes"]["transactions_volume"][]
      }
      get_hourly_transactions_timeseries: {
        Args: { account_id: string; network_id: string }
        Returns: Database["public"]["CompositeTypes"]["transactions_count"][]
      }
      get_listing_by_id: {
        Args: { listing_id: string }
        Returns: Database["public"]["CompositeTypes"]["composite_listing"]
      }
      listings: {
        Args: { "": unknown }
        Returns: {
          account_id: string
          app_id: number
          asset_id: number
          asset_qty: number
          asset_thumbnail: string | null
          asset_type: Database["public"]["Enums"]["assets_types"]
          contract_version: string
          created_at: string
          creator_address: string
          currency: number
          id: string
          metadata: Json
          name: string
          network_id: string
          status: Database["public"]["Enums"]["listings_statuses"]
          type: Database["public"]["Enums"]["listings_types"]
          updated_at: string | null
        }[]
      }
      transactions: {
        Args: { "": Database["public"]["Tables"]["listings"]["Row"] }
        Returns: {
          amount: number | null
          app_id: number
          created_at: string
          currency: number
          from_address: string
          id: string
          metadata: Json
          network_id: string
          type: Database["public"]["Enums"]["transaction_type"]
        }[]
      }
    }
    Enums: {
      accounts_users_roles: "owner" | "admin" | "member"
      assets_types: "arc72" | "offchain" | "asa"
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
        network_id: string | null
        contract_version: string | null
        creator_address: string | null
        name: string | null
        type: Database["public"]["Enums"]["listings_types"] | null
        app_id: number | null
        currency: number | null
        currency_name: string | null
        currency_ticker: string | null
        currency_icon: string | null
        currency_type: Database["public"]["Enums"]["currency_type"] | null
        currency_decimals: number | null
        asset_id: string | null
        asset_thumbnail: string | null
        asset_type: Database["public"]["Enums"]["assets_types"] | null
        asset_qty: number | null
        metadata: Json | null
        sale_price: number | null
        auction_start_price: number | null
        auction_increment: number | null
        auction_duration: number | null
        dutch_min_price: number | null
        dutch_max_price: number | null
        dutch_duration: number | null
      }
      network_subscription_parameters: {
        allow_secondary_listings: boolean | null
        allow_custom_currencies: boolean | null
        flat_fees: number | null
        sales_fees: number | null
        secondary_flat_fees: number | null
        secondary_sales_fees: number | null
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

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
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
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
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
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
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
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      accounts_users_roles: ["owner", "admin", "member"],
      assets_types: ["arc72", "offchain", "asa"],
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
