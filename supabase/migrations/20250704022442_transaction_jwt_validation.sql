alter type "public"."accounts_users_roles" rename to "accounts_users_roles__old_version_to_be_dropped";

create type "public"."accounts_users_roles" as enum ('owner', 'admin', 'member');

alter table "public"."accounts_users_association" alter column role type "public"."accounts_users_roles" using role::text::"public"."accounts_users_roles";

drop type "public"."accounts_users_roles__old_version_to_be_dropped";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.validate_jwt_request()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

create policy "Account admins can select secrets"
on "public"."accounts_secrets"
as permissive
for select
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));



