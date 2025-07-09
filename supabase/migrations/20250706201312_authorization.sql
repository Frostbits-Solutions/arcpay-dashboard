set check_function_bodies = off;

CREATE OR REPLACE FUNCTION private.authorize_request(account_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  headers jsonb := current_setting('request.headers', true)::jsonb;
  auth_jwt text := headers->>'x-arcpay-auth';
  account_row record;
  secret_row record;
  jwt_verify_result record;
  jwt_payload jsonb;
  jwt_iat integer;
  jwt_exp integer;
begin
  -- 1. Validate account id
  select * into account_row from "public"."accounts" where id::text = account_id limit 1;
  if not found then
    raise exception 'Authorization Failed: Invalid account id';
  end if;

  -- 2. Check authorize_requests flag
  if account_row.authorize_requests is false then
    return true;
  end if;

  -- 3. Check x-arcpay-auth header
  if auth_jwt is null or length(auth_jwt) = 0 then
    raise exception 'Authorization Failed: Missing x-arcpay-auth header';
  end if;

  -- 4. Decode JWT payload (header.payload.signature)
  begin
    --  Decode the base64url into base64 and then into the payload
    --  the function decode is not able to decode directly from base64url
    jwt_payload := convert_from(
      decode(
        rpad(
          translate(split_part(auth_jwt, '.', 2), '-_', '+/'),
          (length(translate(split_part(auth_jwt, '.', 2), '-_', '+/')) + 3) & ~3,
          '='
        ),
        'base64'
      ),
      'utf8'
    )::jsonb;
  exception
    when others then
      raise exception 'Authorization Failed: Invalid token format';
  end;

  -- 5. Check iat
  if not (jwt_payload ? 'iat') or jwt_payload->>'iat' is null or jwt_payload->>'iat' !~ '^[0-9]+$' then
    raise exception 'Authorization Failed: Invalid or missing iat';
  end if;
  jwt_iat := (jwt_payload->>'iat')::integer;
  if jwt_iat > extract(epoch from now())::integer then
    raise exception 'Authorization Failed: Invalid iat';
  end if;

  -- 6. Check exp (expiration) if present
  if jwt_payload ? 'exp' and jwt_payload->>'exp' is not null then
    if jwt_payload->>'exp' !~ '^[0-9]+$' then
      raise exception 'Authorization Failed: Invalid exp';
    end if;
    jwt_exp := (jwt_payload->>'exp')::integer;
    if jwt_exp < extract(epoch from now())::integer then
      raise exception 'Authorization Failed: Token expired';
    end if;
  end if;

  -- 7. Get all secrets for this account and verify signature
  for secret_row in
    select secret from "public"."accounts_secrets" where "account_id" = account_row.id
  loop
    begin
      select * into jwt_verify_result from extensions.verify(auth_jwt, secret_row.secret::text);
      if jwt_verify_result.valid = true then
        return true;
      else
        continue;
      end if;
    exception
      when others then
        continue;
    end;
  end loop;

  raise exception 'Authorization Failed: Invalid signature';
end;
$function$
;

CREATE OR REPLACE FUNCTION private.authorize_listing_request(listing_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."listings"
        WHERE "listings"."id" = "authorize_listing_request"."listing_id"
        AND "private"."authorize_request"("listings"."account_id")
    )
$function$
;

drop policy "Enable insert for all users" on "public"."auctions";

drop policy "Enable read access for all users" on "public"."auctions";

drop policy "Enable insert for all users" on "public"."dutch_auctions";

drop policy "Enable read access for all users" on "public"."dutch_auctions";

drop policy "Enable insert for all users" on "public"."listings";

drop policy "Enable read access for all users" on "public"."listings";

drop policy "Enable insert for all users" on "public"."sales";

drop policy "Enable read access for all users" on "public"."sales";

alter type "public"."accounts_users_roles" rename to "accounts_users_roles__old_version_to_be_dropped";

create type "public"."accounts_users_roles" as enum ('owner', 'admin', 'member');

alter table "public"."accounts_users_association" alter column role type "public"."accounts_users_roles" using role::text::"public"."accounts_users_roles";

drop type "public"."accounts_users_roles__old_version_to_be_dropped";

alter table "public"."accounts" drop column "authenticate_clients";

alter table "public"."accounts" add column "authorize_requests" boolean not null default true;

create policy "Account admins can select secrets"
on "public"."accounts_secrets"
as permissive
for select
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Enable insert for all users"
on "public"."auctions"
as permissive
for insert
to public
with check (private.authorize_listing_request(listing_id));


create policy "Enable read access for all users"
on "public"."auctions"
as permissive
for select
to public
using (private.authorize_listing_request(listing_id));


create policy "Enable insert for all users"
on "public"."dutch_auctions"
as permissive
for insert
to public
with check (private.authorize_listing_request(listing_id));


create policy "Enable read access for all users"
on "public"."dutch_auctions"
as permissive
for select
to public
using (private.authorize_listing_request(listing_id));


create policy "Enable insert for all users"
on "public"."listings"
as permissive
for insert
to public
with check (private.authorize_request(account_id));


create policy "Enable read access for all users"
on "public"."listings"
as permissive
for select
to public
using (private.authorize_request(account_id));


create policy "Enable insert for all users"
on "public"."sales"
as permissive
for insert
to public
with check (private.authorize_listing_request(listing_id));


create policy "Enable read access for all users"
on "public"."sales"
as permissive
for select
to public
using (private.authorize_listing_request(listing_id));