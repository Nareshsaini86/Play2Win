# Play2Win

Play2Win is a browser-based game and wallet application built as a single-page HTML app, with Supabase used for authentication and backend data operations.

> **Important:** This repository documents the current application and database snapshot. A successful GitHub commit does not by itself mean that the website is deployed or that every feature has been tested in production. Verify the deployment and backend configuration before accepting real users or payments.

## Contents

- [Application overview](#application-overview)
- [Current application features](#current-application-features)
- [Technology stack](#technology-stack)
- [Repository structure](#repository-structure)
- [Supabase project configuration](#supabase-project-configuration)
- [Google OAuth setup](#google-oauth-setup)
- [Google login flow in this application](#google-login-flow-in-this-application)
- [Local development](#local-development)
- [GitHub Pages deployment](#github-pages-deployment)
- [Database backup and restore](#database-backup-and-restore)
- [Security checklist](#security-checklist)
- [Troubleshooting Google login](#troubleshooting-google-login)

## Application overview

The current frontend is served from `index.html`. It loads Supabase JavaScript v2 from a CDN and connects to the Supabase project configured in the page:

- Supabase project URL: `https://tcirnuhynvtwbprbogqp.supabase.co`
- Frontend Supabase key: the project's public anon/publishable key, configured in `index.html`

The frontend uses a custom application token for existing app operations. Google authentication is handled by Supabase Auth; after Google sign-in, the frontend calls the `google_wallet_login` RPC to exchange the Supabase session for the application's custom login token.

Never put a Supabase service-role key, database password, Google OAuth client secret, or other private credential in `index.html` or any other browser-delivered file.

## Current application features

The current `index.html` contains UI and client-side flows for:

- User login with the application's User ID and password.
- Continue with Google sign-in.
- Number Game: round timer, number selection, amount and multiplier selection, bet placement, current bets, results and personal history.
- Gold Ball game: start a round, choose a cup, view game messages and round history.
- Daily rewards / check-in UI.
- User profile and wallet balance.
- Add coins through the configured UPI payment instructions / QR flow, submit a UTR/reference number, and view deposit requests.
- Withdraw coins using a saved UPI ID and view withdrawal requests.
- Transaction / coin history and password change.
- Admin UI for user and transaction views, deposit and withdrawal request handling, payment UPI configuration, and related controls.

Feature visibility and successful operation depend on the deployed frontend and the matching Supabase schema, functions, permissions, and project settings. The presence of a screen in the HTML is not proof that its backend flow has been production-tested.

## Technology stack

- HTML, CSS and vanilla JavaScript.
- Supabase JavaScript client v2.
- Supabase Auth for Google OAuth.
- Supabase PostgreSQL tables and RPC functions for application operations.
- QRCode.js for rendering UPI QR codes.

## Repository structure

```text
Play2Win/
├── index.html
├── README.md
└── supabase/
    ├── README.md
    ├── schema.sql
    ├── current_functions_snapshot.sql
    ├── full_database_schema.sql
    └── database.types.ts
```

### Important files

| File | Purpose |
|---|---|
| `index.html` | Main single-page application and frontend configuration |
| `supabase/full_database_schema.sql` | Combined public-schema and function snapshot |
| `supabase/schema.sql` | Public tables, sequences, constraints, indexes, RLS state and grants |
| `supabase/current_functions_snapshot.sql` | Snapshot of public PostgreSQL functions |
| `supabase/database.types.ts` | Generated TypeScript database types |
| `supabase/README.md` | Database snapshot scope, limitations and restore notes |

## Supabase project configuration

The current frontend is configured for this Supabase project:

```text
https://tcirnuhynvtwbprbogqp.supabase.co
```

In the Supabase Dashboard:

1. Open the project.
2. Go to **Project Settings → API** to confirm the Project URL and public anon/publishable key.
3. Confirm that the frontend's URL and public key match this project.
4. Go to **Authentication → URL Configuration** and configure the production Site URL and allowed Redirect URLs.
5. Go to **Authentication → Sign In / Providers** and configure Google if Google login is required.
6. Confirm the database functions and tables expected by the frontend exist before testing the application.

The public anon/publishable key is intended for browser use when Row Level Security and policies are correctly configured. It is not a substitute for database security. Do not expose a service-role key.

## Google OAuth setup

Google login requires configuration in both Google Cloud and Supabase. The Google OAuth client secret must be stored in Supabase's Google provider settings, not in frontend code.

### Step 1 — Create a Google Cloud project

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project, for example `Play2Win`.
3. Open **Google Auth Platform → Branding** and configure the app name, support email and developer contact details.
4. Configure the Audience / publishing status as appropriate. While the app is in Testing mode, add the Google accounts that are allowed to test it.
5. Open **Google Auth Platform → Clients → Create Client**.
6. Choose **Web application** and give it a name such as `Play2Win Web Client`.

### Step 2 — Configure authorized origins and callback

Under **Authorized JavaScript origins**, add the origins from which the app will actually be opened. Examples:

```text
https://nareshsaini86.github.io
http://localhost:5500
```

Use your real production domain if it is different. An origin contains the scheme, host and optional port; it does not contain a page path.

Under **Authorized redirect URIs**, add this exact Supabase callback URL:

```text
https://tcirnuhynvtwbprbogqp.supabase.co/auth/v1/callback
```

This is the Google-to-Supabase callback. It is not the same as the final website redirect URL.

Create the OAuth client and copy its **Client ID** and **Client Secret**. Keep the secret private.

Google documentation: [Set up OAuth 2.0](https://developers.google.com/identity/protocols/oauth2).

### Step 3 — Enable Google in Supabase

1. Open [Supabase Authentication Providers](https://supabase.com/dashboard/project/tcirnuhynvtwbprbogqp/auth/providers).
2. Open the **Google** provider.
3. Enable Google sign-in.
4. Paste the Google OAuth **Client ID**.
5. Paste the Google OAuth **Client Secret**.
6. Save the provider settings.

### Step 4 — Configure Supabase URL settings

Open [Supabase URL Configuration](https://supabase.com/dashboard/project/tcirnuhynvtwbprbogqp/auth/url-configuration).

Set **Site URL** to the actual production home URL. For the GitHub Pages workflow, the expected URL is:

```text
https://nareshsaini86.github.io/Play2Win/
```

Use that value only if GitHub Pages is enabled and the site is actually being served at that address.

Add the production URL and local development URL to **Redirect URLs**, for example:

```text
https://nareshsaini86.github.io/Play2Win/
https://nareshsaini86.github.io/Play2Win/**
http://localhost:5500/**
```

Add your real custom domain and its required paths if you use one. Save the settings.

### Step 5 — Test Google login

1. Open the deployed app over HTTPS.
2. Click **Continue with Google**.
3. Select an allowed Google account and approve the consent screen.
4. Google should return to the Supabase callback, and Supabase should then redirect to the configured application URL.
5. The frontend should detect the Supabase session and call the `google_wallet_login` RPC.
6. Confirm the app receives its custom token and loads the user's account.

## Google login flow in this application

The current frontend already contains a Google sign-in button and calls Supabase Auth using the Google provider. Its redirect target is generated from the current page URL:

```javascript
supa.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: location.origin + location.pathname
  }
});
```

After the redirect, the page calls `supa.auth.getSession()` and then posts to:

```text
POST https://tcirnuhynvtwbprbogqp.supabase.co/rest/v1/rpc/google_wallet_login
```

The request uses the Supabase session access token as a Bearer token and the project's public anon key as the `apikey` header. The RPC is expected to return the app's custom token and account details used by the existing application.

**Backend prerequisite:** verify that `google_wallet_login` exists in the target Supabase project, validates the authenticated Supabase user, safely maps that identity to an application account, and returns only the intended account fields. Do not trust a user ID, email, role, balance or account mapping supplied by the browser. Do not create a second wallet for an already-linked identity.

Google sign-in will not work end-to-end merely by adding a Google Client ID. The Supabase provider, callback URL, allowed redirect URL and backend RPC must all be configured correctly.

## Local development

You can serve the static page with a local web server. For example, with Python installed:

```bash
python -m http.server 5500
```

Then open:

```text
http://localhost:5500/
```

Add `http://localhost:5500` to Google Cloud's Authorized JavaScript origins and add `http://localhost:5500/**` to Supabase's Redirect URLs. Do not use a different port unless you also update both configurations.

## GitHub Pages deployment

The repository includes a GitHub Pages workflow under `.github/workflows/` (if present on the selected branch).

To configure GitHub Pages:

1. Open the repository on GitHub.
2. Go to **Settings → Pages**.
3. Under **Build and deployment**, select **GitHub Actions** as the source if the workflow is intended to deploy the site.
4. Check the **Actions** tab and confirm the latest Pages workflow completed successfully.
5. Open the published URL and test the app over HTTPS.
6. Add the final published origin to Google Cloud and the full page URL to Supabase Redirect URLs.

Expected project Pages URL:

```text
https://nareshsaini86.github.io/Play2Win/
```

This is the expected URL based on the repository name and owner; confirm it in GitHub Pages before using it in production OAuth settings.

## Database backup and restore

The database snapshot is maintained separately in the `supabase/` folder.

Start with [supabase/README.md](./supabase/README.md). It explains what the snapshot contains, its limitations and the suggested restore order.

Quick links:

- [Combined database schema](./supabase/full_database_schema.sql)
- [Schema DDL](./supabase/schema.sql)
- [PostgreSQL function snapshot](./supabase/current_functions_snapshot.sql)
- [Supabase TypeScript types](./supabase/database.types.ts)

**The SQL snapshot is not a full data backup.** It does not contain user rows, passwords, sessions, wallet balances, coin transactions, UPI/payment records, Supabase Auth users, Storage objects, project secrets or provider settings. Restore to a separate staging Supabase project first, review the SQL, configure Auth and other project settings separately, and test all flows before production use.

## Security checklist

Before using this application with real users or balances:

- [ ] Review and create appropriate Row Level Security (RLS) policies for every exposed table.
- [ ] Review all RPC functions, especially `SECURITY DEFINER` functions, their ownership, search paths and execute grants.
- [ ] Ensure user-facing RPCs derive the user identity from a verified token/session, not a browser-supplied user ID.
- [ ] Ensure only authorized administrators can approve deposits, approve withdrawals, change payment settings or manage users.
- [ ] Keep Google Client Secret, database credentials and Supabase service-role key on trusted server-side systems only.
- [ ] Do not treat frontend copy-protection, hidden buttons or JavaScript checks as security controls.
- [ ] Validate all amounts, balances, transaction states and game outcomes in trusted database/server-side logic.
- [ ] Use idempotent transaction handling to prevent duplicate credits or withdrawals.
- [ ] Review payment-provider verification before crediting a wallet. A submitted UTR or screenshot alone is not proof of payment.
- [ ] Enable leaked-password protection and review Supabase Security Advisor findings.
- [ ] Use HTTPS in production and restrict OAuth redirect URLs to domains you control.
- [ ] Take secure database backups and test restore procedures.

The current database snapshot notes that public tables have RLS enabled but no public RLS policies were present at export time. Treat this as a security issue to review before exposing database access to users.

## Troubleshooting Google login

| Symptom | What to check |
|---|---|
| `redirect_uri_mismatch` | Google Cloud Authorized redirect URI must exactly equal the Supabase callback URL shown above. |
| Google sign-in opens but does not return to the app | Check Supabase Site URL and Redirect URLs, including scheme, domain, path and port. |
| App says Google provider is disabled | Enable the Google provider and save the Client ID and Client Secret in Supabase. |
| App returns to the page but does not log in | Check browser console/network logs, Supabase Auth session and the `google_wallet_login` RPC. |
| RPC returns 404 / function not found | Verify that `google_wallet_login` exists in the correct Supabase project and has the expected signature. |
| RPC returns 401 / 403 | Check the Supabase session token, function execute grants and backend authorization. |
| Works locally but not on the deployed site | Add the deployed origin in Google Cloud and the deployed page URL in Supabase Redirect URLs. |
| Test user cannot sign in | Check Google OAuth Audience / Testing mode and the configured test-user list. |

## Operational notes

- Keep the database snapshot and application code in sync when database functions or tables change.
- Never commit user data, access tokens, payment credentials, OAuth client secrets or service-role keys.
- Treat the README's example production URL as a deployment target until GitHub Pages confirms it is live.
- Test login, wallet, deposit, withdrawal, game and admin flows in a non-production environment after changes.
