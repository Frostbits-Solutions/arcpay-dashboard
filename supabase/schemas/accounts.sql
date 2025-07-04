/*
# Accounts Schema Permissions Table

This table provides a comprehensive overview of permissions for different user roles across all tables in the accounts schema.

| Table                      | anon                   | authenticated             | member                  | admin                         | owner                          |
|----------------------------|------------------------|---------------------------|-------------------------|-------------------------------|--------------------------------|
| accounts                   | No access              | No direct access          | SELECT only             | SELECT, UPDATE                | ALL (full CRUD access)         |
| accounts_addresses         | No access              | No direct access          | SELECT only             | ALL (full CRUD access)        | ALL (full CRUD access)         |
| accounts_users_association | No access              | No direct access          | SELECT only             | ALL (full CRUD access)        | ALL (full CRUD access)         |
| accounts_chains_parameters | SELECT (read-only)     | SELECT (read-only)        | SELECT only             | ALL (full CRUD access)        | ALL (full CRUD access)         |
| accounts_currencies        | SELECT (read-only)     | SELECT (read-only)        | SELECT only             | ALL (full CRUD access)        | ALL (full CRUD access)         |
| accounts_secrets           | No access              | No direct access          | No access               | ALL (full CRUD access)        | ALL (full CRUD access)         |

## Function Permissions
| Function                   | anon                   | authenticated           | member                  | admin                   | owner                   |
|----------------------------|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| is_user_account_owner      | No access              | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |
| is_user_account_admin      | No access              | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |
| is_user_account_member     | No access              | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |
| get_user_accounts          | No access              | EXECUTE                 | EXECUTE                 | EXECUTE                 | EXECUTE                 |
| create_account             | No access              | EXECUTE                 | No access               | No access               | No access               |

## Notes:
- "authenticated" refers to any logged-in user, which may not be associated with a specific account
- "member", "admin", and "owner" are roles assigned to authenticated users within specific accounts
- RLS (Row-Level Security) policies enforce these permissions at the row level
- Users with admin role can manage most account settings but cannot delete the account
- Only owners can delete accounts
- The service_role has ALL permissions on all tables (superuser)
*/

-------------------- TYPES --------------------
CREATE TYPE "public"."accounts_users_roles" AS ENUM (
    'owner',
    'admin',
    'member'
);
ALTER TYPE "public"."accounts_users_roles" OWNER TO "postgres";

-------------------- ACCOUNTS --------------------
CREATE TABLE IF NOT EXISTS "public"."accounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" UNIQUE NOT NULL,
    "authenticate_clients" boolean DEFAULT true NOT NULL,
    "subscription_id" bigint DEFAULT '1'::bigint NOT NULL,
    "subscription_expiration_date" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "accounts_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "public"."subscription_tiers"("id")
);
ALTER TABLE "public"."accounts" OWNER TO "postgres";

-- RLS for accounts
ALTER TABLE "public"."accounts" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts" TO "service_role";

-------------------- ACCOUNTS ADDRESSES --------------------
CREATE TABLE IF NOT EXISTS "public"."accounts_addresses" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "address" "text" NOT NULL,
    "name" "text",
    "account_id" "uuid" NOT NULL,
    CONSTRAINT "accounts_addresses_pkey" PRIMARY KEY ("address", "account_id"),
    CONSTRAINT "accounts_addresses_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."accounts_addresses" OWNER TO "postgres";

-- RLS for accounts_addresses
ALTER TABLE "public"."accounts_addresses" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."accounts_addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_addresses" TO "service_role";


-------------------- ACCOUNTS USERS --------------------
CREATE TABLE IF NOT EXISTS "public"."accounts_users_association" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,  
    "account_id" "uuid" NOT NULL,
    "user_email" "text" NOT NULL,
    "role" "public"."accounts_users_roles" NOT NULL,
    CONSTRAINT "accounts_users_association_pkey" PRIMARY KEY ("account_id", "user_email"),
    CONSTRAINT "accounts_users_association_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."accounts_users_association" OWNER TO "postgres";

-- RLS for accounts_users_association
ALTER TABLE "public"."accounts_users_association" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."accounts_users_association" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_users_association" TO "service_role";

