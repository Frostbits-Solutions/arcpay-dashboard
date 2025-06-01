-- Supabase Schema: currencies.sql

-- Table Definition: currencies
-- Source: Derived from migrations 20240915211603_inital_schema.sql and 20250413022634_added_chain_table.sql
CREATE TABLE IF NOT EXISTS "public"."currencies" (
    "id" "text" NOT NULL, -- Identifier for the currency, e.g., 'ALGO', 'USDC'
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text" NOT NULL, -- Full name of the currency, e.g., 'Algorand', 'USD Coin'
    "ticker" "text" NOT NULL, -- Ticker symbol, e.g., 'ALGO', 'USDC'
    "icon" "text", -- URL or path to the currency's icon
    "type" "public"."currency_type" NOT NULL, -- Type of currency, e.g., 'algo', 'asa', 'voi', 'arc200' (enum defined in types.sql)
    "decimals" bigint NOT NULL, -- Number of decimal places for the currency
    "is_public" boolean DEFAULT true NOT NULL, -- Whether the currency is publicly visible/usable (renamed from "visible" in 20250413022634)
    "chain_id" "text" NOT NULL -- Identifier for the chain this currency belongs to (FK to public.chains.id, added in 20250413022634)
);

-- Set ownership
ALTER TABLE "public"."currencies" OWNER TO "postgres";

-- Primary Key
-- Composite primary key established in migration 20250413022634_added_chain_table.sql.
-- Original PK in 20240915211603_inital_schema.sql was ("id", "chain").
ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_pkey" PRIMARY KEY ("id", "chain_id");

-- Foreign Keys
-- Foreign key to the chains table, added in migration 20250413022634_added_chain_table.sql.
ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id");

-- Enable Row Level Security
-- Enabled in migration 20240915211603_inital_schema.sql.
ALTER TABLE "public"."currencies" ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- No specific policies for "currencies" were defined in the migrations beyond enabling RLS.
-- Adding a common default policy for public read access, consistent with grants.
CREATE POLICY "Enable read access for all users" ON "public"."currencies"
    FOR SELECT USING (true);
-- Note: INSERT, UPDATE, DELETE operations would typically be restricted by other policies or rely on role privileges.
-- The existing grants are broad; RLS policies are the primary mechanism for fine-grained control.

-- Grant permissions
-- Grants from migration 20240915211603_inital_schema.sql.
GRANT ALL ON TABLE "public"."currencies" TO "anon";
GRANT ALL ON TABLE "public"."currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."currencies" TO "service_role";

-- Indexes
-- The primary key constraint automatically creates a unique index on ("id", "chain_id").
-- An additional index on "chain_id" can be beneficial for queries filtering only by chain.
CREATE INDEX IF NOT EXISTS "idx_currencies_chain_id" ON "public"."currencies" USING "btree" ("chain_id");

-- Comments on related entities:
-- The "public"."currency_type" enum is expected to be defined in a separate types.sql file.
-- The "public"."chains" table (and its "id" column) is a dependency for the "chain_id" foreign key.
-- Tables like "public"."listings" and "public"."accounts_currencies" have foreign keys referencing "public"."currencies"("id", "chain_id").

