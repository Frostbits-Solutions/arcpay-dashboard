create type "public"."apps_statuses" as enum ('pending', 'active', 'closed', 'cancelled');

create type "public"."apps_types" as enum ('swap', 'payment');

drop policy "Account admins can delete account currencies" on "public"."accounts_currencies";

drop policy "Account admins can insert account currencies" on "public"."accounts_currencies";

drop policy "Account admins can update account currencies" on "public"."accounts_currencies";

drop policy "Public can view account currencies" on "public"."accounts_currencies";

drop policy "Allow public read access to all contracts versions" on "public"."contracts_versions";

drop policy "Enable read access for all users" on "public"."currencies";

drop policy "Enable insert for all users" on "public"."listings";

drop policy "Enable read access for all users" on "public"."listings";

drop policy "Members can delete listings" on "public"."listings";

drop policy "Members can update listings" on "public"."listings";

revoke delete on table "public"."accounts_currencies" from "anon";

revoke insert on table "public"."accounts_currencies" from "anon";

revoke references on table "public"."accounts_currencies" from "anon";

revoke select on table "public"."accounts_currencies" from "anon";

revoke trigger on table "public"."accounts_currencies" from "anon";

revoke truncate on table "public"."accounts_currencies" from "anon";

revoke update on table "public"."accounts_currencies" from "anon";

revoke delete on table "public"."accounts_currencies" from "authenticated";

revoke insert on table "public"."accounts_currencies" from "authenticated";

revoke references on table "public"."accounts_currencies" from "authenticated";

revoke select on table "public"."accounts_currencies" from "authenticated";

revoke trigger on table "public"."accounts_currencies" from "authenticated";

revoke truncate on table "public"."accounts_currencies" from "authenticated";

revoke update on table "public"."accounts_currencies" from "authenticated";

revoke delete on table "public"."accounts_currencies" from "service_role";

revoke insert on table "public"."accounts_currencies" from "service_role";

revoke references on table "public"."accounts_currencies" from "service_role";

revoke select on table "public"."accounts_currencies" from "service_role";

revoke trigger on table "public"."accounts_currencies" from "service_role";

revoke truncate on table "public"."accounts_currencies" from "service_role";

revoke update on table "public"."accounts_currencies" from "service_role";

revoke delete on table "public"."contracts_versions" from "anon";

revoke insert on table "public"."contracts_versions" from "anon";

revoke references on table "public"."contracts_versions" from "anon";

revoke select on table "public"."contracts_versions" from "anon";

revoke trigger on table "public"."contracts_versions" from "anon";

revoke truncate on table "public"."contracts_versions" from "anon";

revoke update on table "public"."contracts_versions" from "anon";

revoke delete on table "public"."contracts_versions" from "authenticated";

revoke insert on table "public"."contracts_versions" from "authenticated";

revoke references on table "public"."contracts_versions" from "authenticated";

revoke select on table "public"."contracts_versions" from "authenticated";

revoke trigger on table "public"."contracts_versions" from "authenticated";

revoke truncate on table "public"."contracts_versions" from "authenticated";

revoke update on table "public"."contracts_versions" from "authenticated";

revoke delete on table "public"."contracts_versions" from "service_role";

revoke insert on table "public"."contracts_versions" from "service_role";

revoke references on table "public"."contracts_versions" from "service_role";

revoke select on table "public"."contracts_versions" from "service_role";

revoke trigger on table "public"."contracts_versions" from "service_role";

revoke truncate on table "public"."contracts_versions" from "service_role";

revoke update on table "public"."contracts_versions" from "service_role";

revoke delete on table "public"."currencies" from "anon";

revoke insert on table "public"."currencies" from "anon";

revoke references on table "public"."currencies" from "anon";

revoke select on table "public"."currencies" from "anon";

revoke trigger on table "public"."currencies" from "anon";

revoke truncate on table "public"."currencies" from "anon";

revoke update on table "public"."currencies" from "anon";

revoke delete on table "public"."currencies" from "authenticated";

revoke insert on table "public"."currencies" from "authenticated";

revoke references on table "public"."currencies" from "authenticated";

revoke select on table "public"."currencies" from "authenticated";

revoke trigger on table "public"."currencies" from "authenticated";

revoke truncate on table "public"."currencies" from "authenticated";

