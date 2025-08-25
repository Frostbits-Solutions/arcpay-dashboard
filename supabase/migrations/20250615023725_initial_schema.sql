create schema if not exists "private";
CREATE EXTENSION IF NOT EXISTS pg_cron;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION "private"."create_daily_transactions_partition"()
RETURNS void
LANGUAGE plpgsql
set search_path = ''
AS $$
DECLARE
    start_date date;
    end_date date;
    partition_name text;
BEGIN
    -- Create partition for tomorrow
    start_date := CURRENT_DATE + INTERVAL '1 day';
    end_date := start_date + INTERVAL '1 day';
    partition_name := 'transactions_' || to_char(start_date, 'YYYY_MM_DD');
    
    -- Check if partition already exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = partition_name 
        AND table_schema = 'public'
    ) THEN
        EXECUTE format('CREATE TABLE "public"."%I" PARTITION OF public.transactions FOR VALUES FROM (%L) TO (%L)',
                      partition_name, start_date, end_date);
        EXECUTE format('ALTER TABLE "public"."%I" ENABLE ROW LEVEL SECURITY', partition_name);
        EXECUTE format('GRANT SELECT ON TABLE "public"."%I" TO "anon"', partition_name);
        EXECUTE format('GRANT SELECT ON TABLE "public"."%I" TO "authenticated"', partition_name);
        EXECUTE format('GRANT ALL ON TABLE "public"."%I" TO "service_role"', partition_name);
        EXECUTE format('CREATE POLICY "Enable read access for all users" ON "public"."%I" FOR SELECT USING (true)', partition_name);
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION private.get_user_accounts(user_email text)
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$select account_id from public.accounts_users_association where user_email = $1$function$
;

