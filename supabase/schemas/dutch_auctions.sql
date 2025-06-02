/*
# Dutch Auctions Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the dutch_auctions schema.

| Table           | anon                   | authenticated           | member                  | admin                   | owner                   |
|-----------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| dutch_auctions  | SELECT, INSERT         | SELECT, INSERT          | ALL (full CRUD access)  | ALL (full CRUD access)  | ALL (full CRUD access)  |

## Notes:
- "anon" refers to unauthenticated users who can view and create dutch_auctions
- "authenticated" refers to any logged-in user, which may not be associated with a specific account
- "member", "admin", and "owner" are roles assigned to authenticated users within specific accounts
- ALL permissions for members, admins, and owners are enforced through RLS policies that check if the user is a member of the account associated with the listing
- The service_role has ALL permissions on all tables (superuser)
- RLS (Row-Level Security) policies enforce these permissions based on user roles and account associations
*/

-------------------- DUTCH_AUCTION --------------------
CREATE TABLE IF NOT EXISTS "public"."dutch_auctions" (
    "listing_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "min_price" double precision NOT NULL,
    "max_price" double precision,
    "duration" integer NOT NULL,
    CONSTRAINT "dutch_auctions_pkey" PRIMARY KEY ("listing_id"),
    CONSTRAINT "dutch_auctions_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."dutch_auctions" OWNER TO "postgres";

-- RLS for dutch auctions
ALTER TABLE "public"."dutch_auctions" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."dutch_auctions" TO "anon";
GRANT ALL ON TABLE "public"."dutch_auctions" TO "authenticated";
GRANT ALL ON TABLE "public"."dutch_auctions" TO "service_role";

CREATE POLICY "Enable read access for all users" ON "public"."dutch_auctions" FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON "public"."dutch_auctions" FOR INSERT WITH CHECK (true);
CREATE POLICY "Members can manage dutch auctions" ON "public"."dutch_auctions" FOR ALL TO "authenticated"
    USING (EXISTS ( 
        SELECT 1
        FROM "public"."listings"
        WHERE "listings"."id" = "dutch_auctions"."listing_id"
        AND "private"."is_user_account_member"("auth"."email"(), "listings"."account_id")
    ));
