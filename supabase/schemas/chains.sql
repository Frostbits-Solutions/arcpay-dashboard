-- Supabase Schema: chains.sql

-- Table Definition: chains (from 20250413022634_added_chain_table.sql)
CREATE TABLE IF NOT EXISTS "public"."chains" (
    "id" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    "last_indexed_at" timestamp without time zone,
    "fee_proxy_app_id" int8,
    CONSTRAINT "chains_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "public"."chains" OWNER TO "postgres";

-- Initial data insertion (as in migration)
-- This is data, not strictly schema, but included for completeness matching the migration step.
-- In a pure schema definition, this might be omitted or handled by seeding scripts.
INSERT INTO "public"."chains" ("id", "created_at")
SELECT DISTINCT unnest(enum_range(NULL::"public"."chains_enum"))::text, NOW()
ON CONFLICT (id) DO NOTHING;

-- RLS and Grant Permissions (from 20250413022634_added_chain_table.sql)
-- Note: RLS is not explicitly enabled on `chains` table in the migration, but grants are provided.
-- If RLS is intended, add: ALTER TABLE "public"."chains" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."chains" TO "anon";
GRANT ALL ON TABLE "public"."chains" TO "authenticated";
GRANT ALL ON TABLE "public"."chains" TO "service_role";

-- Foreign Key Constraints from other tables referencing chains.id
-- These would typically be defined in the respective table schemas but are listed here for context of chain usage.

-- From listings (in listings.sql)
-- ALTER TABLE "public"."listings" ADD CONSTRAINT "listings_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id");

-- From transactions (in transactions.sql)
-- ALTER TABLE "public"."transactions" ADD CONSTRAINT "transactions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id");

-- From currencies (in currencies.sql)
-- ALTER TABLE "public"."currencies" ADD CONSTRAINT "currencies_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id");

-- From accounts_chains_parameters (in accounts.sql)
ALTER TABLE "public"."accounts_chains_parameters" ADD CONSTRAINT "accounts_chains_parameters_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE;

-- From subscriptions_chains_parameters (in subscription_tiers.sql)
-- ALTER TABLE "public"."subscriptions_chains_parameters" ADD CONSTRAINT "subscriptions_chains_parameters_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE;

-- From contracts_versions (in contracts.sql)
-- ALTER TABLE "public"."contracts_versions" ADD CONSTRAINT "contracts_versions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE;

-- From contracts (in contracts.sql, indirectly via contracts_versions)
-- ALTER TABLE "public"."contracts" ADD CONSTRAINT "contracts_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE; (This would be part of the composite FK to contracts_versions)