revoke update on table "public"."currencies" from "authenticated";

revoke delete on table "public"."currencies" from "service_role";

revoke insert on table "public"."currencies" from "service_role";

revoke references on table "public"."currencies" from "service_role";

revoke select on table "public"."currencies" from "service_role";

revoke trigger on table "public"."currencies" from "service_role";

revoke truncate on table "public"."currencies" from "service_role";

revoke update on table "public"."currencies" from "service_role";

revoke delete on table "public"."listings" from "anon";

revoke insert on table "public"."listings" from "anon";

revoke references on table "public"."listings" from "anon";

revoke select on table "public"."listings" from "anon";

revoke trigger on table "public"."listings" from "anon";

revoke truncate on table "public"."listings" from "anon";

revoke update on table "public"."listings" from "anon";

revoke delete on table "public"."listings" from "authenticated";

revoke insert on table "public"."listings" from "authenticated";

revoke references on table "public"."listings" from "authenticated";

revoke select on table "public"."listings" from "authenticated";

revoke trigger on table "public"."listings" from "authenticated";

revoke truncate on table "public"."listings" from "authenticated";

revoke update on table "public"."listings" from "authenticated";

revoke delete on table "public"."listings" from "service_role";

revoke insert on table "public"."listings" from "service_role";

revoke references on table "public"."listings" from "service_role";

revoke select on table "public"."listings" from "service_role";

revoke trigger on table "public"."listings" from "service_role";

revoke truncate on table "public"."listings" from "service_role";

revoke update on table "public"."listings" from "service_role";

alter table "public"."accounts_currencies" drop constraint "accounts_currencies_account_id_fkey";

alter table "public"."accounts_currencies" drop constraint "accounts_currencies_currency_fkey";

alter table "public"."contracts" drop constraint "contracts_version_fkey";

alter table "public"."contracts_versions" drop constraint "contracts_versions_network_id_fkey";

alter table "public"."currencies" drop constraint "currencies_network_id_fkey";

alter table "public"."listings" drop constraint "listings_account_id_fkey";

alter table "public"."listings" drop constraint "listings_contract_version_network_id_fkey";

alter table "public"."listings" drop constraint "listings_currency_network_id_fkey";

alter table "public"."listings" drop constraint "listings_network_id_fkey";

alter table "public"."transactions" drop constraint "transactions_currency_fkey";

drop function if exists "private"."authorize_listing_request"(listing_id uuid);

drop function if exists "private"."can_user_manage_listing"(listing_id uuid);

drop function if exists "public"."get_listing_by_id"(listing_id uuid);

drop type "public"."composite_listing";

drop function if exists "public"."listings"(public.transactions);

drop function if exists "public"."transactions"(public.listings);

drop function if exists public.get_account_subscription_params(p_account_id uuid, p_network_id text);

drop type "public"."network_subscription_parameters";

drop function if exists public.get_daily_sales_volume_timeseries(account_id uuid, network_id text);

drop type "public"."transactions_volume";

alter table "public"."accounts_currencies" drop constraint "accounts_currencies_pkey";

alter table "public"."contracts_versions" drop constraint "contracts_versions_pkey";

alter table "public"."currencies" drop constraint "currencies_pkey";

alter table "public"."listings" drop constraint "listings_pkey";

alter table "public"."contracts" drop constraint "contracts_pkey";

drop index if exists "public"."accounts_currencies_pkey";

drop index if exists "public"."contracts_versions_pkey";

drop index if exists "public"."currencies_pkey";

drop index if exists "public"."idx_listings";

drop index if exists "public"."listings_pkey";

drop index if exists "public"."contracts_pkey";

drop table "public"."accounts_currencies";

drop table "public"."contracts_versions";

drop table "public"."currencies";

drop table "public"."listings";

alter type "public"."assets_types" rename to "assets_types__old_version_to_be_dropped";

create type "public"."assets_types" as enum ('asa');


  create table "public"."accounts_assets" (
    "created_at" timestamp with time zone not null default now(),
    "account_id" uuid not null,
    "asset_id" bigint not null,
    "network_id" text not null
      );


alter table "public"."accounts_assets" enable row level security;


  create table "public"."apps" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone,
    "account_id" uuid not null,
    "status" public.apps_statuses not null,
    "creator_address" text not null,
    "app_id" bigint not null,
    "name" text not null,
    "type" public.apps_types not null,
    "network_id" text not null,
    "contract_tag" public.contract_tag_enum not null,
    "contract_version" text not null,
    "metadata" jsonb not null default '{}'::jsonb
      );


