-- Create accounts_chains_parameters table
CREATE TABLE IF NOT EXISTS "public"."accounts_chains_parameters" (
    "account_id" bigint NOT NULL,
    "chain_id" text NOT NULL,
    "enable_secondary" boolean NOT NULL DEFAULT false,
    "secondary_percentage_fee" float NOT NULL DEFAULT 0,
    "secondary_fee_address" text,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "accounts_chains_parameters_pkey" PRIMARY KEY ("account_id", "chain_id"),
    CONSTRAINT "accounts_chains_parameters_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE,
    CONSTRAINT "accounts_chains_parameters_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE
);

-- Set table ownership
ALTER TABLE "public"."accounts_chains_parameters" OWNER TO "postgres";

-- Grant permissions (read-only for anon, full access for authenticated and service_role)
GRANT SELECT ON TABLE "public"."accounts_chains_parameters" TO "anon";
GRANT ALL ON TABLE "public"."accounts_chains_parameters" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_chains_parameters" TO "service_role";

-- Remove secondary sales related fields from accounts table
-- These settings are now managed in accounts_chains_parameters on a per-chain basis
ALTER TABLE "public"."accounts"
    DROP COLUMN IF EXISTS "s_enable_secondary_sales",
    DROP COLUMN IF EXISTS "s_secondary_sales_percentage_fee",
    DROP COLUMN IF EXISTS "s_secondary_sales_fee_address",
    DROP COLUMN IF EXISTS "website";

-- Remove columns from subscription_tiers table
-- These settings are now managed elsewhere
ALTER TABLE "public"."subscription_tiers"
    DROP COLUMN IF EXISTS "updated_at",
    DROP COLUMN IF EXISTS "listing_flat_fee",
    DROP COLUMN IF EXISTS "sale_percentage_fee",
    DROP COLUMN IF EXISTS "allow_secondary_sales",
    DROP COLUMN IF EXISTS "secondary_listing_flat_fee",
    DROP COLUMN IF EXISTS "secondary_sale_percentage_fee",
    DROP COLUMN IF EXISTS "allow_premium_contracts";

-- Add new fields to subscription_tiers table
ALTER TABLE "public"."subscription_tiers"
    ADD COLUMN "allow_secondary_listings" boolean NOT NULL DEFAULT false,
    ADD COLUMN "allow_custom_currencies" boolean NOT NULL DEFAULT false;


-- Create subscriptions_chains_parameters table
CREATE TABLE IF NOT EXISTS "public"."subscriptions_chains_parameters" (
    "subscription_id" bigint NOT NULL,
    "chain_id" text NOT NULL,
    "flat_fees" float NOT NULL DEFAULT 10,
    "sales_fees" float NOT NULL DEFAULT 0,
    "secondary_flat_fees" float NOT NULL DEFAULT 20,
    "secondary_sales_fees" float NOT NULL DEFAULT 0,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "subscriptions_chains_parameters_pkey" PRIMARY KEY ("subscription_id", "chain_id"),
    CONSTRAINT "subscriptions_chains_parameters_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "public"."subscription_tiers"("id") ON DELETE CASCADE,
    CONSTRAINT "subscriptions_chains_parameters_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE
);

-- Set table ownership
ALTER TABLE "public"."subscriptions_chains_parameters" OWNER TO "postgres";

-- Grant permissions (read-only for anon, full access for authenticated and service_role)
GRANT SELECT ON TABLE "public"."subscriptions_chains_parameters" TO "anon";
GRANT ALL ON TABLE "public"."subscriptions_chains_parameters" TO "authenticated";
GRANT ALL ON TABLE "public"."subscriptions_chains_parameters" TO "service_role";