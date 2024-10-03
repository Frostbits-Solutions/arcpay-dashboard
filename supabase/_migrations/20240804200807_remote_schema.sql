alter table "public"."listings" drop constraint "public_listings_listing_currency_fkey";

alter table "public"."currencies" drop constraint "currencies_pkey";

drop index if exists "public"."currencies_pkey";

alter table "public"."currencies" add column "icon" text;

CREATE UNIQUE INDEX currencies_pkey ON public.currencies USING btree (id, chain);

alter table "public"."currencies" add constraint "currencies_pkey" PRIMARY KEY using index "currencies_pkey";

alter table "public"."listings" add constraint "listings_listing_currency_chain_fkey" FOREIGN KEY (listing_currency, chain) REFERENCES currencies(id, chain) not valid;

alter table "public"."listings" validate constraint "listings_listing_currency_chain_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_listing_by_id(listing_id uuid)
 RETURNS composite_listing
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$select l.id, l.created_at, l.updated_at, l.status, l.chain, l.seller_address, l.listing_name, l.listing_currency, l.listing_type, l.app_id, l.asset_id, l.asset_thumbnail, l.asset_type, l.asset_qty, l.asset_creator, l.tags, a.min_price, a.max_price, a.increment, a.duration, a.type as auctions_type, s.asking_price
        from public.listings l left join public.auctions a on a.listing_id = get_listing_by_id.listing_id left join public.sales s on s.listing_id = get_listing_by_id.listing_id where l.id = get_listing_by_id.listing_id$function$
;


