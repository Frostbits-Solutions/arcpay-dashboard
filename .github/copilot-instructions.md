Add # ArcPay Dashboard - Copilot Instructions

## Maintaining These Instructions

**IMPORTANT:** After completing any request, review and update this file to reflect:
- **User corrections** - If the user says something is incorrect, update immediately and note the correction
- **Project changes** - New features, architectural shifts, dependency changes, command updates
- **Clarifications** - Additional context or conventions discovered during the session

Keep instructions accurate and current. Future sessions rely on this file for project understanding.

## Project Overview

ArcPay Dashboard is a Turbo monorepo for managing NFT/RWA listings and transactions on Algorand-based networks. The project consists of two Vue 3 applications and shared packages.

### Applications

- **apps/dashboard** - Admin dashboard for managing listings, accounts, transactions, and API keys
- **apps/client** - Embeddable client widget for creating and purchasing listings (supports wallet integration)

### Shared Packages

- **@repo/ui** - Radix Vue components (buttons, tables, forms, charts, etc.)
- **@repo/shared** - Shared utilities (cn, date formatting, decimal conversions)
- **@repo/supabase** - Supabase client, database types, and models
- **@repo/networks** - Algorand network configurations (mainnet, testnet, voi)

## Build, Test, and Lint Commands

### Root Level (Turbo)
```bash
npm run dev              # Start all apps in dev mode
npm run build            # Build all apps and packages
npm run lint             # Lint all workspaces
npm run type-check       # Type check all workspaces
npm run gen-types        # Generate Supabase types from remote schema
```

### Individual App Commands
```bash
# In apps/dashboard or apps/client
npm run dev              # Start Vite dev server
npm run build            # Type check + production build
npm run test:unit        # Run Vitest tests
npm run lint             # ESLint with auto-fix
npm run format           # Prettier format
npm run type-check       # Vue-tsc type checking
```

### Running Single Tests
```bash
# In apps/dashboard or apps/client
npx vitest run <test-file-path>     # Run specific test file
npx vitest <pattern>                 # Run tests matching pattern
```

## Architecture

### Feature-Based Organization

Both apps use a feature-based structure under `src/features/`:

**Dashboard features:** `accounts`, `app`, `auth`, `currencies`, `dashboard`, `listings`, `networks`, `transactions`

**Client features:** `app`, `create`, `review`, `wallet`

Each feature contains:
- `components/` - Vue components specific to that feature
- `views/` - Top-level route components
- `stores/` - Pinia stores (if needed)
- `services/` - API service functions (dashboard only)

### Services Layer

Dashboard uses service functions (in `src/services/`) that wrap Supabase queries:
- Each service file corresponds to a database table/domain (accounts, listings, transactions)
- All functions return `{ data, error }` structure from Supabase
- Type definitions come from `@repo/supabase/models`

Example pattern:
```typescript
import { supabase } from '@repo/supabase/client'
import type { Listing } from '@repo/supabase/models'

export async function getListings(accountId: string) {
  const { data, error } = await supabase
    .from('listings')
    .select('*')
    .eq('account_id', accountId)
  return { data, error }
}
```

### Client Widget Architecture

The client app exports an `ArcpayClient` class that:
- Manages wallet connections via `@txnlab/use-wallet`
- Handles Algorand smart contract interactions (create, buy, close, cancel)
- Provides modal-based UI for listing creation and purchase flows
- Can be embedded in external applications

### Supabase Integration

- Database types are generated from Supabase schema: `packages/supabase/src/database.types.ts`
- Models in `packages/supabase/src/models.ts` extend database types with business logic types
- Use `npm run gen-types` to regenerate types after schema changes
- Supabase client is configured in `packages/supabase/src/client.ts`

### Routing

Both apps use Vue Router with:
- Nested routes for organization/account settings
- Auth guards checking session state
- Lazy-loaded components for code splitting

Dashboard route pattern:
```
/auth                    → AuthView
/                        → AuthenticatedView (requires auth)
  /dashboard             → DashboardView
  /listings              → ListingsView
  /organization/:name/settings → AccountSettingsView
    /                    → OrganizationSettingsGeneral
    /users               → OrganizationSettingsUsers
```

## Key Conventions

### Environment Variables

Both apps require environment variables (set in `.env.development.local` or `.env.production.local`):
- `VITE_SUPABASE_URL` - Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Supabase anonymous key
- `VITE_ARCPAY_API_KEY` - ArcPay API key (for client app)

Never commit `.env*.local` files.

### Decimal Handling

Use shared utilities for asset amounts:
```typescript
import { formatAmountToDecimals, formatAmountFromDecimals } from '@repo/shared'

// Convert to blockchain format (multiply by 10^decimals)
const microAmount = formatAmountToDecimals(1.5, 6) // 1500000

// Convert from blockchain format (divide by 10^decimals)  
const humanAmount = formatAmountFromDecimals(1500000, 6) // 1.5
```

### Styling

- Both apps use Tailwind CSS
- Use `cn()` utility from `@repo/shared` for conditional classes
- UI components from `@repo/ui` follow Radix Vue patterns
- Dashboard uses custom chart components from `@repo/ui/chart-*`

### Type Safety

- Always import types from `@repo/supabase/models` for database entities
- Use `Database` from `database.types.ts` for raw table types
- Services return `{ data: T | null, error: PostgrestError | null }`
- Client-side wallet types come from `@txnlab/use-wallet`

### Network Configuration

Network settings are in `@repo/networks`:
- `algo.ts` - Algorand mainnet/testnet configuration
- `voi.ts` - Voi network configuration
- `types.ts` - Shared network types

Client app supports multiple networks via `networksConfig`.

## Supabase Schema

Key tables:
- `accounts` - Organizations/teams
- `accounts_users_association` - User-account memberships with roles
- `accounts_addresses` - Blockchain addresses per account
- `accounts_secrets` - API keys (hashed)
- `listings` - NFT/RWA listings (sale/auction/dutch auction)
- `transactions` - Transaction history
- `currencies` - Supported currencies per network
- `networks` - Supported blockchain networks

Use RPC functions for complex operations (e.g., `create_account`).

## Development Notes

### Turbo Caching

Turbo caches build outputs. Clear cache if builds behave unexpectedly:
```bash
npx turbo run build --force
```

### Supabase Local Development

Supabase configuration is in `supabase/config.toml`. Migrations are in `supabase/migrations/`.

To work with local Supabase:
```bash
npx supabase start       # Start local Supabase
npx supabase db reset    # Reset and apply migrations
npx supabase stop        # Stop local instance
```

### Wallet Testing

Client app integrates multiple Algorand wallets:
- Pera Wallet
- Defly
- Lute Connect
- AVM Web Provider

Test wallet flows in testnet/voi testnet before mainnet deployment.
