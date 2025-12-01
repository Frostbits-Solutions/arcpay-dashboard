drop policy "Enable insert for all users" on "public"."auctions";

drop policy "Enable read access for all users" on "public"."auctions";

drop policy "Members can delete auctions" on "public"."auctions";

drop policy "Members can update auctions" on "public"."auctions";

drop policy "Enable insert for all users" on "public"."dutch_auctions";

drop policy "Enable read access for all users" on "public"."dutch_auctions";

drop policy "Members can delete dutch auctions" on "public"."dutch_auctions";

drop policy "Members can update dutch auctions" on "public"."dutch_auctions";

drop policy "Enable insert for all users" on "public"."sales";

drop policy "Enable read access for all users" on "public"."sales";

drop policy "Members can delete sales" on "public"."sales";

drop policy "Members can update sales" on "public"."sales";

revoke delete on table "public"."auctions" from "anon";

revoke insert on table "public"."auctions" from "anon";

revoke references on table "public"."auctions" from "anon";

revoke select on table "public"."auctions" from "anon";

revoke trigger on table "public"."auctions" from "anon";

revoke truncate on table "public"."auctions" from "anon";

revoke update on table "public"."auctions" from "anon";

revoke delete on table "public"."auctions" from "authenticated";

revoke insert on table "public"."auctions" from "authenticated";

revoke references on table "public"."auctions" from "authenticated";

revoke select on table "public"."auctions" from "authenticated";

revoke trigger on table "public"."auctions" from "authenticated";

revoke truncate on table "public"."auctions" from "authenticated";

revoke update on table "public"."auctions" from "authenticated";

revoke delete on table "public"."auctions" from "service_role";

revoke insert on table "public"."auctions" from "service_role";

revoke references on table "public"."auctions" from "service_role";

revoke select on table "public"."auctions" from "service_role";

revoke trigger on table "public"."auctions" from "service_role";

revoke truncate on table "public"."auctions" from "service_role";

revoke update on table "public"."auctions" from "service_role";

revoke delete on table "public"."dutch_auctions" from "anon";

revoke insert on table "public"."dutch_auctions" from "anon";

revoke references on table "public"."dutch_auctions" from "anon";

revoke select on table "public"."dutch_auctions" from "anon";

revoke trigger on table "public"."dutch_auctions" from "anon";

revoke truncate on table "public"."dutch_auctions" from "anon";

revoke update on table "public"."dutch_auctions" from "anon";

revoke delete on table "public"."dutch_auctions" from "authenticated";

revoke insert on table "public"."dutch_auctions" from "authenticated";

revoke references on table "public"."dutch_auctions" from "authenticated";

revoke select on table "public"."dutch_auctions" from "authenticated";

revoke trigger on table "public"."dutch_auctions" from "authenticated";

revoke truncate on table "public"."dutch_auctions" from "authenticated";

revoke update on table "public"."dutch_auctions" from "authenticated";

revoke delete on table "public"."dutch_auctions" from "service_role";

revoke insert on table "public"."dutch_auctions" from "service_role";

revoke references on table "public"."dutch_auctions" from "service_role";

revoke select on table "public"."dutch_auctions" from "service_role";

revoke trigger on table "public"."dutch_auctions" from "service_role";

revoke truncate on table "public"."dutch_auctions" from "service_role";

revoke update on table "public"."dutch_auctions" from "service_role";

revoke delete on table "public"."sales" from "anon";

revoke insert on table "public"."sales" from "anon";

revoke references on table "public"."sales" from "anon";

revoke select on table "public"."sales" from "anon";

revoke trigger on table "public"."sales" from "anon";

revoke truncate on table "public"."sales" from "anon";

revoke update on table "public"."sales" from "anon";

revoke delete on table "public"."sales" from "authenticated";

revoke insert on table "public"."sales" from "authenticated";

revoke references on table "public"."sales" from "authenticated";

revoke select on table "public"."sales" from "authenticated";

revoke trigger on table "public"."sales" from "authenticated";

revoke truncate on table "public"."sales" from "authenticated";

revoke update on table "public"."sales" from "authenticated";

revoke delete on table "public"."sales" from "service_role";

revoke insert on table "public"."sales" from "service_role";

revoke references on table "public"."sales" from "service_role";

revoke select on table "public"."sales" from "service_role";

revoke trigger on table "public"."sales" from "service_role";

revoke truncate on table "public"."sales" from "service_role";

revoke update on table "public"."sales" from "service_role";

alter table "public"."auctions" drop constraint "auctions_listing_id_fkey";

alter table "public"."dutch_auctions" drop constraint "dutch_auctions_listing_id_fkey";

alter table "public"."sales" drop constraint "sales_listing_id_fkey";

drop function public.get_listing_by_id(uuid);

drop type "public"."composite_listing";

alter table "public"."auctions" drop constraint "auctions_pkey";

alter table "public"."dutch_auctions" drop constraint "dutch_auctions_pkey";

alter table "public"."sales" drop constraint "sales_pkey";

drop index if exists "public"."auctions_pkey";

drop index if exists "public"."dutch_auctions_pkey";

drop index if exists "public"."sales_pkey";

drop table "public"."auctions";

drop table "public"."dutch_auctions";

drop table "public"."sales";

set check_function_bodies = off;

create type "public"."composite_listing" as ("id" uuid, "created_at" timestamp without time zone, "updated_at" timestamp without time zone, "status" listings_statuses, "network_id" text, "contract_version" text, "creator_address" text, "name" text, "type" listings_types, "app_id" bigint, "currency" bigint, "currency_name" text, "currency_ticker" text, "currency_icon" text, "currency_type" currency_type, "currency_decimals" bigint, "asset_id" text, "asset_thumbnail" text, "asset_type" assets_types, "asset_qty" double precision, "metadata" jsonb);

CREATE OR REPLACE FUNCTION public.get_listing_by_id(listing_id uuid)
 RETURNS composite_listing
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$select
        l.id,
        l.created_at,
        l.updated_at,
        l.status,
        l.network_id,
        l.contract_version,
        l.creator_address,
        l.name,
        l.type,
        l.app_id,
        l.currency,
        c.name as "currency_name",
        c.ticker as "currency_ticker",
        c.icon as "currency_icon",
        c.type as "currency_type",
        c.decimals as "currency_decimals",
        l.asset_id,
        l.asset_thumbnail,
        l.asset_type,
        l.asset_qty,
        l.metadata
    from public.listings l
        left join public.currencies c on (c.id = l.currency and c.network_id = l.network_id)
    where l.id = get_listing_by_id.listing_id$function$
;