-------------------- ACCOUNTS CHAINS PARAMETERS --------------------
CREATE TABLE IF NOT EXISTS "public"."accounts_chains_parameters" (
    "account_id" "uuid" NOT NULL,
    "chain_id" text NOT NULL,
    "enable_secondary" boolean NOT NULL DEFAULT false,
    "secondary_percentage_fee" float NOT NULL DEFAULT 0,
    "secondary_fee_address" text,
    "created_at" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "accounts_chains_parameters_pkey" PRIMARY KEY ("account_id", "chain_id"),
    CONSTRAINT "accounts_chains_parameters_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE,
    CONSTRAINT "accounts_chains_parameters_chain_id_fkey" FOREIGN KEY ("chain_id") REFERENCES "public"."chains"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."accounts_chains_parameters" OWNER TO "postgres";

-- RLS for accounts_chains_parameters
ALTER TABLE "public"."accounts_chains_parameters" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."accounts_chains_parameters" TO "anon";
GRANT ALL ON TABLE "public"."accounts_chains_parameters" TO "authenticated"; 
GRANT ALL ON TABLE "public"."accounts_chains_parameters" TO "service_role";

-------------------- ACCOUNTS CURRENCIES --------------------
CREATE TABLE IF NOT EXISTS "public"."accounts_currencies" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "account_id" "uuid" NOT NULL,
    "currency" bigint NOT NULL,
    "chain_id" "text" NOT NULL,
    CONSTRAINT "accounts_currencies_pkey" PRIMARY KEY ("account_id", "currency", "chain_id"),
    CONSTRAINT "accounts_currencies_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE,
    CONSTRAINT "accounts_currencies_currency_fkey" FOREIGN KEY ("currency", "chain_id") REFERENCES "public"."currencies"("id", "chain_id") ON DELETE CASCADE
);
ALTER TABLE "public"."accounts_currencies" OWNER TO "postgres";

-- RLS for accounts_currencies
ALTER TABLE "public"."accounts_currencies" ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE "public"."accounts_currencies" TO "anon";
GRANT ALL ON TABLE "public"."accounts_currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_currencies" TO "service_role";

-------------------- ACCOUNTS SECRETS --------------------
CREATE TABLE IF NOT EXISTS "public"."accounts_secrets" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "account_id" "uuid" NOT NULL,
    "secret" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    CONSTRAINT "accounts_secrets_pkey" PRIMARY KEY ("account_id", "secret"),
    CONSTRAINT "accounts_secrets_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE
);
ALTER TABLE "public"."accounts_secrets" OWNER TO "postgres";

-- RLS for accounts_secrets
ALTER TABLE "public"."accounts_secrets" ENABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE "public"."accounts_secrets" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts_secrets" TO "service_role";

