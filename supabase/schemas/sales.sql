/*
# Auctions Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the sales schema.

| Table     | anon                   | authenticated           | member                  | admin                   | owner                   |
|-----------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| sales     | SELECT, INSERT         | SELECT, INSERT          | ALL (full CRUD access)  | ALL (full CRUD access)  | ALL (full CRUD access)  |

## Notes:
- "anon" refers to unauthenticated users who can view and create sales
- "authenticated" refers to any logged-in user, which may not be associated with a specific account
- "member", "admin", and "owner" are roles assigned to authenticated users within specific accounts
- ALL permissions for members, admins, and owners are enforced through RLS policies that check if the user is a member of the account associated with the listing
- The service_role has ALL permissions on all tables (superuser)
- RLS (Row-Level Security) policies enforce these permissions based on user roles and account associations
*/

-------------------- SALES --------------------
CREATE TABLE IF NOT EXISTS "public"."sales" (
    "listing_id" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone,
    "price" numeric NOT NULL,
    CONSTRAINT "sales_pkey" PRIMARY KEY ("listing_id"),
    CONSTRAINT "sales_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."sales" OWNER TO "postgres";

-- RLS for sales
ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."sales" TO "anon";
GRANT ALL ON TABLE "public"."sales" TO "authenticated";
GRANT ALL ON TABLE "public"."sales" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."sales" FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON "public"."sales" FOR INSERT WITH CHECK (true);
CREATE POLICY "Members can manage sales" ON "public"."sales" FOR ALL TO "authenticated"
    USING (EXISTS ( 
        SELECT 1
        FROM "public"."listings"
        WHERE "listings"."id" = "sales"."listing_id"
        AND "private"."is_user_account_member"("auth"."email"(), "listings"."account_id")
    ));