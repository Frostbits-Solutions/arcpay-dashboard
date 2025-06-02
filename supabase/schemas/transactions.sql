-- supabase/schemas/transactions.sql

-- Initial set-up notes related to this table (from migrations):
-- 1. Realtime should be activated on this table.
-- 2. This table should be added to the supabase_realtime publication.
-- 3. TimescaleDB extension should be enabled and this table converted to a hypertable on '''created_at'''.

CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "id" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "account_id" "uuid" NOT NULL,
    "app_id" bigint,
    "type" "public"."transaction_type" NOT NULL,
    "note" "text",
    "data" "jsonb",
    "chain_id" "text" NOT NULL, -- This column was added and '''chain''' was dropped in migration 20250413022634
    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "transactions_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE,
    CONSTRAINT "transactions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE -- Added in migration 20250413022634
);

-- Set ownership
ALTER TABLE "public"."transactions" OWNER TO "postgres";

-- Enable Row Level Security
ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;

-- Define RLS Policies (as per 20240915211603_inital_schema.sql)
CREATE POLICY "Enable read access for all users" ON "public"."transactions"
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."transactions"
    FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable update for users based on user_id" ON "public"."transactions"
    FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable delete for users based on user_id" ON "public"."transactions"
    FOR DELETE TO "authenticated" USING (true);

-- Grant permissions (as per 20240915211603_inital_schema.sql)
GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";

-- Indexes (as per migration 20250413022634_added_chain_table.sql)
-- The original index on (chain, app_id) was dropped and replaced by this one.
CREATE INDEX IF NOT EXISTS "idx_transactions" ON "public"."transactions" ("chain_id", "app_id");
