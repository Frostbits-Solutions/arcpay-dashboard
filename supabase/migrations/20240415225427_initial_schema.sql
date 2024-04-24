
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

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE SCHEMA IF NOT EXISTS "supabase_migrations";

ALTER SCHEMA "supabase_migrations" OWNER TO "postgres";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE TYPE "public"."accounts_users_roles" AS ENUM (
    'admin',
    'moderator',
    'member'
);

ALTER TYPE "public"."accounts_users_roles" OWNER TO "postgres";

CREATE TYPE "public"."assets_types" AS ENUM (
    'ARC72',
    'OFFCHAIN'
);

ALTER TYPE "public"."assets_types" OWNER TO "postgres";

CREATE TYPE "public"."listings_statuses" AS ENUM (
    'pending',
    'active',
    'closed'
);

ALTER TYPE "public"."listings_statuses" OWNER TO "postgres";

CREATE TYPE "public"."listings_types" AS ENUM (
    'sale',
    'auction'
);

ALTER TYPE "public"."listings_types" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_administrated_accounts_for_user"("user_email" "text") RETURNS SETOF bigint
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $_$select id from accounts where owner_email = $1 union select account_id from accounts_users_association where user_email = $1 and role = 'admin'$_$;

ALTER FUNCTION "public"."get_administrated_accounts_for_user"("user_email" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_member_accounts_for_user"("user_email" "text") RETURNS SETOF bigint
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $_$select id from accounts where owner_email = $1 union select account_id from accounts_users_association where user_email = $1 and (role = 'admin' or role = 'member')$_$;

ALTER FUNCTION "public"."get_member_accounts_for_user"("user_email" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."filter_public_listings"("listing_id" "uuid") RETURNS boolean
 LANGUAGE "sql" STABLE SECURITY DEFINER
 AS $_$EXISTS (SELECT 1 FROM listings WHERE id = listing_id)$_$;

ALTER FUNCTION "public"."filter_public_listings"("listing_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."accounts" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" text NOT NULL,
    "owner_email" "text" NOT NULL,
    "subscription_id" bigint DEFAULT '0'::bigint NOT NULL,
    "subscription_expiration_date" timestamp with time zone,
    "s_enable_secondary_sales" boolean DEFAULT false NOT NULL,
    "s_secondary_sales_percentage_fee" integer
);

ALTER TABLE "public"."accounts" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."accounts_addresses" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "address" text NOT NULL,
    "name" text,
    "account_id" bigint NOT NULL
);

ALTER TABLE "public"."accounts_addresses" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."accounts_api_keys" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "key" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "domain" text NOT NULL,
    "name" text,
    "account_id" bigint NOT NULL
);

ALTER TABLE "public"."accounts_api_keys" OWNER TO "postgres";

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
    "min_increment" double precision NOT NULL,
    "duration" integer NOT NULL,
    "type" text NOT NULL
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

CREATE TABLE IF NOT EXISTS "public"."currencies" (
    "id" text NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" text NOT NULL,
    "ticker" text NOT NULL
);

ALTER TABLE "public"."currencies" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."listings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "account_id" bigint NOT NULL,
    "status" "public"."listings_statuses" NOT NULL,
    "seller_address" text NOT NULL,
    "listing_currency" text NOT NULL,
    "listing_type" "public"."listings_types" NOT NULL,
    "contract_address" text NOT NULL,
    "asset_id" text NOT NULL,
    "asset_name" text NOT NULL,
    "asset_thumbnail" text,
    "asset_type" "public"."assets_types" NOT NULL,
    "asset_qty" double precision DEFAULT '1'::double precision NOT NULL,
    "asset_creator" text,
    "tags" text
);

ALTER TABLE "public"."listings" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."sales" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "listing_id" "uuid" NOT NULL,
    "asking_price" double precision NOT NULL
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

CREATE TABLE IF NOT EXISTS "public"."subscription_tiers" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" text NOT NULL,
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

CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "id" text NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "from_address" text NOT NULL,
    "contract_address" text NOT NULL,
    "type" text NOT NULL,
    "amount" double precision NOT NULL,
    "currency" text NOT NULL
);

ALTER TABLE "public"."transactions" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "supabase_migrations"."schema_migrations" (
    "version" "text" NOT NULL,
    "statements" "text"[],
    "name" "text"
);

ALTER TABLE "supabase_migrations"."schema_migrations" OWNER TO "postgres";

ALTER TABLE ONLY "public"."accounts_addresses"
    ADD CONSTRAINT "accounts_addresses_address_key" UNIQUE ("address");

ALTER TABLE ONLY "public"."accounts_addresses"
    ADD CONSTRAINT "accounts_addresses_pkey" PRIMARY KEY ("address");

ALTER TABLE ONLY "public"."accounts_api_keys"
    ADD CONSTRAINT "accounts_api_keys_key_key" UNIQUE ("key");

