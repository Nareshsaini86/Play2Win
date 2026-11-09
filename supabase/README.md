# Play2Win — Full Supabase database schema backup

Snapshot exported from the connected Supabase project on 2026-11-10.

## Main restore file

**[full_database_schema.sql](./full_database_schema.sql)** — one combined SQL file containing the current public schema DDL and all 44 current public PostgreSQL function definitions.

## Split files

- [schema.sql](./schema.sql) — public tables, sequences, constraints, indexes, RLS flags, required extensions, table grants and function execute grants.
- [current_functions_snapshot.sql](./current_functions_snapshot.sql) — public PostgreSQL function definitions.
- [database.types.ts](./database.types.ts) — generated Supabase TypeScript types.

## Snapshot scope and limitations

- Covers the current `public` application schema: 15 tables, sequences, constraints, indexes, RLS enabled state, grants, and 44 functions.
- There are currently **0 RLS policies** in `public`; this snapshot records that current state. Supabase security advisor also reports RLS-enabled tables with no policies.
- No public user-defined triggers or views were found at export time.
- Does not contain table rows or private data: user passwords, sessions, wallet balances, coin transactions, UPI/payment details, or user identities.
- Does not recreate Supabase-managed `auth`, `storage`, platform roles, Auth provider settings, project secrets, Storage objects/policies, external payment gateway configuration, or project-level settings.
- `google_wallet_links` references Supabase-managed `auth.users`; use a Supabase project with Auth enabled.
- Installed platform extensions and roles can vary by project. Review extension availability and grants before restore.
- This is a schema/code snapshot, not a complete point-in-time backup. For complete recovery, also create a Supabase database backup/PITR backup and securely export required data.

## Restore order

1. Create a new Supabase project with Auth enabled.
2. Review `full_database_schema.sql` carefully and execute it on staging first.
3. Configure Auth providers, redirect URLs, Storage buckets and policies, secrets, payment integrations, and other project settings separately.
4. Import application data only through a secure, controlled backup/restore process.
5. Test login, wallet, deposits, withdrawals, games, and admin operations before production use.

Never commit service-role keys, database passwords, user data, session tokens, or payment secrets to GitHub.
