/*
# Apps Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the apps schema.

| Table           | anon                   | authenticated           | member                  | admin                   | owner                   |
|-----------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| apps            | SELECT, INSERT         | SELECT, INSERT          | ALL (full CRUD access)  | ALL (full CRUD access)  | ALL (full CRUD access)  |

## Notes:
- "anon" refers to unauthenticated users who can view and create apps
- "authenticated" refers to any logged-in user, which may not be associated with a specific account
- "member", "admin", and "owner" are roles assigned to authenticated users within specific accounts
- ALL permissions for members, admins, and owners are enforced through RLS policies that check if the user is a member of the account associated with the app
- The service_role has ALL permissions on all tables and functions (superuser)
- RLS (Row-Level Security) policies enforce these permissions based on user roles and account associations
- All users can SELECT and INSERT into apps, but only account members can UPDATE and DELETE their own apps
*/

-------------------- TYPES --------------------
CREATE TYPE "public"."apps_statuses" AS ENUM (
    'pending',
    'active',
    'closed',
    'cancelled'
);
ALTER TYPE "public"."apps_statuses" OWNER TO "postgres";

CREATE TYPE "public"."apps_types" AS ENUM (
    'swap',
    'payment'
);
ALTER TYPE "public"."apps_types" OWNER TO "postgres";

-------------------- APPS --------------------
CREATE TABLE IF NOT EXISTS "public"."apps" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "account_id" "uuid" NOT NULL,
    "status" "public"."apps_statuses" NOT NULL,
    "creator_address" "text" NOT NULL,
    "app_id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "type" "public"."apps_types" NOT NULL,
    "network_id" "text" NOT NULL,
    "contract_tag" "public"."contract_tag_enum" NOT NULL,
    "contract_version" text NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT "apps_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "apps_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE,
    CONSTRAINT "apps_network_id_fkey" FOREIGN KEY ("network_id") REFERENCES "public"."networks"("id"),
    CONSTRAINT "apps_contract_fkey" FOREIGN KEY ("contract_tag", "contract_version", "network_id") REFERENCES "public"."contracts"("tag", "version", "network_id") ON DELETE RESTRICT
);

ALTER TABLE "public"."apps" OWNER TO "postgres";
CREATE INDEX IF NOT EXISTS "idx_apps" ON "public"."apps" ("account_id", "status", "network_id", "type", "app_id", "creator_address");

-- RLS Policies for apps
ALTER TABLE "public"."apps" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."apps" TO "anon";
GRANT ALL ON TABLE "public"."apps" TO "authenticated";
GRANT ALL ON TABLE "public"."apps" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."apps" FOR SELECT USING ("private"."authorize_request"("account_id"));
CREATE POLICY "Enable insert for all users" ON "public"."apps" FOR INSERT WITH CHECK ("private"."authorize_request"("account_id"));
CREATE POLICY "Members can update apps" ON "public"."apps" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_member"((select "auth"."email"()), "account_id"));
CREATE POLICY "Members can delete apps" ON "public"."apps" FOR DELETE TO "authenticated" USING ("private"."is_user_account_member"((select "auth"."email"()), "account_id"));

-------------------- RLS HELPER FUNCTION --------------------
CREATE OR REPLACE FUNCTION "private"."can_user_manage_app"("app_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET search_path = ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."apps"
        WHERE "apps"."id" = "can_user_manage_app"."app_id"
        AND "private"."is_user_account_member"((SELECT "auth"."email"()), "apps"."account_id")
    )
$$;

ALTER FUNCTION "private"."can_user_manage_app"("app_id" "uuid") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "private"."can_user_manage_app"("uuid") TO "service_role";

CREATE OR REPLACE FUNCTION "private"."authorize_app_request"("app_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET search_path = ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."apps"
        WHERE "apps"."id" = "authorize_app_request"."app_id"
        AND "private"."authorize_request"("apps"."account_id")
    )
$$;
ALTER FUNCTION "private"."authorize_app_request"("app_id" "uuid") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "private"."authorize_app_request"("uuid") TO "service_role";