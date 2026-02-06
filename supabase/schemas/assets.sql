/*
# Assets Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the assets schema.

| Table      | anon                   | authenticated           | member                  | admin                   | owner                   |
|------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| assets     | SELECT (read-only)     | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      |

## Notes:
- All users (anon, authenticated, member, admin, owner) have read-only access to assets
- No users can modify asset data through regular application interfaces
- The service_role has ALL permissions on all tables (superuser)
- RLS (Row-Level Security) policies enforce these permissions with a universal read policy
- Asset data is typically managed through administrative processes or migrations
*/

-------------------- TYPES --------------------
CREATE TYPE "public"."assets_types" AS ENUM (
    'asa'
);
ALTER TYPE "public"."assets_types" OWNER TO "postgres";

-------------------- ASSETS --------------------
CREATE TABLE IF NOT EXISTS "public"."assets" (
    "id" bigint NOT NULL,
    "network_id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text" NOT NULL,
    "ticker" "text" NOT NULL,
    "icon" "text",
    "type" "public"."assets_types" NOT NULL,
    "decimals" bigint NOT NULL,
    "is_public" boolean DEFAULT true NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT "assets_pkey" PRIMARY KEY ("id", "network_id"),
    CONSTRAINT "assets_network_id_fkey" FOREIGN KEY ("network_id") REFERENCES "public"."networks"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."assets" OWNER TO "postgres";

-- RLS Policies
ALTER TABLE "public"."assets" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."assets" TO "anon";
GRANT SELECT ON TABLE "public"."assets" TO "authenticated";
GRANT ALL ON TABLE "public"."assets" TO "service_role";
CREATE POLICY "Enable read access for all users" ON "public"."assets" FOR SELECT USING (true);