-------------------- FUNCTIONS --------------------
CREATE OR REPLACE FUNCTION "public"."create_account"("account_name" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    set search_path = ''
    AS $$
DECLARE
    new_account_id uuid;
BEGIN
    INSERT INTO public.accounts (name)
    VALUES (account_name)
    RETURNING id INTO new_account_id;
    
    -- Add the creator as the owner of the account
    INSERT INTO public.accounts_users_association (account_id, user_email, role)
    VALUES (new_account_id, auth.email(), 'owner');
    
    RETURN new_account_id;
END;
$$;
ALTER FUNCTION "public"."create_account"("account_name" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "private"."is_user_account_owner"("user_email" "text", "account_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
        AS $_$
        SELECT EXISTS (
            SELECT 1 
            FROM "public"."accounts_users_association" 
            WHERE user_email = $1 
            AND account_id = $2 
            AND role = 'owner'
        );
    $_$;
ALTER FUNCTION "private"."is_user_account_owner"("user_email" "text", "account_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "private"."is_user_account_admin"("user_email" "text", "account_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
        AS $_$
        SELECT EXISTS (
            SELECT 1 
            FROM "public"."accounts_users_association" 
            WHERE user_email = $1 
            AND account_id = $2 
            AND role IN ('owner', 'admin')
        );
    $_$;
ALTER FUNCTION "private"."is_user_account_admin"("user_email" "text", "account_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "private"."is_user_account_member"("user_email" "text", "account_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
        AS $_$
        SELECT EXISTS (
            SELECT 1 
            FROM "public"."accounts_users_association" 
            WHERE user_email = $1 
            AND account_id = $2
            AND role IN ('owner', 'admin', 'member')
    );
    $_$;
ALTER FUNCTION "private"."is_user_account_member"("user_email" "text", "account_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "private"."get_user_accounts"("user_email" "text") RETURNS SETOF "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    set search_path = ''
    AS $_$select account_id from public.accounts_users_association where user_email = $1$_$;
ALTER FUNCTION "private"."get_user_accounts"("user_email" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_account_subscription_params"("p_account_id" "uuid", "p_chain_id" "text")
RETURNS "public"."chain_subscription_parameters"
LANGUAGE "sql" STABLE SECURITY DEFINER
SET search_path = ''
AS $_$
    SELECT st.allow_secondary_listings, st.allow_custom_currencies, scp.flat_fees, scp.sales_fees, scp.secondary_flat_fees, scp.secondary_sales_fees
    FROM "public"."subscription_tiers" st
    JOIN "public"."accounts" a ON st.id = a.subscription_id
    JOIN "public"."subscriptions_chains_parameters" scp ON st.id = scp.subscription_id AND scp.chain_id = p_chain_id
    WHERE a.id = p_account_id;
$_$;

ALTER FUNCTION "public"."get_account_subscription_params"("uuid", "p_chain_id" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."validate_jwt_request"() RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
declare
  jwt_role text := current_setting('request.jwt.claims', true)::json->>'role';
  headers jsonb := current_setting('request.headers', true)::jsonb;
  req_account_id text := headers->>'x-arcpay-account-id';
  req_jwt text := headers->>'x-arcpay-jwt';
  account_row record;
  secret_row record;
  jwt_verify_result record;
  jwt_payload jsonb;
  jwt_iat integer;
  jwt_exp integer;
begin
  -- 0. not anon role, allow the request to pass (admin)
  if jwt_role <> 'anon' then
    return;
  end if;

  -- 1. Check x-arcpay-account-id header
  if req_account_id is null or length(req_account_id) = 0 then
    raise exception 'Missing x-arcpay-account-id header';
  end if;

  -- 2. Validate account id and get authenticate_clients
  select * into account_row from "public"."accounts" where id::text = req_account_id limit 1;
  if not found then
    raise exception 'Invalid account id';
  end if;

  -- 3. Check authenticate_clients flag
  if account_row.authenticate_clients is false then
    return;
  end if;

  -- 4. Check x-arcpay-jwt header
  if req_jwt is null or length(req_jwt) = 0 then
    raise exception 'Missing x-arcpay-jwt header';
  end if;

  -- 5. Decode JWT payload (header.payload.signature)
  begin
    --  Decode the base64url into base64 and then into the payload
    --  the function decode is not able to decode directly from base64url
    jwt_payload := convert_from(
      decode(
        rpad(
          translate(split_part(req_jwt, '.', 2), '-_', '+/'),
          (length(translate(split_part(req_jwt, '.', 2), '-_', '+/')) + 3) & ~3,
          '='
        ),
        'base64'
      ),
      'utf8'
    )::jsonb;
  exception
    when others then
      raise exception 'Invalid JWT format';
  end;

  -- 6. Check iat
  if not (jwt_payload ? 'iat') or jwt_payload->>'iat' is null or jwt_payload->>'iat' !~ '^[0-9]+$' then
    raise exception 'Invalid or missing iat in JWT';
  end if;
  jwt_iat := (jwt_payload->>'iat')::integer;
  if jwt_iat > extract(epoch from now())::integer then
    raise exception 'Invalid or missing iat in JWT';
  end if;

  -- 7. Check exp (expiration) if present
  if jwt_payload ? 'exp' and jwt_payload->>'exp' is not null then
    if jwt_payload->>'exp' !~ '^[0-9]+$' then
      raise exception 'Invalid exp in JWT';
    end if;
    jwt_exp := (jwt_payload->>'exp')::integer;
    if jwt_exp < extract(epoch from now())::integer then
      raise exception 'JWT is expired';
    end if;
  end if;

  -- 8. Get all secrets for this account and verify signature
  for secret_row in
    select secret from "public"."accounts_secrets" where "account_id" = account_row.id
  loop
    begin
      select * into jwt_verify_result from extensions.verify(req_jwt, secret_row.secret::text);
      if jwt_verify_result.valid = true then
        return;
      else
        continue;
      end if;
    exception
      when others then
        continue;
    end;
  end loop;

  raise exception 'Cannot validate JWT signature';
end;
$$;
ALTER FUNCTION "public"."validate_jwt_request"() OWNER TO "postgres";

-- Grant permissions for functions
GRANT EXECUTE ON FUNCTION "public"."create_account"("account_name" "text") TO "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "private"."is_user_account_owner"("user_email" "text", "account_id" "uuid") TO "service_role";
GRANT EXECUTE ON FUNCTION "private"."is_user_account_admin"("user_email" "text", "account_id" "uuid") TO "service_role";
GRANT EXECUTE ON FUNCTION "private"."is_user_account_member"("user_email" "text", "account_id" "uuid") TO "service_role";
GRANT EXECUTE ON FUNCTION "private"."get_user_accounts"("user_email" "text") TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_account_subscription_params"("uuid", "p_chain_id" "text") TO "anon", "authenticated", "service_role";
GRANT EXECUTE ON FUNCTION "public"."validate_jwt_request"() TO "anon", "authenticated", "service_role";

-------------------- RLS --------------------
-- accounts
CREATE POLICY "Owners can delete account" ON "public"."accounts" FOR DELETE TO "authenticated" USING ("private"."is_user_account_owner"((select "auth"."email"()), "id"));
CREATE POLICY "Admins can update account" ON "public"."accounts" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "id"));
CREATE POLICY "Members can view account" ON "public"."accounts" FOR SELECT TO "authenticated" USING ("private"."is_user_account_member"((select "auth"."email"()), "id"));

-- accounts_addresses
CREATE POLICY "Account members can view addresses" ON "public"."accounts_addresses" FOR SELECT TO "authenticated" USING ("private"."is_user_account_member"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can insert addresses" ON "public"."accounts_addresses" FOR INSERT TO "authenticated" WITH CHECK ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can update addresses" ON "public"."accounts_addresses" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can delete addresses" ON "public"."accounts_addresses" FOR DELETE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));

-- accounts_users_association
CREATE POLICY "Account members can view users in their account" ON "public"."accounts_users_association" FOR SELECT TO "authenticated" USING ("private"."is_user_account_member"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can insert account users" ON "public"."accounts_users_association" FOR INSERT TO "authenticated" WITH CHECK ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can update account users" ON "public"."accounts_users_association" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can delete account users" ON "public"."accounts_users_association" FOR DELETE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));

-- accounts_chains_parameters
CREATE POLICY "Public can view chain parameters" ON "public"."accounts_chains_parameters" FOR SELECT USING (true);
CREATE POLICY "Account admins can insert accounts chain parameters" ON "public"."accounts_chains_parameters" FOR INSERT TO "authenticated" WITH CHECK ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can update accounts chain parameters" ON "public"."accounts_chains_parameters" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can delete accounts chain parameters" ON "public"."accounts_chains_parameters" FOR DELETE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));

-- accounts_currencies
CREATE POLICY "Public can view account currencies" ON "public"."accounts_currencies" FOR SELECT USING (true);
CREATE POLICY "Account admins can insert account currencies" ON "public"."accounts_currencies" FOR INSERT TO "authenticated" WITH CHECK ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can update account currencies" ON "public"."accounts_currencies" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can delete account currencies" ON "public"."accounts_currencies" FOR DELETE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));

-- RLS for accounts_secrets
CREATE POLICY "Account admins can select secrets" ON "public"."accounts_secrets" FOR SELECT TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can insert secrets" ON "public"."accounts_secrets" FOR INSERT TO "authenticated" WITH CHECK ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can update secrets" ON "public"."accounts_secrets" FOR UPDATE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));
CREATE POLICY "Account admins can delete secrets" ON "public"."accounts_secrets" FOR DELETE TO "authenticated" USING ("private"."is_user_account_admin"((select "auth"."email"()), "account_id"));