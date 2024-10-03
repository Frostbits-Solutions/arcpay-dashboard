----------------------------------------------------------------
-- Initial set-up TODO
-- 1. Activate realtime on table transactions
-- 2. Create the supabase_realtime publication and add transactions table (https://supabase.com/docs/guides/realtime/subscribing-to-database-changes)
-- 3. Enable timeseries extension: timescaledb (https://supabase.com/docs/guides/database/extensions/timescaledb)
-- 4. Create the timeseries hypertable for table transactions on field created_at
----------------------------------------------------------------
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE SCHEMA IF NOT EXISTS "supabase_migrations";

ALTER SCHEMA "supabase_migrations" OWNER TO "postgres";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE SCHEMA IF NOT EXISTS "private";

CREATE TYPE "public"."accounts_users_roles" AS ENUM (
    'admin',
    'moderator',
    'member'
);

ALTER TYPE "public"."accounts_users_roles" OWNER TO "postgres";

CREATE TYPE "public"."assets_types" AS ENUM (
    'arc72',
    'offchain',
    'asa'
);

ALTER TYPE "public"."assets_types" OWNER TO "postgres";

CREATE TYPE "public"."chains" AS ENUM (
    'voi:testnet',
    'voi:mainnet',
    'algo:testnet',
    'algo:mainnet'
);

ALTER TYPE "public"."chains" OWNER TO "postgres";

CREATE TYPE "public"."currency_type" AS ENUM (
    'algo',
    'asa',
    'voi',
    'arc200'
);

ALTER TYPE "public"."currency_type" OWNER TO "postgres";

CREATE TYPE "public"."listings_statuses" AS ENUM (
    'pending',
    'active',
    'closed',
    'cancelled'
);

ALTER TYPE "public"."listings_statuses" OWNER TO "postgres";

CREATE TYPE "public"."listings_types" AS ENUM (
    'sale',
    'auction',
    'dutch'
);

ALTER TYPE "public"."listings_types" OWNER TO "postgres";

CREATE TYPE "public"."composite_listing" AS (
	"id" "uuid",
	"created_at" timestamp without time zone,
	"updated_at" timestamp without time zone,
	"status" "public"."listings_statuses",
	"chain" "public"."chains",
	"seller_address" "text",
	"name" "text",
	"type" "public"."listings_types",
	"app_id" bigint,
	"currency" "text",
	"currency_name" "text",
	"currency_ticker" "text",
	"currency_icon" "text",
	"currency_type" "public"."currency_type",
	"currency_decimals" bigint,
	"asset_id" "text",
	"asset_thumbnail" "text",
	"asset_type" "public"."assets_types",
	"asset_qty" double precision,
	"asset_creator" "text",
	"tags" "text",
	"sale_price" double precision,
	"auction_start_price" double precision,
	"auction_increment" double precision,
	"auction_duration" integer,
	"dutch_min_price" double precision,
	"dutch_max_price" double precision,
	"dutch_duration" integer
);

ALTER TYPE "public"."composite_listing" OWNER TO "postgres";

CREATE TYPE "public"."transaction_type" AS ENUM (
    'create',
    'fund',
    'buy',
    'bid',
    'close',
    'update',
    'cancel'
);

ALTER TYPE "public"."transaction_type" OWNER TO "postgres";

CREATE TYPE "public"."transactions_count" AS (
    "time" timestamp without time zone,
    "count" bigint
);

ALTER TYPE "public"."transactions_count" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" bigint, "chain" "public"."chains") RETURNS SETOF "public"."transactions_count"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$
    select
    "extensions"."time_bucket"('1 hour', t.created_at) AS time,
    count(t.id) AS count
    from "public"."transactions" t
    left join "public"."listings" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '168 hours' and t.chain = $2
    group by time
    order by time asc
    $_$;

ALTER FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" bigint, "chain" "public"."chains") OWNER TO "postgres";

CREATE TYPE "public"."transactions_volume" AS (
    "time" timestamp without time zone,
    "volume" float8,
    "currency_id" text,
    "currency_ticker" text
);

ALTER TYPE "public"."transactions_volume" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" bigint, "chain" "public"."chains") RETURNS SETOF "public"."transactions_volume"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$
    select
    "extensions"."time_bucket"('1 day', t.created_at) AS time,
    sum(t.amount) / POWER(10,c.decimals) AS volume,
    c.id as currency_id,
    c.ticker as currency_ticker
    from "public"."transactions" t
    left join "public"."currencies" c on t.currency = c.id and t.chain = c.chain
    left join "public"."listings" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '30 days' and t.type = 'buy' and t.chain = $2
    group by time, c.id, c.decimals, c.ticker
    order by time asc
    $_$;

ALTER FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" bigint, "chain" "public"."chains") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "private"."get_administrated_accounts_for_user"("user_email" "text") RETURNS SETOF bigint
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
    AS $_$select id from "public"."accounts" where owner_email = $1 union select account_id from "public"."accounts_users_association" where user_email = $1 and role = 'admin'$_$;

ALTER FUNCTION "private"."get_administrated_accounts_for_user"("user_email" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_key_account_id"("key" "text", "origin" "text") RETURNS bigint
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
    AS $_$select account_id from "public"."accounts_api_keys" where key::text = $1 and origin = $2$_$;

ALTER FUNCTION "public"."get_key_account_id"("key" "text", "origin" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_listing_by_id"("listing_id" "uuid") RETURNS "public"."composite_listing"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
    AS $$select
        l.id,
        l.created_at,
        l.updated_at,
        l.status,
        l.chain,
        l.seller_address,
        l.name,
        l.type,
        l.app_id,
        l.currency,
        c.name as "currency_name",
        c.ticker as "currency_ticker",
        c.icon as "currency_icon",
        c.type as "currency_type",
        c.decimals as "currency_decimals",
        l.asset_id,
        l.asset_thumbnail,
        l.asset_type,
        l.asset_qty,
        l.asset_creator,
        l.tags,
        s.price as "sale_price",
        a.start_price as "auction_start_price",
        a.increment as "auction_increment",
        a.duration as "auction_duration",
        d.min_price as "dutch_min_price",
        d.max_price as "dutch_max_price",
        d.duration as "dutch_duration"
    from public.listings l
        left join public.auctions a on a.listing_id = get_listing_by_id.listing_id
        left join public.dutch_auctions d on d.listing_id = get_listing_by_id.listing_id
        left join public.sales s on s.listing_id = get_listing_by_id.listing_id
        left join public.currencies c on (c.id = l.currency and c.chain = l.chain)
    where l.id = get_listing_by_id.listing_id$$;

ALTER FUNCTION "public"."get_listing_by_id"("listing_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "private"."get_member_accounts_for_user"("user_email" "text") RETURNS SETOF bigint
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
    AS $_$select id from public.accounts where owner_email = $1 union select account_id from public.accounts_users_association where user_email = $1 and (role = 'admin' or role = 'member')$_$;

ALTER FUNCTION "private"."get_member_accounts_for_user"("user_email" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."listings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "account_id" bigint NOT NULL,
    "status" "public"."listings_statuses" NOT NULL,
    "chain" "public"."chains" NOT NULL,
    "seller_address" "text" NOT NULL,
    "name" "text" NOT NULL,
    "currency" "text" NOT NULL,
    "type" "public"."listings_types" NOT NULL,
    "app_id" bigint NOT NULL,
    "asset_id" "text" NOT NULL,
    "asset_thumbnail" "text",
    "asset_type" "public"."assets_types" NOT NULL,
    "asset_qty" double precision DEFAULT '1'::double precision NOT NULL,
    "asset_creator" "text",
    "tags" "text"
);

ALTER TABLE "public"."listings" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "from_address" "text" NOT NULL,
    "chain" "public"."chains" NOT NULL,
    "app_id" bigint NOT NULL,
    "type" "public"."transaction_type" NOT NULL,
    "amount" double precision,
    "currency" "text",
    "group_id" "text",
    "note" "text"
);

ALTER TABLE "public"."transactions" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."listings"("public"."transactions") RETURNS SETOF "public"."listings"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$ select * from public.listings where app_id = $1.app_id $_$;

ALTER FUNCTION "public"."listings"("public"."transactions") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."transactions"("public"."listings") RETURNS SETOF "public"."transactions"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$ select * from public.transactions where app_id = $1.app_id $_$;

ALTER FUNCTION "public"."transactions"("public"."listings") OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."accounts" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" UNIQUE NOT NULL,
    "website" "text",
    "owner_email" "text" NOT NULL,
    "subscription_id" bigint DEFAULT '1'::bigint NOT NULL,
    "subscription_expiration_date" timestamp with time zone,
    "s_enable_secondary_sales" boolean DEFAULT false NOT NULL,
    "s_secondary_sales_percentage_fee" integer,
    "s_secondary_sales_fee_address" "text"
);

ALTER TABLE "public"."accounts" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."accounts_addresses" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "address" "text" NOT NULL,
    "name" "text",
    "account_id" bigint NOT NULL
);

ALTER TABLE "public"."accounts_addresses" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."accounts_api_keys" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "key" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "origin" "text" NOT NULL,
    "name" "text",
    "account_id" bigint NOT NULL
);

ALTER TABLE "public"."accounts_api_keys" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."accounts_currencies" (
    "account_id" bigint NOT NULL,
    "chain" "public"."chains" NOT NULL,
    "currency" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."accounts_currencies" OWNER TO "postgres";

ALTER TABLE "public"."accounts" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."accounts_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."accounts_users_association" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "role" "public"."accounts_users_roles" DEFAULT 'member'::"public"."accounts_users_roles" NOT NULL,
    "account_id" bigint NOT NULL,
    "user_email" "text" NOT NULL
);

ALTER TABLE "public"."accounts_users_association" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."auctions" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "listing_id" "uuid" NOT NULL,
    "start_price" double precision NOT NULL,
    "increment" double precision NOT NULL,
    "duration" integer NOT NULL
);

