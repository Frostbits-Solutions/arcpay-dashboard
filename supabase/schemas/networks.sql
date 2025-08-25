/*
# Networks Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the networks schema.

| Table      | anon                   | authenticated           | member                  | admin                   | owner                   |
|------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| networks     | SELECT (read-only)     | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      |

## Notes:
- All users (anon, authenticated, member, admin, owner) have read-only access to networks data
- No users can modify networks data through regular application interfaces
- The service_role has ALL permissions on the networks table (superuser)
- RLS (Row-Level Security) policies enforce these permissions with a universal read policy
- Networks data is typically managed through administrative processes or migrations
- This table serves as reference data for blockchain network information
*/

-------------------- NETWORKS --------------------
CREATE TABLE IF NOT EXISTS "public"."networks" (
    "id" text NOT NULL,
    "chain" text NOT NULL,
    "netid" text NOT NULL,
    "node_url" text NOT NULL,
    "node_port" integer NOT NULL,
    "node_token" text,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    "last_indexed_at" timestamp without time zone,
    "fee_proxy_app_id" bigint,
    CONSTRAINT "networks_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "public"."networks" OWNER TO "postgres";

-- RLS for networks
ALTER TABLE "public"."networks" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."networks" TO "anon";
GRANT SELECT ON TABLE "public"."networks" TO "authenticated";
GRANT ALL ON TABLE "public"."networks" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."networks" FOR SELECT USING (true);