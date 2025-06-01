-------------------- LISTINGS --------------------
CREATE TABLE IF NOT EXISTS "public"."listings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "account_id" bigint NOT NULL,
    "status" "public"."listings_statuses" NOT NULL,
    "seller_address" "text" NOT NULL,
    "name" "text" NOT NULL,
    "currency" "text" NOT NULL,
    "type" "public"."listings_types" NOT NULL,
    "app_id" bigint NOT NULL,
    "asset_id" "text" NOT NULL,
    "asset_thumbnail" "text",
    "asset_type" "public"."assets_types" NOT NULL,
    "asset_qty" double precision DEFAULT '1'::double precision NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "chain_id" "text" NOT NULL,
    "contract_version" integer,
    CONSTRAINT "listings_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "listings_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE,
    CONSTRAINT "listings_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id"),
    CONSTRAINT "listings_currency_chain_id_fkey" FOREIGN KEY ("currency", "chain_id") REFERENCES "public"."currencies"("id", "chain_id") ON DELETE CASCADE,
    CONSTRAINT "listings_contract_version_chain_id_fkey" FOREIGN KEY ("contract_version", "chain_id") REFERENCES "public"."contracts_versions"("version", "chain_id") ON DELETE RESTRICT

);

ALTER TABLE "public"."listings" OWNER TO "postgres";
CREATE INDEX IF NOT EXISTS "idx_listings" ON "public"."listings" ("account_id", "status", "chain_id", "currency", "type", "asset_type", "asset_id", "seller_address", "name");

-- RLS Policies for listings
ALTER TABLE "public"."listings" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."accounts" TO "anon";
GRANT ALL ON TABLE "public"."accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts" TO "service_role";
CREATE POLICY "Allow public read access to all listings" ON "public"."listings" FOR SELECT USING (true);

CREATE POLICY "Allow account members to manage listings" ON "public"."listings" FOR ALL
    USING (("account_id" IN ( SELECT "private"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")));

CREATE POLICY "Allow key based access for create" ON "public"."listings" FOR INSERT
    WITH CHECK (("account_id" = ("public"."get_key_account_id"(((current_setting('request.headers'::"text", true))::jsonb ->> 'x-api-key'::"text"), ((current_setting('request.headers'::"text", true))::jsonb ->> 'origin'::"text")))));

-- Functions

-- get_listing_by_id (adapted from 20240915211603_inital_schema.sql and composite_listing type)
-- Assumes composite_listing type in types.sql is:
-- CREATE TYPE "public"."composite_listing" AS (
--    "id" "uuid", "created_at" timestamp without time zone, "updated_at" timestamp without time zone,
--    "status" "public"."listings_statuses", "chain_id" "text", "seller_address" "text", "name" "text",
--    "type" "public"."listings_types", "app_id" bigint, "currency" "text", "currency_name" "text",
--    "currency_ticker" "text", "currency_icon" "text", "currency_type" "public"."currency_type",
--    "currency_decimals" bigint, "asset_id" "text", "asset_thumbnail" "text", "asset_type" "public"."assets_types",
--    "dutch_duration" integer
-- );
CREATE OR REPLACE FUNCTION "public"."get_listing_by_id"("p_listing_id" "uuid")
RETURNS SETOF "public"."composite_listing"
LANGUAGE "sql" STABLE SECURITY DEFINER
AS $_$
SELECT
    l.id,
    timezone('utc', l.created_at) as created_at,
    timezone('utc', l.updated_at) as updated_at,
    l.status,
    l.chain_id,
    l.seller_address,
    l.name,
    l.type,
    l.app_id,
    l.currency,
    c.name AS currency_name,
    c.ticker AS currency_ticker,
    c.icon_url AS currency_icon,
    c.type AS currency_type,
    c.decimals AS currency_decimals,
    l.asset_id,
    l.asset_thumbnail,
    l.asset_type,
    da.duration AS dutch_duration
FROM
    "public"."listings" l
LEFT JOIN
    "public"."currencies" c ON l.currency = c.id AND l.chain_id = c.chain_id
LEFT JOIN
    "public"."dutch_auctions" da ON l.id = da.listing_id AND l.type = 'dutch'
WHERE
    l.id = p_listing_id;
$_$;
ALTER FUNCTION "public"."get_listing_by_id"("uuid") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "public"."get_listing_by_id"("uuid") TO "anon", "authenticated", "service_role";

-- listings(public.transactions) function (from 20240915211603_inital_schema.sql)
-- The type public.transactions is defined by the current structure of the transactions table.
CREATE OR REPLACE FUNCTION "public"."listings"("tr" "public"."transactions")
RETURNS SETOF "public"."listings"
LANGUAGE "sql" STABLE
SET search_path = ''
AS $_$
    SELECT * FROM "public"."listings" WHERE "app_id" = "tr"."app_id";
$_$;
ALTER FUNCTION "public"."listings"("public"."transactions") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "public"."listings"("public"."transactions") TO "anon", "authenticated", "service_role";

