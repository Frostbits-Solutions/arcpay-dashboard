ALTER TYPE "public"."chains" RENAME TO "chains_enum";

-- Create chains table
CREATE TABLE IF NOT EXISTS "public"."chains" (
    "id" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    "last_indexed_at" timestamp without time zone,
    "fee_proxy_app_id" int8,
    CONSTRAINT "chains_pkey" PRIMARY KEY ("id")
);

INSERT INTO "public"."chains" ("id", "created_at")
SELECT DISTINCT unnest(enum_range(NULL::"public"."chains_enum"))::text, NOW()
ON CONFLICT (id) DO NOTHING;

-- Add new columns to existing tables and set up foreign key constraints
ALTER TABLE "public"."listings"
    ADD COLUMN "chain_id" text;

UPDATE "public"."listings"
SET "chain_id" = "chain"::text;

ALTER TABLE "public"."listings"
    ALTER COLUMN "chain_id" SET NOT NULL,
    ADD CONSTRAINT "listings_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id"),
    DROP COLUMN "chain";

ALTER TABLE "public"."transactions"
    ADD COLUMN "chain_id" text;

UPDATE "public"."transactions"
SET "chain_id" = "chain"::text;

ALTER TABLE "public"."transactions"
    ALTER COLUMN "chain_id" SET NOT NULL,
    ADD CONSTRAINT "transactions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id"),
    DROP COLUMN "chain";

ALTER TABLE "public"."currencies"
    ADD COLUMN "chain_id" text;

UPDATE "public"."currencies"
SET "chain_id" = "chain"::text;

ALTER TABLE "public"."currencies"
    RENAME COLUMN "visible" TO "is_public";

ALTER TABLE "public"."currencies"
    ALTER COLUMN "chain_id" SET NOT NULL,
    ADD CONSTRAINT "currencies_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id");

ALTER TABLE "public"."accounts_currencies"
    ADD COLUMN "chain_id" text;

UPDATE "public"."accounts_currencies"
SET "chain_id" = "chain"::text;

ALTER TABLE "public"."accounts_currencies"
    ALTER COLUMN "chain_id" SET NOT NULL,
    DROP COLUMN "chain";

ALTER TABLE "public"."currencies"
    DROP COLUMN "chain",
    ADD CONSTRAINT "currencies_pkey" PRIMARY KEY ("id", "chain_id");

ALTER TABLE "public"."accounts_currencies"
    ADD CONSTRAINT "accounts_currencies_pkey" PRIMARY KEY ("account_id", "currency", "chain_id"),
    ADD CONSTRAINT "accounts_currencies_chain_id_fkey" FOREIGN KEY ("currency", "chain_id") REFERENCES "public"."currencies"("id", "chain_id");

-- Update indexes
DROP INDEX IF EXISTS "idx_listings";
CREATE INDEX "idx_listings" ON "public"."listings" ("account_id", "status", "chain_id", "currency", "type", "asset_type");

DROP INDEX IF EXISTS "idx_transactions";
CREATE INDEX "idx_transactions" ON "public"."transactions" ("chain_id", "app_id");

-- Set table ownership
ALTER TABLE "public"."chains" OWNER TO "postgres";

-- Grant permissions (read-only for anon, full access for authenticated and service_role)
GRANT SELECT ON TABLE "public"."chains" TO "anon";
GRANT ALL ON TABLE "public"."chains" TO "authenticated";
GRANT ALL ON TABLE "public"."chains" TO "service_role";