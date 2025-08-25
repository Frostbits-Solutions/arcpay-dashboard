set check_function_bodies = off;

CREATE OR REPLACE FUNCTION private.can_user_manage_listing(listing_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."listings"
        WHERE "listings"."id" = "can_user_manage_listing"."listing_id"
        AND "private"."is_user_account_member"((SELECT "auth"."email"()), "listings"."account_id")
    )
$function$
;


drop policy "Owners can update and delete account" on "public"."accounts";

drop policy "Account admins can manage addresses" on "public"."accounts_addresses";

drop policy "Account admins can manage accounts network parameters" on "public"."accounts_networks_parameters";

drop policy "Account admins can manage account currencies" on "public"."accounts_currencies";

drop policy "Account admins can manage secrets" on "public"."accounts_secrets";

drop policy "Account admins can manage account users" on "public"."accounts_users_association";

drop policy "Members can manage auctions" on "public"."auctions";

drop policy "Members can manage dutch auctions" on "public"."dutch_auctions";

drop policy "Members can manage listings" on "public"."listings";

drop policy "Members can manage sales" on "public"."sales";

drop policy "Admins can update account" on "public"."accounts";

drop policy "Account members can view addresses" on "public"."accounts_addresses";

drop policy "Account members can view users in their account" on "public"."accounts_users_association";

create policy "Members can view account"
on "public"."accounts"
as permissive
for select
to authenticated
using (private.is_user_account_member(( SELECT auth.email() AS email), id));


create policy "Owners can delete account"
on "public"."accounts"
as permissive
for delete
to authenticated
using (private.is_user_account_owner(( SELECT auth.email() AS email), id));


create policy "Account admins can delete addresses"
on "public"."accounts_addresses"
as permissive
for delete
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can insert addresses"
on "public"."accounts_addresses"
as permissive
for insert
to authenticated
with check (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can update addresses"
on "public"."accounts_addresses"
as permissive
for update
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can delete accounts network parameters"
on "public"."accounts_networks_parameters"
as permissive
for delete
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can insert accounts network parameters"
on "public"."accounts_networks_parameters"
as permissive
for insert
to authenticated
with check (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can update accounts network parameters"
on "public"."accounts_networks_parameters"
as permissive
for update
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can delete account currencies"
on "public"."accounts_currencies"
as permissive
for delete
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can insert account currencies"
on "public"."accounts_currencies"
as permissive
for insert
to authenticated
with check (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can update account currencies"
on "public"."accounts_currencies"
as permissive
for update
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can delete secrets"
on "public"."accounts_secrets"
as permissive
for delete
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can insert secrets"
on "public"."accounts_secrets"
as permissive
for insert
to authenticated
with check (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can update secrets"
on "public"."accounts_secrets"
as permissive
for update
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can delete account users"
on "public"."accounts_users_association"
as permissive
for delete
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can insert account users"
on "public"."accounts_users_association"
as permissive
for insert
to authenticated
with check (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Account admins can update account users"
on "public"."accounts_users_association"
as permissive
for update
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), account_id));


create policy "Members can delete auctions"
on "public"."auctions"
as permissive
for delete
to authenticated
using (private.can_user_manage_listing(listing_id));


create policy "Members can update auctions"
on "public"."auctions"
as permissive
for update
to authenticated
using (private.can_user_manage_listing(listing_id));


create policy "Members can delete dutch auctions"
on "public"."dutch_auctions"
as permissive
for delete
to authenticated
using (private.can_user_manage_listing(listing_id));


create policy "Members can update dutch auctions"
on "public"."dutch_auctions"
as permissive
for update
to authenticated
using (private.can_user_manage_listing(listing_id));


create policy "Members can delete listings"
on "public"."listings"
as permissive
for delete
to authenticated
using (private.is_user_account_member(( SELECT auth.email() AS email), account_id));


create policy "Members can update listings"
on "public"."listings"
as permissive
for update
to authenticated
using (private.is_user_account_member(( SELECT auth.email() AS email), account_id));


create policy "Members can delete sales"
on "public"."sales"
as permissive
for delete
to authenticated
using (private.can_user_manage_listing(listing_id));


create policy "Members can update sales"
on "public"."sales"
as permissive
for update
to authenticated
using (private.can_user_manage_listing(listing_id));


create policy "Admins can update account"
on "public"."accounts"
as permissive
for update
to authenticated
using (private.is_user_account_admin(( SELECT auth.email() AS email), id));


create policy "Account members can view addresses"
on "public"."accounts_addresses"
as permissive
for select
to authenticated
using (private.is_user_account_member(( SELECT auth.email() AS email), account_id));


create policy "Account members can view users in their account"
on "public"."accounts_users_association"
as permissive
for select
to authenticated
using (private.is_user_account_member(( SELECT auth.email() AS email), account_id));



