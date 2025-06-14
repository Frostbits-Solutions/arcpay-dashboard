/*
# Transactions Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the transactions schema.

| Table                      | anon                   | authenticated           | member                  | admin                   | owner                   |
|----------------------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| transactions               | SELECT (read-only)     | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      |

## Function Permissions
| Function                              | anon                   | authenticated           | member                  | admin                   | owner                   |
|--------------------------------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| transactions                         | EXECUTE                | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |
| get_hourly_transactions_timeseries   | No access              | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |
| get_daily_sales_volume_timeseries    | No access              | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |

## Notes:
- "authenticated" refers to any logged-in user
- "member", "admin", and "owner" are roles assigned to authenticated users within specific accounts
- RLS (Row-Level Security) policies enforce these permissions at the row level
- Transactions are read-only for all user types (data is inserted by the service)
- Analysis functions are only available to authenticated users
- The service_role has ALL permissions on all tables (superuser)
*/

-------------------- TYPES --------------------
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

CREATE TYPE "public"."transactions_volume" AS (
    "time" timestamp without time zone,
    "volume" float8,
    "currency_id" text,
    "currency_ticker" text
);

ALTER TYPE "public"."transactions_volume" OWNER TO "postgres";


-------------------- TRANSACTIONS --------------------
CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "from_address" "text" NOT NULL,
    "chain_id" "text" NOT NULL,
    "app_id" bigint NOT NULL,
    "type" "public"."transaction_type" NOT NULL,
    "amount" double precision,
    "currency" "bigint" NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id", "chain_id", "app_id", "from_address", "created_at"),
    CONSTRAINT "transactions_currency_fkey" FOREIGN KEY ("currency", "chain_id") REFERENCES "public"."currencies"("id", "chain_id") ON DELETE CASCADE,
    CONSTRAINT "transactions_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."transactions" OWNER TO "postgres";

-- RLS for transactions
ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."transactions" TO "anon";
GRANT SELECT ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";
CREATE POLICY "Enable read access for all users" ON "public"."transactions" FOR SELECT USING (true);


-------------------- FUNCTIONS --------------------
CREATE OR REPLACE FUNCTION "public"."transactions"("public"."listings") RETURNS SETOF "public"."transactions"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$ select * from public.transactions where app_id = $1.app_id $_$;

ALTER FUNCTION "public"."transactions"("public"."listings") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" "uuid", "chain_id" "text") RETURNS SETOF "public"."transactions_count"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$
    select
    date_trunc('hour', t.created_at) AS time,
    count(t.id) AS count
    from "public"."transactions" t
    left join "public"."listings" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '168 hours' and t."chain_id" = $2
    group by time
    order by time asc
    $_$;

ALTER FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" "uuid", "chain_id" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" "uuid", "chain_id" "text") RETURNS SETOF "public"."transactions_volume"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$
    select
    date_trunc('day', t.created_at) AS time,
    sum(t.amount) / POWER(10,c.decimals) AS volume,
    c.id as currency_id,
    c.ticker as currency_ticker
    from "public"."transactions" t
    left join "public"."currencies" c on t.currency = c.id and t."chain_id" = c."chain_id"
    left join "public"."listings" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '30 days' and t.type = 'buy' and t."chain_id" = $2
    group by time, c.id, c.decimals, c.ticker
    order by time asc
    $_$;

ALTER FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" "uuid", "chain_id" "text") OWNER TO "postgres";

-- GRANT PERMISSION ON FUNCTIONS
GRANT EXECUTE ON FUNCTION "public"."transactions"("public"."listings") TO "anon", "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" "uuid", "chain_id" "text") TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" "uuid", "chain_id" "text") TO "authenticated", "service_role";