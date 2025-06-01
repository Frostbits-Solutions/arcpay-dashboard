-- Supabase Schema: types.sql

-- Enum Types from 20240915211603_inital_schema.sql and active file
CREATE TYPE "public"."accounts_users_roles" AS ENUM (
    'owner',
    'admin',
    'moderator', -- as per active file
    'member'
);
ALTER TYPE "public"."accounts_users_roles" OWNER TO "postgres";

CREATE TYPE "public"."assets_types" AS ENUM (
    'arc72',
    'offchain', -- as per active file
    'asa'
);
ALTER TYPE "public"."assets_types" OWNER TO "postgres";

-- Note: Original 'chains' enum is renamed to 'chains_enum' in 20250413022634_added_chain_table.sql
-- The values here are from the active file, which is the version that gets renamed.
CREATE TYPE "public"."chains_enum" AS ENUM (
    'voi:testnet',
    'voi:mainnet',
    'algo:testnet',
    'algo:mainnet'
);
ALTER TYPE "public"."chains_enum" OWNER TO "postgres";

CREATE TYPE "public"."currency_type" AS ENUM (
    'algo',
    'asa', -- as per active file
    'voi', -- as per active file
    'arc200'
);
ALTER TYPE "public"."currency_type" OWNER TO "postgres";

CREATE TYPE "public"."listings_statuses" AS ENUM (
    'pending',
    'active', -- as per active file
    'closed', -- as per active file
    'cancelled'
);
ALTER TYPE "public"."listings_statuses" OWNER TO "postgres";

CREATE TYPE "public"."listings_types" AS ENUM (
    'sale',
    'auction', -- as per active file
    'dutch'
);
ALTER TYPE "public"."listings_types" OWNER TO "postgres";

CREATE TYPE "public"."transaction_type" AS ENUM (
    'create',
    'cancel'
);
ALTER TYPE "public"."transaction_type" OWNER TO "postgres";

-- Composite Types from 20240915211603_inital_schema.sql and active file
DROP TYPE IF EXISTS "public"."composite_listing";
CREATE TYPE "public"."composite_listing" AS (
    "id" uuid,
    "created_at" timestamp without time zone,
    "updated_at" timestamp without time zone,
    "status" public.listings_statuses,
    "chain_id" text,                       -- Corrected: was 'chain public.chains_enum'
    "seller_address" text,
    "name" text,
    "type" public.listings_types,
    "app_id" bigint,
    "currency" text,
    "currency_name" text,
    "currency_ticker" text,
    "currency_icon" text,
    "currency_type" public.currency_type,
    "currency_decimals" bigint,
    "asset_id" text,                       -- Added
    "asset_thumbnail" text,                -- Added
    "asset_type" public.assets_types,      -- Added
    "dutch_duration" integer
);
ALTER TYPE "public"."composite_listing" OWNER TO "postgres";

CREATE TYPE "public"."transactions_count" AS (
    "time" timestamp without time zone,
    "count" bigint
);
ALTER TYPE "public"."transactions_count" OWNER TO "postgres";

CREATE TYPE "public"."transactions_volume" AS (
    "time" timestamp without time zone,
    "currency_ticker" text -- Mismatch: inital_schema.sql has text, active file has no definition for this type. Using initial.
);
ALTER TYPE "public"."transactions_volume" OWNER TO "postgres";

-- Enum Type from 20250413032235_updated_contracts.sql
CREATE TYPE "public"."contract_tag_enum" AS ENUM (
    'clear',
    'algo_asa_auction_approval',
    'algo_asa_dutch_approval',
    'algo_asa_sale_approval',
    'algo_offchain_sale_approval',
    'asa_asa_auction_approval',
    'asa_asa_dutch_approval',
    'asa_asa_sale_approval',
    'asa_offchain_sale_approval',
    'arc200_arc72_auction_approval',
    'arc200_arc72_dutch_approval',
    'arc200_arc72_sale_approval',
    'arc200_offchain_sale_approval',
    'voi_arc72_auction_approval',
    'voi_arc72_dutch_approval',
    'voi_arc72_sale_approval',
    'voi_offchain_sale_approval'
);
ALTER TYPE "public"."contract_tag_enum" OWNER TO "postgres";