CREATE OR REPLACE FUNCTION private.is_user_account_admin(user_email text, account_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
        SELECT EXISTS (
            SELECT 1 
            FROM "public"."accounts_users_association" 
            WHERE user_email = $1 
            AND account_id = $2 
            AND role IN ('owner', 'admin')
        );
    $function$
;

CREATE OR REPLACE FUNCTION private.is_user_account_member(user_email text, account_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
        SELECT EXISTS (
            SELECT 1 
            FROM "public"."accounts_users_association" 
            WHERE user_email = $1 
            AND account_id = $2
            AND role IN ('owner', 'admin', 'member')
    );
    $function$
;

CREATE OR REPLACE FUNCTION private.is_user_account_owner(user_email text, account_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
        SELECT EXISTS (
            SELECT 1 
            FROM "public"."accounts_users_association" 
            WHERE user_email = $1 
            AND account_id = $2 
            AND role = 'owner'
        );
    $function$
;


create type "public"."accounts_users_roles" as enum ('owner', 'admin', 'moderator', 'member');

create type "public"."assets_types" as enum ('arc72', 'offchain', 'asa');

create type "public"."contract_tag_enum" as enum ('clear', 'algo_asa_auction_approval', 'algo_asa_dutch_approval', 'algo_asa_sale_approval', 'algo_offchain_sale_approval', 'asa_asa_auction_approval', 'asa_asa_dutch_approval', 'asa_asa_sale_approval', 'asa_offchain_sale_approval', 'arc200_arc72_auction_approval', 'arc200_arc72_dutch_approval', 'arc200_arc72_sale_approval', 'arc200_offchain_sale_approval', 'voi_arc72_auction_approval', 'voi_arc72_dutch_approval', 'voi_arc72_sale_approval', 'voi_offchain_sale_approval');

create type "public"."currency_type" as enum ('algo', 'asa', 'voi', 'arc200');

create type "public"."listings_statuses" as enum ('pending', 'active', 'closed', 'cancelled');

create type "public"."listings_types" as enum ('sale', 'auction', 'dutch');

create type "public"."transaction_type" as enum ('create', 'fund', 'buy', 'bid', 'close', 'update', 'cancel');

create table "public"."accounts" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "authenticate_clients" boolean not null default true,
    "subscription_id" bigint not null default '1'::bigint,
    "subscription_expiration_date" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."accounts" enable row level security;

create table "public"."accounts_addresses" (
    "created_at" timestamp with time zone not null default now(),
    "address" text not null,
    "name" text,
    "account_id" uuid not null
);


alter table "public"."accounts_addresses" enable row level security;

create table "public"."accounts_networks_parameters" (
    "account_id" uuid not null,
    "network_id" text not null,
    "enable_secondary" boolean not null default false,
    "secondary_percentage_fee" double precision not null default 0,
    "secondary_fee_address" text,
    "created_at" timestamp without time zone not null default now()
);


alter table "public"."accounts_networks_parameters" enable row level security;

create table "public"."accounts_currencies" (
    "created_at" timestamp with time zone not null default now(),
    "account_id" uuid not null,
    "currency" bigint not null,
    "network_id" text not null
);


alter table "public"."accounts_currencies" enable row level security;

create table "public"."accounts_secrets" (
    "created_at" timestamp with time zone not null default now(),
    "account_id" uuid not null,
    "secret" uuid not null default gen_random_uuid(),
    "name" text not null
);


alter table "public"."accounts_secrets" enable row level security;

create table "public"."accounts_users_association" (
    "created_at" timestamp with time zone not null default now(),
    "account_id" uuid not null,
    "user_email" text not null,
    "role" accounts_users_roles not null
);


alter table "public"."accounts_users_association" enable row level security;

create table "public"."auctions" (
    "listing_id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone,
    "start_price" double precision not null,
    "increment" double precision not null,
    "duration" integer not null
);


alter table "public"."auctions" enable row level security;

create table "public"."networks" (
    "id" text not null,
    "chain" text NOT NULL,
    "netid" text NOT NULL,
    "node_url" text NOT NULL,
    "node_port" integer NOT NULL,
    "node_token" text,
    "created_at" timestamp without time zone not null default now(),
    "last_indexed_at" timestamp without time zone,
    "fee_proxy_app_id" bigint
);


alter table "public"."networks" enable row level security;

create table "public"."contracts" (
    "tag" contract_tag_enum not null,
    "version" text not null,
    "network_id" text not null,
    "byte_code" text not null,
    "created_at" timestamp without time zone not null default now()
);


alter table "public"."contracts" enable row level security;

create table "public"."contracts_versions" (
    "version" text not null,
    "network_id" text not null,
    "created_at" timestamp without time zone not null default now()
);


alter table "public"."contracts_versions" enable row level security;

create table "public"."currencies" (
    "id" bigint not null,
    "network_id" text not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone,
    "name" text not null,
    "ticker" text not null,
    "icon" text,
    "type" currency_type not null,
    "decimals" bigint not null,
    "is_public" boolean not null default true
);


alter table "public"."currencies" enable row level security;

create table "public"."dutch_auctions" (
    "listing_id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone,
    "min_price" double precision not null,
    "max_price" double precision,
    "duration" integer not null
);


alter table "public"."dutch_auctions" enable row level security;

create table "public"."listings" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone,
    "account_id" uuid not null,
    "status" listings_statuses not null,
    "creator_address" text not null,
    "name" text not null,
    "currency" bigint not null,
    "type" listings_types not null,
    "app_id" bigint not null,
    "asset_id" bigint not null,
    "asset_thumbnail" text,
    "asset_type" assets_types not null,
    "asset_qty" double precision not null default '1'::double precision,
    "metadata" jsonb not null default '{}'::jsonb,
    "network_id" text not null,
    "contract_version" text not null
);


alter table "public"."listings" enable row level security;

create table "public"."sales" (
    "listing_id" uuid not null,
    "created_at" timestamp without time zone not null default now(),
    "updated_at" timestamp without time zone,
    "price" numeric not null
);


alter table "public"."sales" enable row level security;

create table "public"."subscription_tiers" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "name" text not null,
    "duration" bigint,
    "allow_secondary_listings" boolean not null default false,
    "allow_custom_currencies" boolean not null default false
);


alter table "public"."subscription_tiers" enable row level security;

create table "public"."subscriptions_networks_parameters" (
    "subscription_id" bigint not null,
    "network_id" text not null,
    "flat_fees" double precision not null default 10,
    "sales_fees" double precision not null default 0,
    "secondary_flat_fees" double precision not null default 20,
    "secondary_sales_fees" double precision not null default 0,
    "created_at" timestamp without time zone not null default now()
);


alter table "public"."subscriptions_networks_parameters" enable row level security;

create table "public"."transactions" (
    "id" text not null,
    "created_at" timestamp with time zone not null default now(),
    "from_address" text not null,
    "network_id" text not null,
    "app_id" bigint not null,
    "type" transaction_type not null,
    "amount" double precision,
    "currency" bigint not null,
    "metadata" jsonb not null default '{}'::jsonb
) partition by RANGE (created_at);


alter table "public"."transactions" enable row level security;

CREATE UNIQUE INDEX accounts_addresses_pkey ON public.accounts_addresses USING btree (address, account_id);

CREATE UNIQUE INDEX accounts_networks_parameters_pkey ON public.accounts_networks_parameters USING btree (account_id, network_id);

CREATE UNIQUE INDEX accounts_currencies_pkey ON public.accounts_currencies USING btree (account_id, currency, network_id);

CREATE UNIQUE INDEX accounts_name_key ON public.accounts USING btree (name);

CREATE UNIQUE INDEX accounts_pkey ON public.accounts USING btree (id);

CREATE UNIQUE INDEX accounts_secrets_pkey ON public.accounts_secrets USING btree (account_id, secret);

CREATE UNIQUE INDEX accounts_users_association_pkey ON public.accounts_users_association USING btree (account_id, user_email);

CREATE UNIQUE INDEX auctions_pkey ON public.auctions USING btree (listing_id);

CREATE UNIQUE INDEX networks_pkey ON public.networks USING btree (id);

CREATE UNIQUE INDEX contracts_pkey ON public.contracts USING btree (version, tag, network_id);

CREATE UNIQUE INDEX contracts_versions_pkey ON public.contracts_versions USING btree (version, network_id);

CREATE UNIQUE INDEX currencies_pkey ON public.currencies USING btree (id, network_id);

CREATE UNIQUE INDEX dutch_auctions_pkey ON public.dutch_auctions USING btree (listing_id);

CREATE INDEX idx_listings ON public.listings USING btree (account_id, status, network_id, currency, type, asset_type, asset_id, creator_address);

CREATE UNIQUE INDEX listings_pkey ON public.listings USING btree (id);

CREATE UNIQUE INDEX sales_pkey ON public.sales USING btree (listing_id);

CREATE UNIQUE INDEX subscription_tiers_pkey ON public.subscription_tiers USING btree (id);

CREATE UNIQUE INDEX subscriptions_networks_parameters_pkey ON public.subscriptions_networks_parameters USING btree (subscription_id, network_id);

alter table "public"."accounts" add constraint "accounts_pkey" PRIMARY KEY using index "accounts_pkey";

alter table "public"."accounts_addresses" add constraint "accounts_addresses_pkey" PRIMARY KEY using index "accounts_addresses_pkey";

alter table "public"."accounts_networks_parameters" add constraint "accounts_networks_parameters_pkey" PRIMARY KEY using index "accounts_networks_parameters_pkey";

alter table "public"."accounts_currencies" add constraint "accounts_currencies_pkey" PRIMARY KEY using index "accounts_currencies_pkey";

alter table "public"."accounts_secrets" add constraint "accounts_secrets_pkey" PRIMARY KEY using index "accounts_secrets_pkey";

alter table "public"."accounts_users_association" add constraint "accounts_users_association_pkey" PRIMARY KEY using index "accounts_users_association_pkey";

alter table "public"."auctions" add constraint "auctions_pkey" PRIMARY KEY using index "auctions_pkey";

alter table "public"."networks" add constraint "networks_pkey" PRIMARY KEY using index "networks_pkey";

alter table "public"."contracts" add constraint "contracts_pkey" PRIMARY KEY using index "contracts_pkey";

alter table "public"."contracts_versions" add constraint "contracts_versions_pkey" PRIMARY KEY using index "contracts_versions_pkey";

alter table "public"."currencies" add constraint "currencies_pkey" PRIMARY KEY using index "currencies_pkey";

alter table "public"."dutch_auctions" add constraint "dutch_auctions_pkey" PRIMARY KEY using index "dutch_auctions_pkey";

alter table "public"."listings" add constraint "listings_pkey" PRIMARY KEY using index "listings_pkey";

alter table "public"."sales" add constraint "sales_pkey" PRIMARY KEY using index "sales_pkey";

alter table "public"."subscription_tiers" add constraint "subscription_tiers_pkey" PRIMARY KEY using index "subscription_tiers_pkey";

alter table "public"."subscriptions_networks_parameters" add constraint "subscriptions_networks_parameters_pkey" PRIMARY KEY using index "subscriptions_networks_parameters_pkey";

alter table "public"."transactions" add constraint "transactions_pkey" PRIMARY KEY ("id", "network_id","app_id", "from_address", "created_at");

alter table "public"."accounts" add constraint "accounts_name_key" UNIQUE using index "accounts_name_key";

alter table "public"."accounts" add constraint "accounts_subscription_id_fkey" FOREIGN KEY (subscription_id) REFERENCES subscription_tiers(id) not valid;

alter table "public"."accounts" validate constraint "accounts_subscription_id_fkey";

alter table "public"."accounts_addresses" add constraint "accounts_addresses_account_id_fkey" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE not valid;

alter table "public"."accounts_addresses" validate constraint "accounts_addresses_account_id_fkey";

alter table "public"."accounts_networks_parameters" add constraint "accounts_networks_parameters_account_id_fkey" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE not valid;

alter table "public"."accounts_networks_parameters" validate constraint "accounts_networks_parameters_account_id_fkey";

alter table "public"."accounts_networks_parameters" add constraint "accounts_networks_parameters_network_id_fkey" FOREIGN KEY (network_id) REFERENCES networks(id) ON DELETE CASCADE not valid;

alter table "public"."accounts_networks_parameters" validate constraint "accounts_networks_parameters_network_id_fkey";

alter table "public"."accounts_currencies" add constraint "accounts_currencies_account_id_fkey" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE not valid;

alter table "public"."accounts_currencies" validate constraint "accounts_currencies_account_id_fkey";

alter table "public"."accounts_currencies" add constraint "accounts_currencies_currency_fkey" FOREIGN KEY (currency, network_id) REFERENCES currencies(id, network_id) ON DELETE CASCADE not valid;

alter table "public"."accounts_currencies" validate constraint "accounts_currencies_currency_fkey";

alter table "public"."accounts_secrets" add constraint "accounts_secrets_account_id_fkey" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE not valid;

alter table "public"."accounts_secrets" validate constraint "accounts_secrets_account_id_fkey";

alter table "public"."accounts_users_association" add constraint "accounts_users_association_account_id_fkey" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE not valid;

alter table "public"."accounts_users_association" validate constraint "accounts_users_association_account_id_fkey";

alter table "public"."auctions" add constraint "auctions_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."auctions" validate constraint "auctions_listing_id_fkey";

alter table "public"."contracts" add constraint "contracts_version_fkey" FOREIGN KEY (version, network_id) REFERENCES contracts_versions(version, network_id) ON DELETE CASCADE not valid;

alter table "public"."contracts" validate constraint "contracts_version_fkey";

alter table "public"."contracts_versions" add constraint "contracts_versions_network_id_fkey" FOREIGN KEY (network_id) REFERENCES networks(id) ON DELETE RESTRICT not valid;

alter table "public"."contracts_versions" validate constraint "contracts_versions_network_id_fkey";

alter table "public"."currencies" add constraint "currencies_network_id_fkey" FOREIGN KEY (network_id) REFERENCES networks(id) ON DELETE CASCADE not valid;

alter table "public"."currencies" validate constraint "currencies_network_id_fkey";

alter table "public"."dutch_auctions" add constraint "dutch_auctions_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."dutch_auctions" validate constraint "dutch_auctions_listing_id_fkey";

alter table "public"."listings" add constraint "listings_account_id_fkey" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE not valid;

alter table "public"."listings" validate constraint "listings_account_id_fkey";

alter table "public"."listings" add constraint "listings_network_id_fkey" FOREIGN KEY (network_id) REFERENCES networks(id) not valid;

alter table "public"."listings" validate constraint "listings_network_id_fkey";

alter table "public"."listings" add constraint "listings_contract_version_network_id_fkey" FOREIGN KEY (contract_version, network_id) REFERENCES contracts_versions(version, network_id) ON DELETE RESTRICT not valid;

alter table "public"."listings" validate constraint "listings_contract_version_network_id_fkey";

alter table "public"."listings" add constraint "listings_currency_network_id_fkey" FOREIGN KEY (currency, network_id) REFERENCES currencies(id, network_id) ON DELETE CASCADE not valid;

alter table "public"."listings" validate constraint "listings_currency_network_id_fkey";

alter table "public"."sales" add constraint "sales_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE not valid;

alter table "public"."sales" validate constraint "sales_listing_id_fkey";

alter table "public"."subscriptions_networks_parameters" add constraint "subscriptions_networks_parameters_network_id_fkey" FOREIGN KEY (network_id) REFERENCES networks(id) ON DELETE CASCADE not valid;

alter table "public"."subscriptions_networks_parameters" validate constraint "subscriptions_networks_parameters_network_id_fkey";

alter table "public"."subscriptions_networks_parameters" add constraint "subscriptions_networks_parameters_subscription_id_fkey" FOREIGN KEY (subscription_id) REFERENCES subscription_tiers(id) ON DELETE CASCADE not valid;

alter table "public"."subscriptions_networks_parameters" validate constraint "subscriptions_networks_parameters_subscription_id_fkey";

alter table "public"."transactions" add constraint "transactions_network_id_fkey" FOREIGN KEY (network_id) REFERENCES networks(id) ON DELETE CASCADE;

alter table "public"."transactions" add constraint "transactions_currency_fkey" FOREIGN KEY (currency, network_id) REFERENCES currencies(id, network_id) ON DELETE CASCADE;

set check_function_bodies = off;

create type "public"."network_subscription_parameters" as ("allow_secondary_listings" boolean, "allow_custom_currencies" boolean, "flat_fees" double precision, "sales_fees" double precision, "secondary_flat_fees" double precision, "secondary_sales_fees" double precision);

create type "public"."composite_listing" as ("id" uuid, "created_at" timestamp without time zone, "updated_at" timestamp without time zone, "status" listings_statuses, "network_id" text, "contract_version" text, "creator_address" text, "name" text, "type" listings_types, "app_id" bigint, "currency" bigint, "currency_name" text, "currency_ticker" text, "currency_icon" text, "currency_type" currency_type, "currency_decimals" bigint, "asset_id" text, "asset_thumbnail" text, "asset_type" assets_types, "asset_qty" double precision, "metadata" jsonb, "sale_price" double precision, "auction_start_price" double precision, "auction_increment" double precision, "auction_duration" integer, "dutch_min_price" double precision, "dutch_max_price" double precision, "dutch_duration" integer);

create type "public"."transactions_count" as ("time" timestamp without time zone, "count" bigint);

create type "public"."transactions_volume" as ("time" timestamp without time zone, "volume" double precision, "currency_id" text, "currency_ticker" text);

CREATE OR REPLACE FUNCTION public.create_account(account_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_account_subscription_params(p_account_id uuid, p_network_id text)
 RETURNS network_subscription_parameters
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT st.allow_secondary_listings, st.allow_custom_currencies, scp.flat_fees, scp.sales_fees, scp.secondary_flat_fees, scp.secondary_sales_fees
    FROM "public"."subscription_tiers" st
    JOIN "public"."accounts" a ON st.id = a.subscription_id
    JOIN "public"."subscriptions_networks_parameters" scp ON st.id = scp.subscription_id AND scp.network_id = p_network_id
    WHERE a.id = p_account_id;
$function$
;

CREATE OR REPLACE FUNCTION public.get_daily_sales_volume_timeseries(account_id uuid, network_id text)
 RETURNS SETOF transactions_volume
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
    select
    date_trunc('day', t.created_at) AS time,
    sum(t.amount) / POWER(10,c.decimals) AS volume,
    c.id as currency_id,
    c.ticker as currency_ticker
    from "public"."transactions" t
    left join "public"."currencies" c on t.currency = c.id and t."network_id" = c."network_id"
    left join "public"."listings" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '30 days' and t.type = 'buy' and t."network_id" = $2
    group by time, c.id, c.decimals, c.ticker
    order by time asc
    $function$
;

CREATE OR REPLACE FUNCTION public.get_hourly_transactions_timeseries(account_id uuid, network_id text)
 RETURNS SETOF transactions_count
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
    select
    date_trunc('hour', t.created_at) AS time,
    count(t.id) AS count
    from "public"."transactions" t
    left join "public"."listings" l on t.app_id = l.app_id
    where l.account_id = $1 and t.created_at > NOW() - interval '168 hours' and t."network_id" = $2
    group by time
    order by time asc
    $function$
;

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
        l.metadata,
        s.price as "sale_price",
        a.start_price as "auction_start_price",
        a.increment as "auction_increment",
        a.duration as "auction_duration",
        d.min_price as "dutch_min_price",
        d.max_price as "dutch_max_price",
        d.duration as "dutch_duration"
    from public.listings l
        left join public.auctions a on a.listing_id = get_listing_by_id.listing_id
        left join public.dutch_auctions d on d.listing_id = get_listing_by_id.listing_id
        left join public.sales s on s.listing_id = get_listing_by_id.listing_id
        left join public.currencies c on (c.id = l.currency and c.network_id = l.network_id)
    where l.id = get_listing_by_id.listing_id$function$
;

CREATE OR REPLACE FUNCTION public.listings(transactions)
 RETURNS SETOF listings
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$ select * from public.listings where app_id = $1.app_id $function$
;

CREATE OR REPLACE FUNCTION public.transactions(listings)
 RETURNS SETOF transactions
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$ select * from public.transactions where app_id = $1.app_id $function$
;

create or replace function public.transactions_changes()
returns trigger
security definer
language plpgsql
set search_path = ''
as $$
begin
  perform realtime.broadcast_changes(
    'topic:transactions',                              -- topic - the topic to which we're broadcasting
    TG_OP,                                             -- event - the event that triggered the function
    TG_OP,                                             -- operation - the operation that triggered the function
    TG_TABLE_NAME,                                     -- table - the table that caused the trigger
    TG_TABLE_SCHEMA,                                   -- schema - the schema of the table that caused the trigger
    NEW,                                               -- new record - the record after the change
    OLD                                                -- old record - the record before the change
  );
  return null;
end;
$$;

grant delete on table "public"."accounts" to "anon";

grant insert on table "public"."accounts" to "anon";

grant references on table "public"."accounts" to "anon";

grant select on table "public"."accounts" to "anon";

grant trigger on table "public"."accounts" to "anon";

grant truncate on table "public"."accounts" to "anon";

grant update on table "public"."accounts" to "anon";

grant delete on table "public"."accounts" to "authenticated";

grant insert on table "public"."accounts" to "authenticated";

grant references on table "public"."accounts" to "authenticated";

grant select on table "public"."accounts" to "authenticated";

grant trigger on table "public"."accounts" to "authenticated";

grant truncate on table "public"."accounts" to "authenticated";

grant update on table "public"."accounts" to "authenticated";

grant delete on table "public"."accounts" to "service_role";

grant insert on table "public"."accounts" to "service_role";

grant references on table "public"."accounts" to "service_role";

grant select on table "public"."accounts" to "service_role";

grant trigger on table "public"."accounts" to "service_role";

grant truncate on table "public"."accounts" to "service_role";

grant update on table "public"."accounts" to "service_role";

grant delete on table "public"."accounts_addresses" to "anon";

grant insert on table "public"."accounts_addresses" to "anon";

grant references on table "public"."accounts_addresses" to "anon";

grant select on table "public"."accounts_addresses" to "anon";

grant trigger on table "public"."accounts_addresses" to "anon";

grant truncate on table "public"."accounts_addresses" to "anon";

grant update on table "public"."accounts_addresses" to "anon";

grant delete on table "public"."accounts_addresses" to "authenticated";

grant insert on table "public"."accounts_addresses" to "authenticated";

grant references on table "public"."accounts_addresses" to "authenticated";

grant select on table "public"."accounts_addresses" to "authenticated";

grant trigger on table "public"."accounts_addresses" to "authenticated";

grant truncate on table "public"."accounts_addresses" to "authenticated";

grant update on table "public"."accounts_addresses" to "authenticated";

grant delete on table "public"."accounts_addresses" to "service_role";

grant insert on table "public"."accounts_addresses" to "service_role";

grant references on table "public"."accounts_addresses" to "service_role";

grant select on table "public"."accounts_addresses" to "service_role";

grant trigger on table "public"."accounts_addresses" to "service_role";

grant truncate on table "public"."accounts_addresses" to "service_role";

grant update on table "public"."accounts_addresses" to "service_role";

grant delete on table "public"."accounts_networks_parameters" to "anon";

grant insert on table "public"."accounts_networks_parameters" to "anon";

grant references on table "public"."accounts_networks_parameters" to "anon";

grant select on table "public"."accounts_networks_parameters" to "anon";

grant trigger on table "public"."accounts_networks_parameters" to "anon";

grant truncate on table "public"."accounts_networks_parameters" to "anon";

grant update on table "public"."accounts_networks_parameters" to "anon";

grant delete on table "public"."accounts_networks_parameters" to "authenticated";

grant insert on table "public"."accounts_networks_parameters" to "authenticated";

grant references on table "public"."accounts_networks_parameters" to "authenticated";

grant select on table "public"."accounts_networks_parameters" to "authenticated";

grant trigger on table "public"."accounts_networks_parameters" to "authenticated";

grant truncate on table "public"."accounts_networks_parameters" to "authenticated";

grant update on table "public"."accounts_networks_parameters" to "authenticated";

grant delete on table "public"."accounts_networks_parameters" to "service_role";

grant insert on table "public"."accounts_networks_parameters" to "service_role";

grant references on table "public"."accounts_networks_parameters" to "service_role";

grant select on table "public"."accounts_networks_parameters" to "service_role";

grant trigger on table "public"."accounts_networks_parameters" to "service_role";

grant truncate on table "public"."accounts_networks_parameters" to "service_role";

grant update on table "public"."accounts_networks_parameters" to "service_role";

grant delete on table "public"."accounts_currencies" to "anon";

grant insert on table "public"."accounts_currencies" to "anon";

grant references on table "public"."accounts_currencies" to "anon";

grant select on table "public"."accounts_currencies" to "anon";

grant trigger on table "public"."accounts_currencies" to "anon";

grant truncate on table "public"."accounts_currencies" to "anon";

grant update on table "public"."accounts_currencies" to "anon";

grant delete on table "public"."accounts_currencies" to "authenticated";

grant insert on table "public"."accounts_currencies" to "authenticated";

grant references on table "public"."accounts_currencies" to "authenticated";

grant select on table "public"."accounts_currencies" to "authenticated";

grant trigger on table "public"."accounts_currencies" to "authenticated";

grant truncate on table "public"."accounts_currencies" to "authenticated";

grant update on table "public"."accounts_currencies" to "authenticated";

grant delete on table "public"."accounts_currencies" to "service_role";

grant insert on table "public"."accounts_currencies" to "service_role";

grant references on table "public"."accounts_currencies" to "service_role";

grant select on table "public"."accounts_currencies" to "service_role";

grant trigger on table "public"."accounts_currencies" to "service_role";

grant truncate on table "public"."accounts_currencies" to "service_role";

grant update on table "public"."accounts_currencies" to "service_role";

grant delete on table "public"."accounts_secrets" to "anon";

grant insert on table "public"."accounts_secrets" to "anon";

grant references on table "public"."accounts_secrets" to "anon";

grant select on table "public"."accounts_secrets" to "anon";

grant trigger on table "public"."accounts_secrets" to "anon";

grant truncate on table "public"."accounts_secrets" to "anon";

grant update on table "public"."accounts_secrets" to "anon";

grant delete on table "public"."accounts_secrets" to "authenticated";

grant insert on table "public"."accounts_secrets" to "authenticated";

grant references on table "public"."accounts_secrets" to "authenticated";

grant select on table "public"."accounts_secrets" to "authenticated";

grant trigger on table "public"."accounts_secrets" to "authenticated";

grant truncate on table "public"."accounts_secrets" to "authenticated";

grant update on table "public"."accounts_secrets" to "authenticated";

grant delete on table "public"."accounts_secrets" to "service_role";

grant insert on table "public"."accounts_secrets" to "service_role";

grant references on table "public"."accounts_secrets" to "service_role";

grant select on table "public"."accounts_secrets" to "service_role";

grant trigger on table "public"."accounts_secrets" to "service_role";

grant truncate on table "public"."accounts_secrets" to "service_role";

grant update on table "public"."accounts_secrets" to "service_role";

grant delete on table "public"."accounts_users_association" to "anon";

grant insert on table "public"."accounts_users_association" to "anon";

grant references on table "public"."accounts_users_association" to "anon";

grant select on table "public"."accounts_users_association" to "anon";

grant trigger on table "public"."accounts_users_association" to "anon";

grant truncate on table "public"."accounts_users_association" to "anon";

grant update on table "public"."accounts_users_association" to "anon";

grant delete on table "public"."accounts_users_association" to "authenticated";

grant insert on table "public"."accounts_users_association" to "authenticated";

grant references on table "public"."accounts_users_association" to "authenticated";

grant select on table "public"."accounts_users_association" to "authenticated";

grant trigger on table "public"."accounts_users_association" to "authenticated";

grant truncate on table "public"."accounts_users_association" to "authenticated";

grant update on table "public"."accounts_users_association" to "authenticated";

grant delete on table "public"."accounts_users_association" to "service_role";

grant insert on table "public"."accounts_users_association" to "service_role";

grant references on table "public"."accounts_users_association" to "service_role";

grant select on table "public"."accounts_users_association" to "service_role";

grant trigger on table "public"."accounts_users_association" to "service_role";

grant truncate on table "public"."accounts_users_association" to "service_role";

grant update on table "public"."accounts_users_association" to "service_role";

grant delete on table "public"."auctions" to "anon";

grant insert on table "public"."auctions" to "anon";

grant references on table "public"."auctions" to "anon";

grant select on table "public"."auctions" to "anon";

grant trigger on table "public"."auctions" to "anon";

grant truncate on table "public"."auctions" to "anon";

grant update on table "public"."auctions" to "anon";

grant delete on table "public"."auctions" to "authenticated";

grant insert on table "public"."auctions" to "authenticated";

grant references on table "public"."auctions" to "authenticated";

grant select on table "public"."auctions" to "authenticated";

grant trigger on table "public"."auctions" to "authenticated";

grant truncate on table "public"."auctions" to "authenticated";

grant update on table "public"."auctions" to "authenticated";

grant delete on table "public"."auctions" to "service_role";

grant insert on table "public"."auctions" to "service_role";

grant references on table "public"."auctions" to "service_role";

grant select on table "public"."auctions" to "service_role";

grant trigger on table "public"."auctions" to "service_role";

grant truncate on table "public"."auctions" to "service_role";

grant update on table "public"."auctions" to "service_role";

grant delete on table "public"."networks" to "anon";

grant insert on table "public"."networks" to "anon";

grant references on table "public"."networks" to "anon";

grant select on table "public"."networks" to "anon";

grant trigger on table "public"."networks" to "anon";

grant truncate on table "public"."networks" to "anon";

grant update on table "public"."networks" to "anon";

grant delete on table "public"."networks" to "authenticated";

grant insert on table "public"."networks" to "authenticated";

grant references on table "public"."networks" to "authenticated";

grant select on table "public"."networks" to "authenticated";

grant trigger on table "public"."networks" to "authenticated";

grant truncate on table "public"."networks" to "authenticated";

grant update on table "public"."networks" to "authenticated";

grant delete on table "public"."networks" to "service_role";

grant insert on table "public"."networks" to "service_role";

grant references on table "public"."networks" to "service_role";

grant select on table "public"."networks" to "service_role";

grant trigger on table "public"."networks" to "service_role";

grant truncate on table "public"."networks" to "service_role";

grant update on table "public"."networks" to "service_role";

grant delete on table "public"."contracts" to "anon";

grant insert on table "public"."contracts" to "anon";

grant references on table "public"."contracts" to "anon";

grant select on table "public"."contracts" to "anon";

grant trigger on table "public"."contracts" to "anon";

grant truncate on table "public"."contracts" to "anon";

grant update on table "public"."contracts" to "anon";

grant delete on table "public"."contracts" to "authenticated";

grant insert on table "public"."contracts" to "authenticated";

grant references on table "public"."contracts" to "authenticated";

grant select on table "public"."contracts" to "authenticated";

grant trigger on table "public"."contracts" to "authenticated";

grant truncate on table "public"."contracts" to "authenticated";

grant update on table "public"."contracts" to "authenticated";

grant delete on table "public"."contracts" to "service_role";

grant insert on table "public"."contracts" to "service_role";

grant references on table "public"."contracts" to "service_role";

grant select on table "public"."contracts" to "service_role";

grant trigger on table "public"."contracts" to "service_role";

grant truncate on table "public"."contracts" to "service_role";

grant update on table "public"."contracts" to "service_role";

grant delete on table "public"."contracts_versions" to "anon";

grant insert on table "public"."contracts_versions" to "anon";

grant references on table "public"."contracts_versions" to "anon";

grant select on table "public"."contracts_versions" to "anon";

grant trigger on table "public"."contracts_versions" to "anon";

grant truncate on table "public"."contracts_versions" to "anon";

grant update on table "public"."contracts_versions" to "anon";

grant delete on table "public"."contracts_versions" to "authenticated";

grant insert on table "public"."contracts_versions" to "authenticated";

grant references on table "public"."contracts_versions" to "authenticated";

grant select on table "public"."contracts_versions" to "authenticated";

grant trigger on table "public"."contracts_versions" to "authenticated";

grant truncate on table "public"."contracts_versions" to "authenticated";

grant update on table "public"."contracts_versions" to "authenticated";

grant delete on table "public"."contracts_versions" to "service_role";

grant insert on table "public"."contracts_versions" to "service_role";

grant references on table "public"."contracts_versions" to "service_role";

grant select on table "public"."contracts_versions" to "service_role";

grant trigger on table "public"."contracts_versions" to "service_role";

grant truncate on table "public"."contracts_versions" to "service_role";

grant update on table "public"."contracts_versions" to "service_role";

grant delete on table "public"."currencies" to "anon";

grant insert on table "public"."currencies" to "anon";

grant references on table "public"."currencies" to "anon";

grant select on table "public"."currencies" to "anon";

grant trigger on table "public"."currencies" to "anon";

grant truncate on table "public"."currencies" to "anon";

grant update on table "public"."currencies" to "anon";

grant delete on table "public"."currencies" to "authenticated";

grant insert on table "public"."currencies" to "authenticated";

grant references on table "public"."currencies" to "authenticated";

grant select on table "public"."currencies" to "authenticated";

grant trigger on table "public"."currencies" to "authenticated";

grant truncate on table "public"."currencies" to "authenticated";

grant update on table "public"."currencies" to "authenticated";

grant delete on table "public"."currencies" to "service_role";

grant insert on table "public"."currencies" to "service_role";

grant references on table "public"."currencies" to "service_role";

grant select on table "public"."currencies" to "service_role";

grant trigger on table "public"."currencies" to "service_role";

grant truncate on table "public"."currencies" to "service_role";

grant update on table "public"."currencies" to "service_role";

grant delete on table "public"."dutch_auctions" to "anon";

grant insert on table "public"."dutch_auctions" to "anon";

grant references on table "public"."dutch_auctions" to "anon";

grant select on table "public"."dutch_auctions" to "anon";

grant trigger on table "public"."dutch_auctions" to "anon";

grant truncate on table "public"."dutch_auctions" to "anon";

grant update on table "public"."dutch_auctions" to "anon";

grant delete on table "public"."dutch_auctions" to "authenticated";

grant insert on table "public"."dutch_auctions" to "authenticated";

grant references on table "public"."dutch_auctions" to "authenticated";

grant select on table "public"."dutch_auctions" to "authenticated";

grant trigger on table "public"."dutch_auctions" to "authenticated";

grant truncate on table "public"."dutch_auctions" to "authenticated";

grant update on table "public"."dutch_auctions" to "authenticated";

grant delete on table "public"."dutch_auctions" to "service_role";

grant insert on table "public"."dutch_auctions" to "service_role";

grant references on table "public"."dutch_auctions" to "service_role";

grant select on table "public"."dutch_auctions" to "service_role";

grant trigger on table "public"."dutch_auctions" to "service_role";

grant truncate on table "public"."dutch_auctions" to "service_role";

grant update on table "public"."dutch_auctions" to "service_role";

grant delete on table "public"."listings" to "anon";

grant insert on table "public"."listings" to "anon";

grant references on table "public"."listings" to "anon";

grant select on table "public"."listings" to "anon";

grant trigger on table "public"."listings" to "anon";

grant truncate on table "public"."listings" to "anon";

grant update on table "public"."listings" to "anon";

grant delete on table "public"."listings" to "authenticated";

grant insert on table "public"."listings" to "authenticated";

grant references on table "public"."listings" to "authenticated";

grant select on table "public"."listings" to "authenticated";

grant trigger on table "public"."listings" to "authenticated";

grant truncate on table "public"."listings" to "authenticated";

grant update on table "public"."listings" to "authenticated";

grant delete on table "public"."listings" to "service_role";

grant insert on table "public"."listings" to "service_role";

grant references on table "public"."listings" to "service_role";

grant select on table "public"."listings" to "service_role";

grant trigger on table "public"."listings" to "service_role";

grant truncate on table "public"."listings" to "service_role";

grant update on table "public"."listings" to "service_role";

grant delete on table "public"."sales" to "anon";

grant insert on table "public"."sales" to "anon";

grant references on table "public"."sales" to "anon";

grant select on table "public"."sales" to "anon";

grant trigger on table "public"."sales" to "anon";

grant truncate on table "public"."sales" to "anon";

grant update on table "public"."sales" to "anon";

grant delete on table "public"."sales" to "authenticated";

grant insert on table "public"."sales" to "authenticated";

grant references on table "public"."sales" to "authenticated";

grant select on table "public"."sales" to "authenticated";

grant trigger on table "public"."sales" to "authenticated";

grant truncate on table "public"."sales" to "authenticated";

grant update on table "public"."sales" to "authenticated";

grant delete on table "public"."sales" to "service_role";

grant insert on table "public"."sales" to "service_role";

grant references on table "public"."sales" to "service_role";

grant select on table "public"."sales" to "service_role";

grant trigger on table "public"."sales" to "service_role";

grant truncate on table "public"."sales" to "service_role";

grant update on table "public"."sales" to "service_role";

grant delete on table "public"."subscription_tiers" to "anon";

grant insert on table "public"."subscription_tiers" to "anon";

grant references on table "public"."subscription_tiers" to "anon";

grant select on table "public"."subscription_tiers" to "anon";

grant trigger on table "public"."subscription_tiers" to "anon";

grant truncate on table "public"."subscription_tiers" to "anon";

grant update on table "public"."subscription_tiers" to "anon";

grant delete on table "public"."subscription_tiers" to "authenticated";

grant insert on table "public"."subscription_tiers" to "authenticated";

grant references on table "public"."subscription_tiers" to "authenticated";

grant select on table "public"."subscription_tiers" to "authenticated";

grant trigger on table "public"."subscription_tiers" to "authenticated";

grant truncate on table "public"."subscription_tiers" to "authenticated";

grant update on table "public"."subscription_tiers" to "authenticated";

grant delete on table "public"."subscription_tiers" to "service_role";

grant insert on table "public"."subscription_tiers" to "service_role";

grant references on table "public"."subscription_tiers" to "service_role";

grant select on table "public"."subscription_tiers" to "service_role";

grant trigger on table "public"."subscription_tiers" to "service_role";

grant truncate on table "public"."subscription_tiers" to "service_role";

grant update on table "public"."subscription_tiers" to "service_role";

grant delete on table "public"."subscriptions_networks_parameters" to "anon";

grant insert on table "public"."subscriptions_networks_parameters" to "anon";

grant references on table "public"."subscriptions_networks_parameters" to "anon";

grant select on table "public"."subscriptions_networks_parameters" to "anon";

grant trigger on table "public"."subscriptions_networks_parameters" to "anon";

grant truncate on table "public"."subscriptions_networks_parameters" to "anon";

grant update on table "public"."subscriptions_networks_parameters" to "anon";

grant delete on table "public"."subscriptions_networks_parameters" to "authenticated";

grant insert on table "public"."subscriptions_networks_parameters" to "authenticated";

grant references on table "public"."subscriptions_networks_parameters" to "authenticated";

grant select on table "public"."subscriptions_networks_parameters" to "authenticated";

grant trigger on table "public"."subscriptions_networks_parameters" to "authenticated";

grant truncate on table "public"."subscriptions_networks_parameters" to "authenticated";

grant update on table "public"."subscriptions_networks_parameters" to "authenticated";

grant delete on table "public"."subscriptions_networks_parameters" to "service_role";

grant insert on table "public"."subscriptions_networks_parameters" to "service_role";

grant references on table "public"."subscriptions_networks_parameters" to "service_role";

grant select on table "public"."subscriptions_networks_parameters" to "service_role";

grant trigger on table "public"."subscriptions_networks_parameters" to "service_role";

grant truncate on table "public"."subscriptions_networks_parameters" to "service_role";

grant update on table "public"."subscriptions_networks_parameters" to "service_role";

grant delete on table "public"."transactions" to "anon";

grant insert on table "public"."transactions" to "anon";

grant references on table "public"."transactions" to "anon";

grant select on table "public"."transactions" to "anon";

grant trigger on table "public"."transactions" to "anon";

grant truncate on table "public"."transactions" to "anon";

grant update on table "public"."transactions" to "anon";

grant delete on table "public"."transactions" to "authenticated";

grant insert on table "public"."transactions" to "authenticated";

grant references on table "public"."transactions" to "authenticated";

grant select on table "public"."transactions" to "authenticated";

grant trigger on table "public"."transactions" to "authenticated";

grant truncate on table "public"."transactions" to "authenticated";

grant update on table "public"."transactions" to "authenticated";

grant delete on table "public"."transactions" to "service_role";

grant insert on table "public"."transactions" to "service_role";

grant references on table "public"."transactions" to "service_role";

grant select on table "public"."transactions" to "service_role";

grant trigger on table "public"."transactions" to "service_role";

grant truncate on table "public"."transactions" to "service_role";

grant update on table "public"."transactions" to "service_role";

create policy "Admins can update account"
on "public"."accounts"
as permissive
for update
to authenticated
using (private.is_user_account_admin(auth.email(), id));


create policy "Owners can update and delete account"
on "public"."accounts"
as permissive
for all
to authenticated
using (private.is_user_account_owner(auth.email(), id));


create policy "Account admins can manage addresses"
on "public"."accounts_addresses"
as permissive
for all
to authenticated
using (private.is_user_account_admin(auth.email(), account_id));


create policy "Account members can view addresses"
on "public"."accounts_addresses"
as permissive
for select
to authenticated
using (private.is_user_account_member(auth.email(), account_id));


create policy "Account admins can manage accounts network parameters"
on "public"."accounts_networks_parameters"
as permissive
for all
to authenticated
using (private.is_user_account_admin(auth.email(), account_id));


create policy "Public can view network parameters"
on "public"."accounts_networks_parameters"
as permissive
for select
to public
using (true);


create policy "Account admins can manage account currencies"
on "public"."accounts_currencies"
as permissive
for all
to authenticated
using (private.is_user_account_admin(auth.email(), account_id));


create policy "Public can view account currencies"
on "public"."accounts_currencies"
as permissive
for select
to public
using (true);


create policy "Account admins can manage secrets"
on "public"."accounts_secrets"
as permissive
for all
to authenticated
using (private.is_user_account_admin(auth.email(), account_id));


create policy "Account admins can manage account users"
on "public"."accounts_users_association"
as permissive
for all
to authenticated
using (private.is_user_account_admin(auth.email(), account_id));


create policy "Account members can view users in their account"
on "public"."accounts_users_association"
as permissive
for select
to authenticated
using (private.is_user_account_member(auth.email(), account_id));


create policy "Enable insert for all users"
on "public"."auctions"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."auctions"
as permissive
for select
to public
using (true);


create policy "Members can manage auctions"
on "public"."auctions"
as permissive
for all
to authenticated
using ((EXISTS ( SELECT 1
   FROM listings
  WHERE ((listings.id = auctions.listing_id) AND private.is_user_account_member(auth.email(), listings.account_id)))));


create policy "Enable read access for all users"
on "public"."networks"
as permissive
for select
to public
using (true);


create policy "Allow public read access to all contracts"
on "public"."contracts"
as permissive
for select
to public
using (true);


create policy "Allow public read access to all contracts versions"
on "public"."contracts_versions"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."currencies"
as permissive
for select
to public
using (true);


create policy "Enable insert for all users"
on "public"."dutch_auctions"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."dutch_auctions"
as permissive
for select
to public
using (true);


create policy "Members can manage dutch auctions"
on "public"."dutch_auctions"
as permissive
for all
to authenticated
using ((EXISTS ( SELECT 1
   FROM listings
  WHERE ((listings.id = dutch_auctions.listing_id) AND private.is_user_account_member(auth.email(), listings.account_id)))));


create policy "Enable insert for all users"
on "public"."listings"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."listings"
as permissive
for select
to public
using (true);


create policy "Members can manage listings"
on "public"."listings"
as permissive
for all
to authenticated
using (private.is_user_account_member(auth.email(), account_id));


create policy "Enable insert for all users"
on "public"."sales"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."sales"
as permissive
for select
to public
using (true);


create policy "Members can manage sales"
on "public"."sales"
as permissive
for all
to authenticated
using ((EXISTS ( SELECT 1
   FROM listings
  WHERE ((listings.id = sales.listing_id) AND private.is_user_account_member(auth.email(), listings.account_id)))));


create policy "Enable read access for all users"
on "public"."subscription_tiers"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."subscriptions_networks_parameters"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."transactions"
as permissive
for select
to public
using (true);


CREATE TRIGGER handle_transactions_changes AFTER INSERT OR DELETE OR UPDATE ON public.transactions FOR EACH ROW EXECUTE FUNCTION transactions_changes();