ALTER TABLE "public"."auctions" OWNER TO "postgres";

ALTER TABLE "public"."auctions" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."auctions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."contracts" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "byte_code" "text" NOT NULL,
    "name" "text"
);

ALTER TABLE "public"."contracts" OWNER TO "postgres";

ALTER TABLE "public"."contracts" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."contracts_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."contracts_tags" (
    "tag" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."contracts_tags" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."contracts_tags_association" (
    "chain" "public"."chains" NOT NULL,
    "tag" "text" NOT NULL,
    "version" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "contract" bigint NOT NULL
);

ALTER TABLE "public"."contracts_tags_association" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."currencies" (
    "id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "chain" "public"."chains" NOT NULL,
    "name" "text" NOT NULL,
    "ticker" "text" NOT NULL,
    "icon" "text",
    "type" "public"."currency_type" NOT NULL,
    "decimals" bigint NOT NULL,
    "visible" boolean DEFAULT true NOT NULL
);

ALTER TABLE "public"."currencies" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."dutch_auctions" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "listing_id" "uuid" NOT NULL,
    "min_price" double precision NOT NULL,
    "max_price" double precision,
    "duration" integer NOT NULL
);

ALTER TABLE "public"."dutch_auctions" OWNER TO "postgres";

ALTER TABLE "public"."dutch_auctions" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."dutch_auctions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."sales" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "listing_id" "uuid" NOT NULL,
    "price" double precision NOT NULL
);

