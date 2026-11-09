# Play2Win — Supabase database snapshot

Exported from the live Supabase project on 2026-11-10. Tiger vs Dragon is intentionally absent because it was rolled back.

## Files

| File | Contents |
|---|---|
| `schema.sql` | 15 public tables, 7 sequences, constraints, indexes, RLS flags, required extensions, API function grants |
| `current_functions_snapshot.sql` | Current public PostgreSQL function definitions |
| `database.types.ts` | Generated Supabase TypeScript database types |

## Important restore notes

- This is a **schema/code backup**, not a full point-in-time database backup.
- No user rows or private values are included: no passwords, session tokens, wallet balances, transaction history, UPI details, OAuth identities, API keys, or secrets.
- The current public schema has RLS enabled on its tables, but the live database currently reports **0 policies** in `public`. The SQL snapshot preserves that state; do not assume direct client table access is configured.
- No user-defined public triggers or public views were found at export time.
- `google_wallet_links` references Supabase-managed `auth.users`; restore into a Supabase project with Auth enabled.
- The function snapshot contains function bodies but depends on the tables and extensions in `schema.sql`.
- Supabase-managed schemas/services (such as `auth`, `storage`, `vault`, platform roles, secrets, OAuth provider configuration, Edge Function secrets, scheduled jobs, and project settings) are not recreated by these files.
- The tracked migration history currently contains the Tiger vs Dragon rollback migration only. Earlier changes were applied outside tracked migrations, so this snapshot reflects the current live state rather than a complete historical migration chain.

## Restore order

1. Create a new Supabase project and enable/configure Auth as required.
2. Review and run `schema.sql` in the SQL Editor.
3. Review and run `current_functions_snapshot.sql`.
4. Configure Auth providers, redirect URLs, secrets, Storage buckets/policies, and any external payment settings separately.
5. Test on staging before using production.

Never commit service-role keys, database passwords, session tokens, or other secrets to GitHub.
