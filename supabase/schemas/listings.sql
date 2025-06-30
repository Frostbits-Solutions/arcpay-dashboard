/*
# Listings Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the listings schema.

| Table           | anon                   | authenticated           | member                  | admin                   | owner                   |
|-----------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| listings        | SELECT, INSERT         | SELECT, INSERT          | ALL (full CRUD access)  | ALL (full CRUD access)  | ALL (full CRUD access)  |
| auctions        | SELECT, INSERT         | SELECT, INSERT          | ALL (full CRUD access)  | ALL (full CRUD access)  | ALL (full CRUD access)  |
| dutch_auctions  | SELECT, INSERT         | SELECT, INSERT          | ALL (full CRUD access)  | ALL (full CRUD access)  | ALL (full CRUD access)  |
| sales           | SELECT, INSERT         | SELECT, INSERT          | ALL (full CRUD access)  | ALL (full CRUD access)  | ALL (full CRUD access)  |

## Function Permissions
| Function                   | anon                   | authenticated           | member                  | admin                   | owner                   |
|----------------------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| get_listing_by_id          | EXECUTE                | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |
| listings                   | EXECUTE                | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |

## Notes:
- "anon" refers to unauthenticated users who can view and create listings
- "authenticated" refers to any logged-in user, which may not be associated with a specific account
- "member", "admin", and "owner" are roles assigned to authenticated users within specific accounts
- ALL permissions for members, admins, and owners are enforced through RLS policies that check if the user is a member of the account associated with the listing
- The service_role has ALL permissions on all tables and functions (superuser)
- RLS (Row-Level Security) policies enforce these permissions based on user roles and account associations
- All users can SELECT and INSERT into listings, but only account members can UPDATE and DELETE their own listings
*/

-------------------- TYPES --------------------
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

CREATE TYPE "public"."assets_types" AS ENUM (
    'arc72',
    'offchain',
    'asa'
);
ALTER TYPE "public"."assets_types" OWNER TO "postgres";

CREATE TYPE "public"."composite_listing" AS (
	"id" "uuid",
	"created_at" timestamp without time zone,
	"updated_at" timestamp without time zone,
	"status" "public"."listings_statuses",
	"chain_id" "text",
    "contract_version" text,
	"creator_address" "text",
	"name" "text",
	"type" "public"."listings_types",
	"app_id" bigint,
	"currency" bigint,
	"currency_name" "text",
	"currency_ticker" "text",
	"currency_icon" "text",
	"currency_type" "public"."currency_type",
	"currency_decimals" bigint,
	"asset_id" "text",
	"asset_thumbnail" "text",
	"asset_type" "public"."assets_types",
	"asset_qty" double precision,
	"metadata" "jsonb",
	"sale_price" double precision,
	"auction_start_price" double precision,
	"auction_increment" double precision,
	"auction_duration" integer,
	"dutch_min_price" double precision,
	"dutch_max_price" double precision,
	"dutch_duration" integer
);

ALTER TYPE "public"."composite_listing" OWNER TO "postgres";
-------------------- LISTINGS --------------------
CREATE TABLE IF NOT EXISTS "public"."listings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "account_id" "uuid" NOT NULL,
    "status" "public"."listings_statuses" NOT NULL,
    "creator_address" "text" NOT NULL,
    "name" "text" NOT NULL,
    "currency" bigint NOT NULL,
    "type" "public"."listings_types" NOT NULL,
    "app_id" bigint NOT NULL,
    "asset_id" bigint NOT NULL,
    "asset_thumbnail" "text",
    "asset_type" "public"."assets_types" NOT NULL,
    "asset_qty" double precision DEFAULT '1'::double precision NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "chain_id" "text" NOT NULL,
    "contract_version" text NOT NULL,
    CONSTRAINT "listings_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "listings_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE,
    CONSTRAINT "listings_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id"),
    CONSTRAINT "listings_currency_chain_id_fkey" FOREIGN KEY ("currency", "chain_id") REFERENCES "public"."currencies"("id", "chain_id") ON DELETE CASCADE,
    CONSTRAINT "listings_contract_version_chain_id_fkey" FOREIGN KEY ("contract_version", "chain_id") REFERENCES "public"."contracts_versions"("version", "chain_id") ON DELETE RESTRICT
);

ALTER TABLE "public"."listings" OWNER TO "postgres";
CREATE INDEX IF NOT EXISTS "idx_listings" ON "public"."listings" ("account_id", "status", "chain_id", "currency", "type", "asset_type", "asset_id", "creator_address");