ALTER TABLE "public"."sales" OWNER TO "postgres";

ALTER TABLE "public"."sales" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."sales_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."sdk_versions" (
    "id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "changelog" "text"
);

ALTER TABLE "public"."sdk_versions" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."subscription_tiers" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text" NOT NULL,
    "listing_flat_fee" double precision NOT NULL,
    "sale_percentage_fee" double precision NOT NULL,
    "allow_secondary_sales" boolean DEFAULT false NOT NULL,
    "secondary_listing_flat_fee" double precision,
    "secondary_sale_percentage_fee" double precision,
    "allow_premium_contracts" boolean DEFAULT false NOT NULL,
    "duration" bigint
);

ALTER TABLE "public"."subscription_tiers" OWNER TO "postgres";

ALTER TABLE "public"."subscription_tiers" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."subscription_tiers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "supabase_migrations"."schema_migrations" (
    "version" "text" NOT NULL,
    "statements" "text"[],
    "name" "text"
);

CREATE OR REPLACE FUNCTION "public"."get_account_subscription"("account_id" bigint) RETURNS "public"."subscription_tiers"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
    AS $_$select * from "public"."subscription_tiers" where (id IN ( SELECT "private"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")) and id = (select subscription_id from "public"."accounts" where id = $1)$_$;

ALTER FUNCTION "public"."get_account_subscription"("account_id" bigint) OWNER TO "postgres";

ALTER TABLE "supabase_migrations"."schema_migrations" OWNER TO "postgres";

ALTER TABLE ONLY "public"."accounts_addresses"
    ADD CONSTRAINT "accounts_addresses_address_key" UNIQUE ("address");

ALTER TABLE ONLY "public"."accounts_addresses"
    ADD CONSTRAINT "accounts_addresses_pkey" PRIMARY KEY ("address");

ALTER TABLE ONLY "public"."accounts_api_keys"
    ADD CONSTRAINT "accounts_api_keys_key_key" UNIQUE ("key");

ALTER TABLE ONLY "public"."accounts_api_keys"
    ADD CONSTRAINT "accounts_api_keys_pkey" PRIMARY KEY ("key");

ALTER TABLE ONLY "public"."accounts_currencies"
    ADD CONSTRAINT "accounts_currencies_pkey" PRIMARY KEY ("account_id", "chain", "currency");

ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."accounts_users_association"
    ADD CONSTRAINT "accounts_users_association_pkey" PRIMARY KEY ("account_id", "user_email");

ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."contracts"
    ADD CONSTRAINT "contracts_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."contracts_tags_association"
    ADD CONSTRAINT "contracts_tags_association_pkey" PRIMARY KEY ("chain", "tag", "version");

ALTER TABLE ONLY "public"."contracts_tags"
    ADD CONSTRAINT "contracts_tags_pkey" PRIMARY KEY ("tag");

ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_pkey" PRIMARY KEY ("id", "chain");

ALTER TABLE ONLY "public"."dutch_auctions"
    ADD CONSTRAINT "dutch_auctions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."sdk_versions"
    ADD CONSTRAINT "sdk_versions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."subscription_tiers"
    ADD CONSTRAINT "subscription_tiers_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("id", "created_at");

CREATE INDEX "idx_auctions" ON "public"."auctions" USING "btree" ("listing_id");

CREATE INDEX "idx_dutch_auctions" ON "public"."dutch_auctions" USING "btree" ("listing_id");

CREATE INDEX "idx_listings" ON "public"."listings" USING "btree" ("account_id", "status", "chain", "currency", "type", "asset_type");

CREATE INDEX "idx_sales" ON "public"."sales" USING "btree" ("listing_id");

CREATE INDEX "idx_transactions" ON "public"."transactions" USING "btree" ("chain", "app_id");

ALTER TABLE ONLY "public"."accounts_currencies"
    ADD CONSTRAINT "accounts_currencies_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."accounts_currencies"
    ADD CONSTRAINT "accounts_currencies_chain_currency_fkey" FOREIGN KEY ("chain", "currency") REFERENCES "public"."currencies"("chain", "id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."contracts_tags_association"
    ADD CONSTRAINT "contracts_tags_association_contract_fkey" FOREIGN KEY ("contract") REFERENCES "public"."contracts"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."contracts_tags_association"
    ADD CONSTRAINT "contracts_tags_association_tag_fkey" FOREIGN KEY ("tag") REFERENCES "public"."contracts_tags"("tag") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_listing_currency_chain_fkey" FOREIGN KEY ("currency", "chain") REFERENCES "public"."currencies"("id", "chain");

ALTER TABLE ONLY "public"."accounts_addresses"
    ADD CONSTRAINT "public_accounts_addresses_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."accounts_api_keys"
    ADD CONSTRAINT "public_accounts_api_keys_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "public_accounts_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "public"."subscription_tiers"("id") ON DELETE SET DEFAULT;

ALTER TABLE ONLY "public"."accounts_users_association"
    ADD CONSTRAINT "public_accounts_users_association_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "public_auctions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."dutch_auctions"
    ADD CONSTRAINT "public_dutch_auctions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "public_listings_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "public_sales_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;

CREATE POLICY "Enable insert for authenticated users only" ON "public"."accounts" FOR INSERT TO "authenticated" WITH CHECK (("auth"."email"() = "owner_email"));

CREATE POLICY "Enable read access for API keys" ON "public"."accounts_currencies" FOR SELECT USING (("account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")));

CREATE POLICY "Enable read access for API keys" ON "public"."auctions" FOR SELECT USING (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")))));

CREATE POLICY "Enable read access for API keys" ON "public"."dutch_auctions" FOR SELECT USING (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")))));

CREATE POLICY "Enable read access for API keys" ON "public"."listings" FOR SELECT USING (("account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")));

CREATE POLICY "Enable read access for API keys" ON "public"."sales" FOR SELECT USING (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")))));

CREATE POLICY "Enable read access for all users" ON "public"."contracts" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."contracts_tags" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."contracts_tags_association" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."currencies" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."sdk_versions" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."transactions" FOR SELECT USING (true);

CREATE POLICY "Enable select for users based on user_email" ON "public"."accounts_users_association" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."email"() AS "email") = "user_email"));

CREATE POLICY "Enable write access for API keys" ON "public"."auctions" FOR INSERT WITH CHECK (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")))));

CREATE POLICY "Enable write access for API keys" ON "public"."dutch_auctions" FOR INSERT WITH CHECK (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")))));

CREATE POLICY "Enable write access for API keys" ON "public"."listings" FOR INSERT WITH CHECK (("account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")));

CREATE POLICY "Enable write access for API keys" ON "public"."sales" FOR INSERT WITH CHECK (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" = ( SELECT "public"."get_key_account_id"((("current_setting"('request.headers'::"text", true))::"json" ->> 'x-arcpay-key'::"text"), (("current_setting"('request.headers'::"text", true))::"json" ->> 'origin'::"text")) AS "get_key_account_id")))));

CREATE POLICY "Members can manage auctions" ON "public"."auctions" TO "authenticated" USING (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" IN ( SELECT "private"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")))));