alter table "public"."apps" enable row level security;


  create table "public"."assets" (
    "id" bigint not null,
    "network_id" text not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone,
    "name" text not null,
    "ticker" text not null,
    "icon" text,
    "type" public.assets_types not null,
    "decimals" bigint not null,
    "is_public" boolean not null default true,
    "metadata" jsonb not null default '{}'::jsonb
      );


alter table "public"."assets" enable row level security;

drop type "public"."assets_types__old_version_to_be_dropped";

alter table "public"."subscription_tiers" drop column "allow_custom_currencies";

alter table "public"."subscription_tiers" add column "allow_custom_assets" boolean not null default false;

alter table "public"."transactions" drop column "amount";

alter table "public"."transactions" drop column "currency";

alter table "public"."transactions" add column "quoted_amount" double precision;

alter table "public"."transactions" add column "quoted_asset_id" bigint NOT NULL;

drop type "public"."currency_type";

drop type "public"."listings_statuses";

drop type "public"."listings_types";

CREATE UNIQUE INDEX accounts_assets_pkey ON public.accounts_assets USING btree (account_id, asset_id, network_id);

CREATE UNIQUE INDEX apps_pkey ON public.apps USING btree (id);

CREATE UNIQUE INDEX assets_pkey ON public.assets USING btree (id, network_id);

CREATE INDEX idx_apps ON public.apps USING btree (account_id, status, network_id, type, app_id, creator_address);

CREATE UNIQUE INDEX contracts_pkey ON public.contracts USING btree (tag, version, network_id);

alter table "public"."accounts_assets" add constraint "accounts_assets_pkey" PRIMARY KEY using index "accounts_assets_pkey";

alter table "public"."apps" add constraint "apps_pkey" PRIMARY KEY using index "apps_pkey";

alter table "public"."assets" add constraint "assets_pkey" PRIMARY KEY using index "assets_pkey";

alter table "public"."contracts" add constraint "contracts_pkey" PRIMARY KEY using index "contracts_pkey";

alter table "public"."accounts_assets" add constraint "accounts_assets_account_id_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE ;

alter table "public"."accounts_assets" validate constraint "accounts_assets_account_id_fkey";

alter table "public"."accounts_assets" add constraint "accounts_assets_asset_fkey" FOREIGN KEY (asset_id, network_id) REFERENCES public.assets(id, network_id) ON DELETE CASCADE ;

alter table "public"."accounts_assets" validate constraint "accounts_assets_asset_fkey";

alter table "public"."apps" add constraint "apps_account_id_fkey" FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE ;

alter table "public"."apps" validate constraint "apps_account_id_fkey";

alter table "public"."apps" add constraint "apps_contract_fkey" FOREIGN KEY (contract_tag, contract_version, network_id) REFERENCES public.contracts(tag, version, network_id) ON DELETE RESTRICT ;

alter table "public"."apps" validate constraint "apps_contract_fkey";

alter table "public"."apps" add constraint "apps_network_id_fkey" FOREIGN KEY (network_id) REFERENCES public.networks(id) ;

alter table "public"."apps" validate constraint "apps_network_id_fkey";

alter table "public"."assets" add constraint "assets_network_id_fkey" FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE ;

alter table "public"."assets" validate constraint "assets_network_id_fkey";

alter table "public"."contracts" add constraint "contracts_network_id_fkey" FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE ;

alter table "public"."contracts" validate constraint "contracts_network_id_fkey";

alter table "public"."transactions" add constraint "transactions_asset_fkey" FOREIGN KEY (quoted_asset_id, network_id) REFERENCES public.assets(id, network_id) ON DELETE CASCADE ;

alter table "public"."transactions" validate constraint "transactions_asset_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION private.authorize_app_request(app_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."apps"
        WHERE "apps"."id" = "authorize_app_request"."app_id"
        AND "private"."authorize_request"("apps"."account_id")
    )
$function$
;

CREATE OR REPLACE FUNCTION private.can_user_manage_app(app_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."apps"
        WHERE "apps"."id" = "can_user_manage_app"."app_id"
        AND "private"."is_user_account_member"((SELECT "auth"."email"()), "apps"."account_id")
    )
