/*
# Contracts Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the contracts schema.

| Table               | anon                  | authenticated          | member                 | admin                  | owner                  |
|---------------------|----------------------|------------------------|------------------------|------------------------|------------------------|
| contracts           | SELECT (read-only)   | SELECT (read-only)     | SELECT (read-only)     | SELECT (read-only)     | SELECT (read-only)     |

## Notes:
- All users (anon, authenticated, member, admin, owner) have read-only access to contracts data
- No users can modify contracts data through regular application interfaces
- The service_role has ALL permissions on all tables (superuser)
- RLS (Row-Level Security) policies enforce these permissions with universal read policies
- Contracts data is typically managed through administrative processes or migrations
- This table serves as reference data for smart contract deployments and versioning
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

-------------------- CONTRACTS --------------------
CREATE TABLE IF NOT EXISTS "public"."contracts" (
    "tag" "public"."contract_tag_enum" NOT NULL,
    "version" text NOT NULL,
    "network_id" text NOT NULL,
    "byte_code" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "contracts_pkey" PRIMARY KEY ("tag", "version", "network_id"),
    CONSTRAINT "contracts_network_id_fkey" FOREIGN KEY ("network_id") REFERENCES "public"."networks"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."contracts" OWNER TO "postgres";

-- RLS for contracts
ALTER TABLE "public"."contracts" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."contracts" TO "anon";
GRANT SELECT ON TABLE "public"."contracts" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts" TO "service_role";
CREATE POLICY "Allow public read access to all contracts" ON "public"."contracts" FOR SELECT USING (true);