CREATE POLICY "Members can manage dutch auctions" ON "public"."dutch_auctions" TO "authenticated" USING (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" IN ( SELECT "private"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")))));

CREATE POLICY "Members can manage listings" ON "public"."listings" TO "authenticated" USING (("account_id" IN ( SELECT "private"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")));

CREATE POLICY "Members can manage sales" ON "public"."sales" TO "authenticated" USING (("listing_id" IN ( SELECT "listings"."id"
   FROM "public"."listings"
  WHERE ("listings"."account_id" IN ( SELECT "private"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")))));

CREATE POLICY "Members can read accounts" ON "public"."accounts" FOR SELECT TO "authenticated" USING (("id" IN ( SELECT "private"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")));

CREATE POLICY "Owner and admins can manage account addresses" ON "public"."accounts_addresses" TO "authenticated" USING (("account_id" IN ( SELECT "private"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner and admins can manage account api keys" ON "public"."accounts_api_keys" TO "authenticated" USING (("account_id" IN ( SELECT "private"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner and admins can manage account currencies" ON "public"."accounts_currencies" TO "authenticated" USING (("account_id" IN ( SELECT "private"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner and admins can manage account users" ON "public"."accounts_users_association" TO "authenticated" USING (("account_id" IN ( SELECT "private"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner and admins can update account settings" ON "public"."accounts" FOR UPDATE TO "authenticated" USING (("id" IN ( SELECT "private"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner can delete account" ON "public"."accounts" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."email"() AS "email") = "owner_email"));

ALTER TABLE "public"."accounts" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."accounts_addresses" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."accounts_api_keys" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."accounts_currencies" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."accounts_users_association" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."auctions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."contracts" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."contracts_tags" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."contracts_tags_association" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."currencies" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."dutch_auctions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."listings" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."sdk_versions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."subscription_tiers" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" bigint, "chain" "public"."chains") TO "anon";
GRANT ALL ON FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" bigint, "chain" "public"."chains") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" bigint, "chain" "public"."chains") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" bigint, "chain" "public"."chains") TO "anon";
GRANT ALL ON FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" bigint, "chain" "public"."chains") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" bigint, "chain" "public"."chains") TO "service_role";

GRANT ALL ON FUNCTION "private"."get_administrated_accounts_for_user"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "private"."get_administrated_accounts_for_user"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "private"."get_administrated_accounts_for_user"("user_email" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_key_account_id"("key" "text", "origin" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_key_account_id"("key" "text", "origin" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_key_account_id"("key" "text", "origin" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_account_subscription"("account_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_account_subscription"("account_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_account_subscription"("account_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."get_listing_by_id"("listing_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_listing_by_id"("listing_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_listing_by_id"("listing_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "private"."get_member_accounts_for_user"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "private"."get_member_accounts_for_user"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "private"."get_member_accounts_for_user"("user_email" "text") TO "service_role";

GRANT ALL ON TABLE "public"."listings" TO "anon";
GRANT ALL ON TABLE "public"."listings" TO "authenticated";
GRANT ALL ON TABLE "public"."listings" TO "service_role";

GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";

GRANT ALL ON FUNCTION "public"."listings"("public"."transactions") TO "anon";
GRANT ALL ON FUNCTION "public"."listings"("public"."transactions") TO "authenticated";
GRANT ALL ON FUNCTION "public"."listings"("public"."transactions") TO "service_role";

GRANT ALL ON FUNCTION "public"."transactions"("public"."listings") TO "anon";
GRANT ALL ON FUNCTION "public"."transactions"("public"."listings") TO "authenticated";
GRANT ALL ON FUNCTION "public"."transactions"("public"."listings") TO "service_role";

GRANT ALL ON TABLE "public"."accounts" TO "anon";
GRANT ALL ON TABLE "public"."accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts" TO "service_role";

GRANT ALL ON TABLE "public"."accounts_addresses" TO "anon";
GRANT ALL ON TABLE "public"."accounts_addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_addresses" TO "service_role";

GRANT ALL ON TABLE "public"."accounts_api_keys" TO "anon";
GRANT ALL ON TABLE "public"."accounts_api_keys" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_api_keys" TO "service_role";

GRANT ALL ON TABLE "public"."accounts_currencies" TO "anon";
GRANT ALL ON TABLE "public"."accounts_currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_currencies" TO "service_role";

GRANT ALL ON SEQUENCE "public"."accounts_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."accounts_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."accounts_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."accounts_users_association" TO "anon";
GRANT ALL ON TABLE "public"."accounts_users_association" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_users_association" TO "service_role";

GRANT ALL ON TABLE "public"."auctions" TO "anon";
GRANT ALL ON TABLE "public"."auctions" TO "authenticated";
GRANT ALL ON TABLE "public"."auctions" TO "service_role";

GRANT ALL ON SEQUENCE "public"."auctions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."auctions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."auctions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."contracts" TO "anon";
GRANT ALL ON TABLE "public"."contracts" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts" TO "service_role";

GRANT ALL ON SEQUENCE "public"."contracts_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."contracts_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."contracts_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."contracts_tags" TO "anon";
GRANT ALL ON TABLE "public"."contracts_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts_tags" TO "service_role";

GRANT ALL ON TABLE "public"."contracts_tags_association" TO "anon";
GRANT ALL ON TABLE "public"."contracts_tags_association" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts_tags_association" TO "service_role";

GRANT ALL ON TABLE "public"."currencies" TO "anon";
GRANT ALL ON TABLE "public"."currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."currencies" TO "service_role";

GRANT ALL ON TABLE "public"."dutch_auctions" TO "anon";
GRANT ALL ON TABLE "public"."dutch_auctions" TO "authenticated";
GRANT ALL ON TABLE "public"."dutch_auctions" TO "service_role";

GRANT ALL ON SEQUENCE "public"."dutch_auctions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."dutch_auctions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."dutch_auctions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."sales" TO "anon";
GRANT ALL ON TABLE "public"."sales" TO "authenticated";
GRANT ALL ON TABLE "public"."sales" TO "service_role";

GRANT ALL ON SEQUENCE "public"."sales_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."sales_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."sales_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."sdk_versions" TO "anon";
GRANT ALL ON TABLE "public"."sdk_versions" TO "authenticated";
GRANT ALL ON TABLE "public"."sdk_versions" TO "service_role";

GRANT ALL ON TABLE "public"."subscription_tiers" TO "anon";
GRANT ALL ON TABLE "public"."subscription_tiers" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_tiers" TO "service_role";

GRANT ALL ON SEQUENCE "public"."subscription_tiers_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."subscription_tiers_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."subscription_tiers_id_seq" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