-- RLS Policies for listings
ALTER TABLE "public"."listings" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."listings" TO "anon";
GRANT ALL ON TABLE "public"."listings" TO "authenticated";
GRANT ALL ON TABLE "public"."listings" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."listings" FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON "public"."listings" FOR INSERT WITH CHECK (true);
CREATE POLICY "Members can update listings" ON "public"."listings" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_member"((select "auth"."email"()), "account_id"));
CREATE POLICY "Members can delete listings" ON "public"."listings" FOR DELETE TO "authenticated" USING ("private"."is_user_account_member"((select "auth"."email"()), "account_id"));

-------------------- AUCTIONS --------------------
CREATE TABLE IF NOT EXISTS "public"."auctions" (
    "listing_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "start_price" double precision NOT NULL,
    "increment" double precision NOT NULL,
    "duration" integer NOT NULL,
    CONSTRAINT "auctions_pkey" PRIMARY KEY ("listing_id"),
    CONSTRAINT "auctions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."auctions" OWNER TO "postgres";

-- RLS for auctions
ALTER TABLE "public"."auctions" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."auctions" TO "anon";
GRANT ALL ON TABLE "public"."auctions" TO "authenticated";
GRANT ALL ON TABLE "public"."auctions" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."auctions" FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON "public"."auctions" FOR INSERT WITH CHECK (true);
CREATE POLICY "Members can update auctions" ON "public"."auctions" FOR UPDATE TO "authenticated"
    USING ("public"."can_user_manage_listing"("listing_id"));
CREATE POLICY "Members can delete auctions" ON "public"."auctions" FOR DELETE TO "authenticated"
    USING ("public"."can_user_manage_listing"("listing_id"));

-------------------- DUTCH_AUCTION --------------------
CREATE TABLE IF NOT EXISTS "public"."dutch_auctions" (
    "listing_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "min_price" double precision NOT NULL,
    "max_price" double precision,
    "duration" integer NOT NULL,
    CONSTRAINT "dutch_auctions_pkey" PRIMARY KEY ("listing_id"),
    CONSTRAINT "dutch_auctions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."dutch_auctions" OWNER TO "postgres";

-- RLS for dutch auctions
ALTER TABLE "public"."dutch_auctions" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."dutch_auctions" TO "anon";
GRANT ALL ON TABLE "public"."dutch_auctions" TO "authenticated";
GRANT ALL ON TABLE "public"."dutch_auctions" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."dutch_auctions" FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON "public"."dutch_auctions" FOR INSERT WITH CHECK (true);
CREATE POLICY "Members can update dutch auctions" ON "public"."dutch_auctions" FOR UPDATE TO "authenticated"
    USING ("public"."can_user_manage_listing"("listing_id"));
CREATE POLICY "Members can delete dutch auctions" ON "public"."dutch_auctions" FOR DELETE TO "authenticated"
    USING ("public"."can_user_manage_listing"("listing_id"));

-------------------- SALES --------------------
CREATE TABLE IF NOT EXISTS "public"."sales" (
    "listing_id" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone,
    "price" numeric NOT NULL,
    CONSTRAINT "sales_pkey" PRIMARY KEY ("listing_id"),
    CONSTRAINT "sales_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."sales" OWNER TO "postgres";

-- RLS for sales
ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."sales" TO "anon";
GRANT ALL ON TABLE "public"."sales" TO "authenticated";
GRANT ALL ON TABLE "public"."sales" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."sales" FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON "public"."sales" FOR INSERT WITH CHECK (true);
CREATE POLICY "Members can update sales" ON "public"."sales" FOR UPDATE TO "authenticated"
    USING ("public"."can_user_manage_listing"("listing_id"));
CREATE POLICY "Members can delete sales" ON "public"."sales" FOR DELETE TO "authenticated"
    USING ("public"."can_user_manage_listing"("listing_id"));


-------------------- FUNCTIONS --------------------
CREATE OR REPLACE FUNCTION "private"."can_user_manage_listing"("listing_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET search_path = ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."listings"
        WHERE "listings"."id" = "can_user_manage_listing"."listing_id"
        AND "private"."is_user_account_member"((SELECT "auth"."email"()), "listings"."account_id")
    )
$$;

ALTER FUNCTION "public"."can_user_manage_listing"("listing_id" "uuid") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "public"."can_user_manage_listing"("uuid") TO "service_role";

CREATE OR REPLACE FUNCTION "public"."get_listing_by_id"("listing_id" "uuid") RETURNS "public"."composite_listing"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
    AS $$select
        l.id,
        l.created_at,
        l.updated_at,
        l.status,
        l.chain_id,
        l.contract_version,
        l.creator_address,
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
        l.metadata,
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
        left join public.currencies c on (c.id = l.currency and c.chain_id = l.chain_id)
    where l.id = get_listing_by_id.listing_id$$;

ALTER FUNCTION "public"."get_listing_by_id"("listing_id" "uuid") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "public"."get_listing_by_id"("uuid") TO "anon", "authenticated", "service_role";