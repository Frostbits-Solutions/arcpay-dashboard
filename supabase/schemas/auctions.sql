-- Supabase Schema: auctions.sql

CREATE TABLE IF NOT EXISTS "public"."auctions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "listing_id" "uuid" NOT NULL,
    "duration" integer NOT NULL,
    "reserve_price" numeric,
    "start_price" numeric,
    "buy_now_price" numeric,
    "highest_bid" numeric,
    "highest_bidder" "text",
    "ended_at" timestamp without time zone,
    "is_settled" boolean DEFAULT false NOT NULL,
    CONSTRAINT "auctions_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "auctions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."auctions" OWNER TO "postgres";

-- Row Level Security
ALTER TABLE "public"."auctions" ENABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE "public"."auctions" TO "anon";
GRANT ALL ON TABLE "public"."auctions" TO "authenticated";
GRANT ALL ON TABLE "public"."auctions" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."auctions" FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON "public"."auctions" FOR INSERT TO "authenticated" WITH CHECK (true);
CREATE POLICY "Enable update for users based on user_id" ON "public"."auctions" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete for users based on user_id" ON "public"."auctions" FOR DELETE TO "authenticated" USING (true);

-- Indexes
CREATE INDEX "idx_auctions_listing_id" ON "public"."auctions" USING "btree" ("listing_id");