$function$
;

CREATE OR REPLACE FUNCTION public.apps(public.transactions)
 RETURNS SETOF public.apps
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$ select * from public.apps where app_id = $1.app_id $function$
;

CREATE OR REPLACE FUNCTION public.apps_changes()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  perform realtime.broadcast_changes(
    'topic:apps',                                      -- topic - the topic to which we're broadcasting
    TG_OP,                                             -- event - the event that triggered the function
    TG_OP,                                             -- operation - the operation that triggered the function
    TG_TABLE_NAME,                                     -- table - the table that caused the trigger
    TG_TABLE_SCHEMA,                                   -- schema - the schema of the table that caused the trigger
    NEW,                                               -- new record - the record after the change
    OLD                                                -- old record - the record before the change
  );
  return null;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.transactions(public.apps)
 RETURNS SETOF public.transactions
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$ select * from public.transactions where app_id = $1.app_id $function$
;

create type "public"."network_subscription_parameters" as ("allow_secondary_listings" boolean, "allow_custom_assets" boolean, "flat_fees" double precision, "sales_fees" double precision, "secondary_flat_fees" double precision, "secondary_sales_fees" double precision);

CREATE OR REPLACE FUNCTION public.get_account_subscription_params(p_account_id uuid, p_network_id text)
 RETURNS public.network_subscription_parameters
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT st.allow_secondary_listings, st.allow_custom_assets, scp.flat_fees, scp.sales_fees, scp.secondary_flat_fees, scp.secondary_sales_fees
    FROM "public"."subscription_tiers" st
    JOIN "public"."accounts" a ON st.id = a.subscription_id
    JOIN "public"."subscriptions_networks_parameters" scp ON st.id = scp.subscription_id AND scp.network_id = p_network_id
    WHERE a.id = p_account_id;
$function$
;

create type "public"."transactions_volume" as ("time" timestamp without time zone, "volume" double precision, "asset_id" text, "asset_ticker" text);

CREATE OR REPLACE FUNCTION public.get_daily_sales_volume_timeseries(account_id uuid, network_id text)
 RETURNS SETOF public.transactions_volume
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
    select
    date_trunc('day', t.created_at) AS time,
    sum(t.quoted_amount) / POWER(10,c.decimals) AS volume,
    c.id as asset_id,
    c.ticker as asset_ticker
    from "public"."transactions" t
    left join "public"."assets" c on t.quoted_asset_id = c.id and t."network_id" = c."network_id"
    left join "public"."apps" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '30 days' and t.type = 'buy' and t."network_id" = $2
    group by time, c.id, c.decimals, c.ticker
    order by time asc
    $function$
;

CREATE OR REPLACE FUNCTION public.get_hourly_transactions_timeseries(account_id uuid, network_id text)
 RETURNS SETOF public.transactions_count
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
    select
    date_trunc('hour', t.created_at) AS time,
    count(t.id) AS count
    from "public"."transactions" t
    left join "public"."apps" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '168 hours' and t."network_id" = $2
    group by time
    order by time asc
    $function$
;

grant delete on table "public"."accounts_assets" to "anon";

grant insert on table "public"."accounts_assets" to "anon";

grant references on table "public"."accounts_assets" to "anon";

grant select on table "public"."accounts_assets" to "anon";

grant trigger on table "public"."accounts_assets" to "anon";

grant truncate on table "public"."accounts_assets" to "anon";

grant update on table "public"."accounts_assets" to "anon";

grant delete on table "public"."accounts_assets" to "authenticated";

grant insert on table "public"."accounts_assets" to "authenticated";

grant references on table "public"."accounts_assets" to "authenticated";

grant select on table "public"."accounts_assets" to "authenticated";

grant trigger on table "public"."accounts_assets" to "authenticated";

grant truncate on table "public"."accounts_assets" to "authenticated";

grant update on table "public"."accounts_assets" to "authenticated";

grant delete on table "public"."accounts_assets" to "service_role";

grant insert on table "public"."accounts_assets" to "service_role";

grant references on table "public"."accounts_assets" to "service_role";

grant select on table "public"."accounts_assets" to "service_role";

grant trigger on table "public"."accounts_assets" to "service_role";

grant truncate on table "public"."accounts_assets" to "service_role";

