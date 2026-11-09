# Play2Win — Supabase SQL

This folder contains a snapshot of the active PostgreSQL functions currently present in the connected Supabase project.

## Files

- `current_functions_snapshot.sql` — 44 current functions in the `public` schema, exported on 2026-11-10.
- Tiger vs Dragon is intentionally excluded because that feature was rolled back and its table/functions were removed.

## Important: this is not a full database bootstrap

The snapshot contains function definitions only. It does **not** contain the complete table definitions, indexes, triggers, RLS policies, grants, extensions, storage configuration, or project secrets needed to recreate the full production database from an empty project.

Do not run the snapshot blindly against production. Several functions depend on existing tables and other functions. Review and test it on a staging Supabase project first.

## Current migration history

The connected Supabase project reports this tracked migration:

- `20261109183345_rollback_tiger_dragon_game`

Earlier SQL changes were applied outside the tracked migration history, so they cannot honestly be represented here as a complete ordered migration chain. The function snapshot is exported from the current live database state instead.

## Recommended next step

For a proper deployable setup, create versioned migrations for every table, index, policy, trigger, and function, then test the full migration sequence on a fresh staging project before production deployment.

Never commit Supabase service-role keys, database passwords, access tokens, or other secrets to this repository.