ALTER TABLE ONLY "public"."accounts_api_keys"
    ADD CONSTRAINT "accounts_api_keys_pkey" PRIMARY KEY ("key");

ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."accounts_users_association"
    ADD CONSTRAINT "accounts_users_association_pkey" PRIMARY KEY ("account_id", "user_email");

ALTER TABLE ONLY "public"."auctions"
    ADD CONSTRAINT "auctions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "listings_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."subscription_tiers"
    ADD CONSTRAINT "subscription_tiers_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("id");

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

ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "public_listings_listing_currency_fkey" FOREIGN KEY ("listing_currency") REFERENCES "public"."currencies"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."listings"
    ADD CONSTRAINT "public_listings_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "public_sales_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE;

CREATE POLICY "Enable insert for authenticated users only" ON "public"."accounts" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable select for users based on user_email" ON "public"."accounts_users_association" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."email"() AS "email") = "user_email"));

CREATE POLICY "Owner and admins can manage account addresses" ON "public"."accounts_addresses" TO "authenticated" USING (("account_id" IN ( SELECT "public"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner and admins can manage account api keys" ON "public"."accounts_api_keys" TO "authenticated" USING (("account_id" IN ( SELECT "public"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner and admins can manage account users" ON "public"."accounts_users_association" TO "authenticated" USING (("account_id" IN ( SELECT "public"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner and admins can update account settings" ON "public"."accounts" FOR UPDATE TO "authenticated" USING (("id" IN ( SELECT "public"."get_administrated_accounts_for_user"("auth"."email"()) AS "get_administrated_accounts_for_user")));

CREATE POLICY "Owner can delete account" ON "public"."accounts" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."email"() AS "email") = "owner_email"));

CREATE POLICY "Members can manage listings" ON "public"."listings" FOR ALL TO "authenticated" USING (("account_id" IN ( SELECT "public"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user")));

CREATE POLICY "Anon can select one listing" ON "public"."listings" FOR SELECT TO "public" USING ("public"."filter_public_listings"("id"));

CREATE POLICY "Anon can select one sale" ON "public"."sales" FOR SELECT TO "public" USING ("public"."filter_public_listings"("listing_id"));

CREATE POLICY "Anon can select one auction" ON "public"."auctions" FOR SELECT TO "public" USING ("public"."filter_public_listings"("listing_id"));

CREATE POLICY "Enable read access for all users" ON "public"."currencies" FOR SELECT TO "public" USING (true);

CREATE POLICY "Members can manage sales" ON "public"."sales" FOR ALL TO "authenticated" USING (("listing_id" IN ( SELECT "id" FROM "public"."listings" WHERE "account_id" IN ( SELECT "public"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user"))));

CREATE POLICY "Members can manage auctions" ON "public"."auctions" FOR ALL TO "authenticated" USING (("listing_id" IN ( SELECT "id" FROM "public"."listings" WHERE "account_id" IN ( SELECT "public"."get_member_accounts_for_user"("auth"."email"()) AS "get_member_accounts_for_user"))));

CREATE POLICY "Enable read access for all users" ON "public"."transactions" FOR SELECT TO "public" USING (true);

ALTER TABLE "public"."accounts" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."accounts_addresses" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."accounts_api_keys" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."accounts_users_association" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."auctions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."currencies" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."listings" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."subscription_tiers" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."get_administrated_accounts_for_user"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_administrated_accounts_for_user"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_administrated_accounts_for_user"("user_email" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_member_accounts_for_user"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_member_accounts_for_user"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_member_accounts_for_user"("user_email" "text") TO "service_role";

GRANT ALL ON TABLE "public"."accounts" TO "anon";
GRANT ALL ON TABLE "public"."accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts" TO "service_role";

GRANT ALL ON TABLE "public"."accounts_addresses" TO "anon";
GRANT ALL ON TABLE "public"."accounts_addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_addresses" TO "service_role";

GRANT ALL ON TABLE "public"."accounts_api_keys" TO "anon";
GRANT ALL ON TABLE "public"."accounts_api_keys" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_api_keys" TO "service_role";

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

GRANT ALL ON TABLE "public"."currencies" TO "anon";
GRANT ALL ON TABLE "public"."currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."currencies" TO "service_role";

GRANT ALL ON TABLE "public"."listings" TO "anon";
GRANT ALL ON TABLE "public"."listings" TO "authenticated";
GRANT ALL ON TABLE "public"."listings" TO "service_role";

GRANT ALL ON TABLE "public"."sales" TO "anon";
GRANT ALL ON TABLE "public"."sales" TO "authenticated";
GRANT ALL ON TABLE "public"."sales" TO "service_role";

GRANT ALL ON SEQUENCE "public"."sales_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."sales_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."sales_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."subscription_tiers" TO "anon";
GRANT ALL ON TABLE "public"."subscription_tiers" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_tiers" TO "service_role";

GRANT ALL ON SEQUENCE "public"."subscription_tiers_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."subscription_tiers_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."subscription_tiers_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";

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
