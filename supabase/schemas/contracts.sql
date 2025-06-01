-- Supabase Schema: contracts.sql

-- Table Definition: contracts_versions (from 20250413032235_updated_contracts.sql)
CREATE TABLE IF NOT EXISTS "public"."contracts_versions" (
    "version" integer NOT NULL,
    "chain_id" text NOT NULL, -- Foreign key to chains.id
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "contracts_versions_pkey" PRIMARY KEY ("version", "chain_id"),
    CONSTRAINT "contracts_versions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."contracts_versions" OWNER TO "postgres";

-- Table Definition: contracts (from 20250413032235_updated_contracts.sql)
-- Original contracts, contracts_tags, contracts_tags_association were dropped.
CREATE TABLE IF NOT EXISTS "public"."contracts" (
    "tag" "public"."contract_tag_enum" NOT NULL,
    "version" bigint NOT NULL, -- Part of composite FK to contracts_versions
    "chain_id" text NOT NULL, -- Part of composite FK to contracts_versions
    "byte_code" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "contracts_pkey" PRIMARY KEY ("version", "tag", "chain_id"),
    CONSTRAINT "contracts_version_fkey" FOREIGN KEY ("version", "chain_id") REFERENCES "public"."contracts_versions"("version", "chain_id") ON DELETE CASCADE
);
ALTER TABLE "public"."contracts" OWNER TO "postgres";

-- RLS and Grant Permissions (from 20250413032235_updated_contracts.sql)
-- Note: RLS is not explicitly enabled on these new tables in the migration, but grants are provided.
-- If RLS is intended, add: ALTER TABLE "public"."contracts_versions" ENABLE ROW LEVEL SECURITY;
-- If RLS is intended, add: ALTER TABLE "public"."contracts" ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE "public"."contracts_versions" TO "anon";
GRANT ALL ON TABLE "public"."contracts_versions" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts_versions" TO "service_role";

GRANT SELECT ON TABLE "public"."contracts" TO "anon";
GRANT ALL ON TABLE "public"."contracts" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts" TO "service_role";

-- RLS Policies for original contracts tables (from 20240915211603_inital_schema.sql)
-- These are for the OLD tables that were dropped. Included for historical context if needed, but not active for new schema.
/*
ALTER TABLE "public"."contracts" ENABLE ROW LEVEL SECURITY; -- Old table
CREATE POLICY "Allow public read access to all contracts" ON "public"."contracts" FOR SELECT USING (true);
CREATE POLICY "Allow admin to manage contracts" ON "public"."contracts" FOR ALL USING ((get_my_claim('role')) = 'admin'::text);

ALTER TABLE "public"."contracts_tags" ENABLE ROW LEVEL SECURITY; -- Old table
CREATE POLICY "Allow public read access to all contract tags" ON "public"."contracts_tags" FOR SELECT USING (true);
CREATE POLICY "Allow admin to manage contract tags" ON "public"."contracts_tags" FOR ALL USING ((get_my_claim('role')) = 'admin'::text);

ALTER TABLE "public"."contracts_tags_association" ENABLE ROW LEVEL SECURITY; -- Old table
CREATE POLICY "Allow public read access to all contract tag associations" ON "public"."contracts_tags_association" FOR SELECT USING (true);
CREATE POLICY "Allow admin to manage contract tag associations" ON "public"."contracts_tags_association" FOR ALL USING ((get_my_claim('role')) = 'admin'::text);
*/

-- Note: The table `sdk_versions` was dropped in 20250413032235_updated_contracts.sql.
-- DROP TABLE IF EXISTS "public"."sdk_versions";
