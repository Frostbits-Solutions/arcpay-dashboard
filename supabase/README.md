# Supabase

### Run local Dev instance

```
supabase start
```

### Declarative database shcema

1. Declare / update schema in `supabase/schemas/`
2. Generate migration file:

```
supabase db diff -f <migration name>
```

3. Apply migration:

```
supabase migration up
```

4. Push changes to remote:

```
supabase db push
```

Reference: [Declarative database schemas - Supabase docs]("https://supabase.com/docs/guides/local-development/declarative-database-schemas")

### Typescript types

Generate types from database schema:

From local:

```
supabase gen types typescript --local > app/src/lib/supabase/database.types.ts
```

From remote:

```
supabase gen types typescript --project-id <project id> > app/src/lib/supabase/database.types.ts
```

Reference: [Generating TypeScript Types - Supabase docs]("https://supabase.com/docs/guides/api/rest/generating-types")
