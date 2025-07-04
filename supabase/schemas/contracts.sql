/*
# Contracts Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the contracts schema.

| Table               | anon                  | authenticated          | member                 | admin                  | owner                  |
|---------------------|----------------------|------------------------|------------------------|------------------------|------------------------|
| contracts_versions  | SELECT (read-only)   | SELECT (read-only)     | SELECT (read-only)     | SELECT (read-only)     | SELECT (read-only)     |
| contracts           | SELECT (read-only)   | SELECT (read-only)     | SELECT (read-only)     | SELECT (read-only)     | SELECT (read-only)     |

## Notes:
- All users (anon, authenticated, member, admin, owner) have read-only access to contracts data
- No users can modify contracts data through regular application interfaces
- The service_role has ALL permissions on all tables (superuser)
- RLS (Row-Level Security) policies enforce these permissions with universal read policies
- Contracts data is typically managed through administrative processes or migrations
- These tables serve as reference data for smart contract deployments and versioning
*/

-------------------- TYPES --------------------
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

-------------------- CONTRACTS_VERSIONS --------------------
CREATE TABLE IF NOT EXISTS "public"."contracts_versions" (
    "version" text NOT NULL,
    "chain_id" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "contracts_versions_pkey" PRIMARY KEY ("version", "chain_id"),
    CONSTRAINT "contracts_versions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE RESTRICT
);
ALTER TABLE "public"."contracts_versions" OWNER TO "postgres";

-- RLS for contracts_versions
ALTER TABLE "public"."contracts_versions" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."contracts_versions" TO "anon";
GRANT SELECT ON TABLE "public"."contracts_versions" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts_versions" TO "service_role";
CREATE POLICY "Allow public read access to all contracts versions" ON "public"."contracts_versions" FOR SELECT USING (true);

-------------------- CONTRACTS --------------------
CREATE TABLE IF NOT EXISTS "public"."contracts" (
    "tag" "public"."contract_tag_enum" NOT NULL,
    "version" text NOT NULL,
    "chain_id" text NOT NULL,
    "byte_code" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "contracts_pkey" PRIMARY KEY ("version", "tag", "chain_id"),
    CONSTRAINT "contracts_version_fkey" FOREIGN KEY ("version", "chain_id") REFERENCES "public"."contracts_versions"("version", "chain_id") ON DELETE CASCADE
);
ALTER TABLE "public"."contracts" OWNER TO "postgres";

-- RLS for contracts
ALTER TABLE "public"."contracts" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."contracts" TO "anon";
GRANT SELECT ON TABLE "public"."contracts" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts" TO "service_role";
CREATE POLICY "Allow public read access to all contracts" ON "public"."contracts" FOR SELECT USING (true);