-------------------- RLS --------------------
create policy "Users can select presence channels"
on realtime.messages
for select
to public, authenticated
using (
  realtime.messages.extension = 'presence'
);

create policy "Users can update presence channels"
on realtime.messages
for insert
to public, authenticated
with check (
  realtime.messages.extension = 'presence'
);

create policy "Users can listen to apps specific broadcasts"
on realtime.messages
for select
to public, authenticated
using (
  (select realtime.topic()) ~ '^topic:apps'
);

create policy "Users can listen to transactions specific broadcasts"
on realtime.messages
for select
to public, authenticated
using (
  (select realtime.topic()) ~ '^topic:transactions'
);

-------------------- FUNCTIONS --------------------
create or replace function public.apps_changes()
returns trigger
security definer
language plpgsql
set search_path = ''
as $$
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
$$;

create trigger handle_apps_changes
after insert or update or delete
on public.apps
for each row
execute function public.apps_changes();

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

create trigger handle_transactions_changes
after insert or update or delete
on public.transactions
for each row
execute function public.transactions_changes();