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
    "asset_id" text,
    "asset_ticker" text
);

ALTER TYPE "public"."transactions_volume" OWNER TO "postgres";


-------------------- TRANSACTIONS --------------------
CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "from_address" "text" NOT NULL,
    "network_id" "text" NOT NULL,
    "app_id" bigint NOT NULL,
    "type" "public"."transaction_type" NOT NULL,
    "quoted_asset_id" bigint NOT NULL,
    "quoted_amount" double precision,
    "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id", "network_id", "app_id", "from_address", "created_at"),
    CONSTRAINT "transactions_asset_fkey" FOREIGN KEY ("quoted_asset_id", "network_id") REFERENCES "public"."assets"("id", "network_id") ON DELETE CASCADE,
    CONSTRAINT "transactions_network_id_fkey" FOREIGN KEY ("network_id") REFERENCES "public"."networks"("id") ON DELETE CASCADE
) PARTITION BY RANGE (created_at);
ALTER TABLE "public"."transactions" OWNER TO "postgres";

-- RLS for transactions
ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."transactions" TO "anon";
GRANT SELECT ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";
CREATE POLICY "Enable read access for all users" ON "public"."transactions" FOR SELECT USING (true);


-------------------- FUNCTIONS --------------------
CREATE OR REPLACE FUNCTION "public"."transactions"("public"."apps") RETURNS SETOF "public"."transactions"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$ select * from public.transactions where app_id = $1.app_id $_$;

ALTER FUNCTION "public"."transactions"("public"."apps") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."apps"("public"."transactions") RETURNS SETOF "public"."apps"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$ select * from public.apps where app_id = $1.app_id $_$;

ALTER FUNCTION "public"."apps"("public"."transactions") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "public"."apps"("public"."transactions") TO "anon", "authenticated", "service_role";

CREATE OR REPLACE FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" "uuid", "network_id" "text") RETURNS SETOF "public"."transactions_count"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$
    select
    date_trunc('hour', t.created_at) AS time,
    count(t.id) AS count
    from "public"."transactions" t
    left join "public"."apps" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '168 hours' and t."network_id" = $2
    group by time
    order by time asc
    $_$;

ALTER FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" "uuid", "network_id" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" "uuid", "network_id" "text") RETURNS SETOF "public"."transactions_volume"
    LANGUAGE "sql" STABLE
    set search_path = ''
    AS $_$
    select
    date_trunc('day', t.created_at) AS time,
    sum(t.quoted_amount) / POWER(10,c.decimals) AS volume,
    c.id as asset_id,
    c.ticker as asset_ticker
    from "public"."transactions" t
    left join "public"."assets" c on t.quoted_asset_id = c.id and t."network_id" = c."network_id"
    left join "public"."apps" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '30 days' and t.type = 'buy' and t."network_id" = $2
    group by time, c.id, c.decimals, c.ticker
    order by time asc
    $_$;

ALTER FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" "uuid", "network_id" "text") OWNER TO "postgres";

-- Create a function to automatically create new daily partitions
CREATE OR REPLACE FUNCTION "private"."create_daily_transactions_partition"()
RETURNS void
LANGUAGE plpgsql
set search_path = ''
AS $$
DECLARE
    start_date date;
    end_date date;
    partition_name text;
BEGIN
    -- Create partition for tomorrow
    start_date := CURRENT_DATE + INTERVAL '1 day';
    end_date := start_date + INTERVAL '1 day';
    partition_name := 'transactions_' || to_char(start_date, 'YYYY_MM_DD');
    
    -- Check if partition already exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = partition_name 
        AND table_schema = 'parts'
    ) THEN
        EXECUTE format('CREATE TABLE "parts"."%I" PARTITION OF public.transactions FOR VALUES FROM (%L) TO (%L)',
                      partition_name, start_date, end_date);
        EXECUTE format('ALTER TABLE "parts"."%I" ENABLE ROW LEVEL SECURITY', partition_name);
        EXECUTE format('GRANT SELECT ON TABLE "parts"."%I" TO "anon"', partition_name);
        EXECUTE format('GRANT SELECT ON TABLE "parts"."%I" TO "authenticated"', partition_name);
        EXECUTE format('GRANT ALL ON TABLE "parts"."%I" TO "service_role"', partition_name);
        EXECUTE format('CREATE POLICY "Enable read access for all users" ON "parts"."%I" FOR SELECT USING (true)', partition_name);
    END IF;
END;
$$;

-- GRANT PERMISSION ON FUNCTIONS
GRANT EXECUTE ON FUNCTION "public"."transactions"("public"."apps") TO "anon", "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_hourly_transactions_timeseries"("account_id" "uuid", "network_id" "text") TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_daily_sales_volume_timeseries"("account_id" "uuid", "network_id" "text") TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "private"."create_daily_transactions_partition"() TO "service_role";