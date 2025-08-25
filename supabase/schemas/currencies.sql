/*
# Currencies Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the currencies schema.

| Table      | anon                   | authenticated           | member                  | admin                   | owner                   |
|------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| currencies | SELECT (read-only)     | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      |

## Notes:
- All users (anon, authenticated, member, admin, owner) have read-only access to currencies
- No users can modify currency data through regular application interfaces
- The service_role has ALL permissions on all tables (superuser)
- RLS (Row-Level Security) policies enforce these permissions with a universal read policy
- Currency data is typically managed through administrative processes or migrations
*/

-------------------- TYPES --------------------
CREATE TYPE "public"."currency_type" AS ENUM (
    'algo',
    'asa',
    'voi',
    'arc200'
);
ALTER TYPE "public"."currency_type" OWNER TO "postgres";

-------------------- CURRENCIES --------------------
CREATE TABLE IF NOT EXISTS "public"."currencies" (
    "id" bigint NOT NULL,
    "network_id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text" NOT NULL,
    "ticker" "text" NOT NULL,
    "icon" "text",
    "type" "public"."currency_type" NOT NULL,
    "decimals" bigint NOT NULL,
    "is_public" boolean DEFAULT true NOT NULL,
    CONSTRAINT "currencies_pkey" PRIMARY KEY ("id", "network_id"),
    CONSTRAINT "currencies_network_id_fkey" FOREIGN KEY ("network_id") REFERENCES "public"."networks"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."currencies" OWNER TO "postgres";

-- RLS Policies
ALTER TABLE "public"."currencies" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."currencies" TO "anon";
GRANT SELECT ON TABLE "public"."currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."currencies" TO "service_role";
CREATE POLICY "Enable read access for all users" ON "public"."currencies" FOR SELECT USING (true);