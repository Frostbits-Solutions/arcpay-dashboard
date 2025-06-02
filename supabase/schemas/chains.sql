/*
# Chains Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the chains schema.

| Table      | anon                   | authenticated           | member                  | admin                   | owner                   |
|------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| chains     | SELECT (read-only)     | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      | SELECT (read-only)      |

## Notes:
- All users (anon, authenticated, member, admin, owner) have read-only access to chains data
- No users can modify chains data through regular application interfaces
- The service_role has ALL permissions on the chains table (superuser)
- RLS (Row-Level Security) policies enforce these permissions with a universal read policy
- Chains data is typically managed through administrative processes or migrations
- This table serves as reference data for blockchain network information
*/

-------------------- CHAINS --------------------
CREATE TABLE IF NOT EXISTS "public"."chains" (
    "id" text NOT NULL,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    "last_indexed_at" timestamp without time zone,
    "fee_proxy_app_id" bigint,
    CONSTRAINT "chains_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "public"."chains" OWNER TO "postgres";

-- RLS for chains
ALTER TABLE "public"."accounts" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."chains" TO "anon";
GRANT SELECT ON TABLE "public"."chains" TO "authenticated";
GRANT ALL ON TABLE "public"."chains" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."chains" FOR SELECT USING (true);