grant update on table "public"."accounts_assets" to "service_role";

grant delete on table "public"."apps" to "anon";

grant insert on table "public"."apps" to "anon";

grant references on table "public"."apps" to "anon";

grant select on table "public"."apps" to "anon";

grant trigger on table "public"."apps" to "anon";

grant truncate on table "public"."apps" to "anon";

grant update on table "public"."apps" to "anon";

grant delete on table "public"."apps" to "authenticated";

grant insert on table "public"."apps" to "authenticated";

grant references on table "public"."apps" to "authenticated";

grant select on table "public"."apps" to "authenticated";

grant trigger on table "public"."apps" to "authenticated";

grant truncate on table "public"."apps" to "authenticated";

grant update on table "public"."apps" to "authenticated";

grant delete on table "public"."apps" to "service_role";

grant insert on table "public"."apps" to "service_role";

grant references on table "public"."apps" to "service_role";

grant select on table "public"."apps" to "service_role";

grant trigger on table "public"."apps" to "service_role";

grant truncate on table "public"."apps" to "service_role";

grant update on table "public"."apps" to "service_role";

grant delete on table "public"."assets" to "anon";

grant insert on table "public"."assets" to "anon";

grant references on table "public"."assets" to "anon";

grant select on table "public"."assets" to "anon";

grant trigger on table "public"."assets" to "anon";

grant truncate on table "public"."assets" to "anon";

grant update on table "public"."assets" to "anon";

grant delete on table "public"."assets" to "authenticated";

grant insert on table "public"."assets" to "authenticated";

grant references on table "public"."assets" to "authenticated";

grant select on table "public"."assets" to "authenticated";

grant trigger on table "public"."assets" to "authenticated";

grant truncate on table "public"."assets" to "authenticated";

grant update on table "public"."assets" to "authenticated";

grant delete on table "public"."assets" to "service_role";

grant insert on table "public"."assets" to "service_role";

grant references on table "public"."assets" to "service_role";

grant select on table "public"."assets" to "service_role";

grant trigger on table "public"."assets" to "service_role";

grant truncate on table "public"."assets" to "service_role";

grant update on table "public"."assets" to "service_role";


  create policy "Account admins can delete account assets"
  on "public"."accounts_assets"
  as permissive
  for delete
  to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));



  create policy "Account admins can insert account assets"
  on "public"."accounts_assets"
  as permissive
  for insert
  to authenticated
with check (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));



  create policy "Account admins can update account assets"
  on "public"."accounts_assets"
  as permissive
  for update
  to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));



  create policy "Public can view account assets"
  on "public"."accounts_assets"
  as permissive
  for select
  to public
using (true);



  create policy "Enable insert for all users"
  on "public"."apps"
  as permissive
  for insert
  to public
with check (private.authorize_request(account_id));



  create policy "Enable read access for all users"
  on "public"."apps"
  as permissive
  for select
  to public
using (private.authorize_request(account_id));



  create policy "Members can delete apps"
  on "public"."apps"
  as permissive
  for delete
  to authenticated
using (private.is_user_account_member(( SELECT auth.email() AS email), account_id));



  create policy "Members can update apps"
  on "public"."apps"
  as permissive
  for update
  to authenticated
using (private.is_user_account_member(( SELECT auth.email() AS email), account_id));



  create policy "Enable read access for all users"
  on "public"."assets"
  as permissive
  for select
  to public
using (true);


CREATE TRIGGER handle_apps_changes AFTER INSERT OR DELETE OR UPDATE ON public.apps FOR EACH ROW EXECUTE FUNCTION public.apps_changes();


  create policy "Users can listen to apps specific broadcasts"
  on "realtime"."messages"
  as permissive
  for select
  to public
using ((( SELECT realtime.topic() AS topic) ~ '^topic:apps'::text));



  create policy "Users can listen to transactions specific broadcasts"
  on "realtime"."messages"
  as permissive
  for select
  to public
using ((( SELECT realtime.topic() AS topic) ~ '^topic:transactions'::text));



  create policy "Users can select presence channels"
  on "realtime"."messages"
  as permissive
  for select
  to public
using ((extension = 'presence'::text));



  create policy "Users can update presence channels"
  on "realtime"."messages"
  as permissive
  for insert
  to public
with check ((extension = 'presence'::text));



