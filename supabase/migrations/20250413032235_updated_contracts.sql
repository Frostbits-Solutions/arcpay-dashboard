-- Drop contracts tables
-- First drop the association table that likely has foreign key constraints
DROP TABLE IF EXISTS "public"."contracts_tags_association";

-- Then drop the main tables
DROP TABLE IF EXISTS "public"."contracts";
DROP TABLE IF EXISTS "public"."contracts_tags";

-- Create the contracts_versions table with version and chain_id as primary key
CREATE TABLE IF NOT EXISTS "public"."contracts_versions" (
    "version" integer NOT NULL,
    "chain_id" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "contracts_versions_pkey" PRIMARY KEY ("version", "chain_id"),
    CONSTRAINT "contracts_versions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE
);

-- Create the enum type for contract tags
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

-- Create the contracts table with reference to contracts_versions
CREATE TABLE IF NOT EXISTS "public"."contracts" (
    "tag" "public"."contract_tag_enum" NOT NULL,
    "version" bigint NOT NULL,
    "chain_id" text NOT NULL,
    "byte_code" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "contracts_pkey" PRIMARY KEY ("version", "tag", "chain_id"),
    CONSTRAINT "contracts_version_fkey" FOREIGN KEY ("version", "chain_id") REFERENCES "public"."contracts_versions"("version", "chain_id") ON DELETE CASCADE
);

-- Set table ownership
ALTER TABLE "public"."contracts_versions" OWNER TO "postgres";
ALTER TABLE "public"."contracts" OWNER TO "postgres";

-- Grant permissions
GRANT SELECT ON TABLE "public"."contracts_versions" TO "anon";
GRANT ALL ON TABLE "public"."contracts_versions" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts_versions" TO "service_role";

GRANT SELECT ON TABLE "public"."contracts" TO "anon";
GRANT ALL ON TABLE "public"."contracts" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts" TO "service_role";

-- Add contract_version field to listings table
ALTER TABLE "public"."listings"
    ADD COLUMN "contract_version" integer;

-- Add foreign key constraint using composite key (contract_version, chain_id)
ALTER TABLE "public"."listings"
    ADD CONSTRAINT "listings_contract_version_chain_id_fkey"
    FOREIGN KEY ("contract_version", "chain_id")
    REFERENCES "public"."contracts_versions"("version", "chain_id") ON DELETE SET NULL;

DROP TABLE IF EXISTS "public"."sdk_versions";

-- Add index for performance
CREATE INDEX "idx_listings_contract_version" ON "public"."listings" ("contract_version", "chain_id");