create type "public"."currency_type" as enum ('algo', 'asa', 'voi', 'arc200');

drop type "public"."composite_listing";

alter type "public"."assets_types" rename to "assets_types__old_version_to_be_dropped";

create type "public"."assets_types" as enum ('ARC72', 'OFFCHAIN', 'ASA');

alter type "public"."chains" rename to "chains__old_version_to_be_dropped";

create type "public"."chains" as enum ('voi:testnet', 'voi:mainnet', 'algo:testnet', 'algo:mainnet');

alter table "public"."accounts_addresses" alter column chain type "public"."chains" using chain::text::"public"."chains";

alter table "public"."currencies" alter column chain type "public"."chains" using chain::text::"public"."chains";

alter table "public"."listings" alter column asset_type type "public"."assets_types" using asset_type::text::"public"."assets_types";

alter table "public"."listings" alter column chain type "public"."chains" using chain::text::"public"."chains";

alter table "public"."transactions" alter column chain type "public"."chains" using chain::text::"public"."chains";

drop type "public"."assets_types__old_version_to_be_dropped";

drop type "public"."chains__old_version_to_be_dropped";

alter table "public"."accounts" add column "s_secondary_sales_fee_address" text;

alter table "public"."currencies" add column "currency_type" currency_type not null;

alter table "public"."currencies" add column "fees_address" text;

create type "public"."composite_listing" as ("id" uuid, "created_at" timestamp without time zone, "updated_at" timestamp without time zone, "status" listings_statuses, "chain" chains, "seller_address" text, "listing_name" text, "listing_currency" text, "listing_type" listings_types, "app_id" bigint, "asset_id" text, "asset_thumbnail" text, "asset_type" assets_types, "asset_qty" double precision, "asset_creator" text, "tags" text, "min_price" double precision, "max_price" double precision, "increment" double precision, "duration" integer, "auction_type" auctions_type, "asking_price" double precision);


