-- Supabase Schema: sales.sql

CREATE TABLE IF NOT EXISTS "public"."sales" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "listing_id" "uuid" NOT NULL,
    "price" numeric NOT NULL,
    "buyer_address" "text",
    "seller_address" "text",
    "transaction_id" "text",
    "is_settled" boolean DEFAULT false NOT NULL,
    "currency" "text" NOT NULL,
    "currency_name" "text",
    "currency_ticker" "text",
    "currency_icon" "text",
    "currency_type" "public"."currency_type",
    "currency_decimals" bigint,
    CONSTRAINT "sales_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "sales_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE,
    CONSTRAINT "sales_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("id") ON DELETE SET NULL
);

ALTER TABLE "public"."sales" OWNER TO "postgres";

-- Row Level Security
ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE "public"."sales" TO "anon";
GRANT ALL ON TABLE "public"."sales" TO "authenticated";
GRANT ALL ON TABLE "public"."sales" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."sales" FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON "public"."sales" FOR INSERT TO "authenticated" WITH CHECK (true);
CREATE POLICY "Enable update for users based on user_id" ON "public"."sales" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete for users based on user_id" ON "public"."sales" FOR DELETE TO "authenticated" USING (true);

-- Indexes
CREATE INDEX "idx_sales_listing_id" ON "public"."sales" USING "btree" ("listing_id");
CREATE INDEX "idx_sales_transaction_id" ON "public"."sales" USING "btree" ("transaction_id");
CREATE INDEX "idx_sales_buyer_address" ON "public"."sales" USING "btree" ("buyer_address");
CREATE INDEX "idx_sales_seller_address" ON "public"."sales" USING "btree" ("seller_address");
