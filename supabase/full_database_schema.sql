-- PLAY2WIN FULL PUBLIC DATABASE SCHEMA SNAPSHOT
-- Exported from Supabase project tcirnuhynvtwbprbogqp on 2026-11-10.
-- Contains schema DDL and current public function definitions.
-- Does NOT contain application data, user credentials, session tokens, wallet balances,
-- UPI/payment identifiers, Auth user records, Storage objects, project secrets or API keys.
-- Restore only into a fresh/staging Supabase project first; review before production use.
-- RLS is enabled on 15 public tables and currently there are 0 public RLS policies.

-- Play2Win public schema snapshot
-- Exported 2026-11-10 from Supabase project tcirnuhynvtwbprbogqp
-- Schema-only: NO user rows, passwords, session tokens, payment identifiers, or secrets are included.
-- Requires a Supabase project: google_wallet_links references managed auth.users.
-- Review extensions and role grants on the target project before execution.

SET search_path = public, extensions;

-- Installed extensions required/observed in the project
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA pg_catalog;

-- Sequences
CREATE SEQUENCE IF NOT EXISTS public.bets_id_seq;

CREATE SEQUENCE IF NOT EXISTS public.coin_deposit_requests_id_seq;

CREATE SEQUENCE IF NOT EXISTS public.coin_log_id_seq;

CREATE SEQUENCE IF NOT EXISTS public.gold_game_ledger_id_seq;

CREATE SEQUENCE IF NOT EXISTS public.gold_game_rounds_id_seq;

CREATE SEQUENCE IF NOT EXISTS public.payment_receiving_upis_id_seq;

CREATE SEQUENCE IF NOT EXISTS public.withdrawal_requests_id_seq;

-- Tables
CREATE TABLE IF NOT EXISTS public.app_users (id text NOT NULL,
  pw text NOT NULL,
  role text NOT NULL DEFAULT 'user'::text,
  balance bigint NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  phone text,
  display_name text,
  email text);

CREATE TABLE IF NOT EXISTS public.bets (id bigint NOT NULL DEFAULT nextval('bets_id_seq'::regclass),
  user_id text NOT NULL,
  round bigint NOT NULL,
  target text NOT NULL,
  amount bigint NOT NULL,
  payout bigint NOT NULL DEFAULT 0,
  settled boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.coin_deposit_requests (id bigint NOT NULL DEFAULT nextval('coin_deposit_requests_id_seq'::regclass),
  user_id text NOT NULL,
  amount bigint NOT NULL,
  utr text NOT NULL,
  payment_reference text,
  status text NOT NULL DEFAULT 'pending'::text,
  reviewed_by text,
  reviewed_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.coin_log (id bigint NOT NULL DEFAULT nextval('coin_log_id_seq'::regclass),
  user_id text NOT NULL,
  amount bigint NOT NULL,
  by_admin text,
  created_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.daily_checkins (user_id text NOT NULL,
  last_claim_date date NOT NULL,
  streak_day integer NOT NULL,
  updated_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.gold_game_ledger (id bigint NOT NULL DEFAULT nextval('gold_game_ledger_id_seq'::regclass),
  user_id text NOT NULL,
  round_id bigint,
  amount bigint NOT NULL,
  entry_type text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.gold_game_rounds (id bigint NOT NULL DEFAULT nextval('gold_game_rounds_id_seq'::regclass),
  user_id text NOT NULL,
  stake bigint NOT NULL,
  entry_amount bigint NOT NULL,
  multiplier integer NOT NULL,
  winning_cup smallint NOT NULL,
  selected_cup smallint,
  won boolean,
  payout bigint NOT NULL DEFAULT 0,
  settled boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  settled_at timestamp with time zone);

CREATE TABLE IF NOT EXISTS public.gold_game_wallets (user_id text NOT NULL,
  credits bigint NOT NULL DEFAULT 1000,
  updated_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.google_wallet_links (auth_user_id uuid NOT NULL,
  user_id text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.login_attempts (login_key text NOT NULL,
  attempts integer NOT NULL DEFAULT 0,
  window_started timestamp with time zone NOT NULL DEFAULT now(),
  locked_until timestamp with time zone);

CREATE TABLE IF NOT EXISTS public.payment_receiving_upis (id bigint NOT NULL DEFAULT nextval('payment_receiving_upis_id_seq'::regclass),
  upi_id text NOT NULL,
  payee_name text NOT NULL DEFAULT 'Play2Win'::text,
  is_active boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.results (round bigint NOT NULL,
  num integer NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.sessions (token text NOT NULL,
  user_id text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  expires_at timestamp with time zone NOT NULL,
  last_seen_at timestamp with time zone);

CREATE TABLE IF NOT EXISTS public.user_withdrawal_upi (user_id text NOT NULL,
  upi_id text NOT NULL,
  updated_at timestamp with time zone NOT NULL DEFAULT now());

CREATE TABLE IF NOT EXISTS public.withdrawal_requests (id bigint NOT NULL DEFAULT nextval('withdrawal_requests_id_seq'::regclass),
  user_id text NOT NULL,
  upi_id text NOT NULL,
  amount bigint NOT NULL,
  status text NOT NULL DEFAULT 'pending'::text,
  reviewed_by text,
  reviewed_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now());

-- Attach serial sequences after their owning tables exist
ALTER SEQUENCE public.bets_id_seq OWNED BY public.bets.id;
ALTER SEQUENCE public.coin_deposit_requests_id_seq OWNED BY public.coin_deposit_requests.id;
ALTER SEQUENCE public.coin_log_id_seq OWNED BY public.coin_log.id;
ALTER SEQUENCE public.gold_game_ledger_id_seq OWNED BY public.gold_game_ledger.id;
ALTER SEQUENCE public.gold_game_rounds_id_seq OWNED BY public.gold_game_rounds.id;
ALTER SEQUENCE public.payment_receiving_upis_id_seq OWNED BY public.payment_receiving_upis.id;
ALTER SEQUENCE public.withdrawal_requests_id_seq OWNED BY public.withdrawal_requests.id;

-- Constraints
ALTER TABLE public.app_users ADD CONSTRAINT app_users_balance_check CHECK ((balance >= 0));
ALTER TABLE public.app_users ADD CONSTRAINT app_users_id_check CHECK ((id ~ '^[A-Za-z0-9_.-]{3,20}$'::text));
ALTER TABLE public.app_users ADD CONSTRAINT app_users_pkey PRIMARY KEY (id);
ALTER TABLE public.app_users ADD CONSTRAINT app_users_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'user'::text])));
ALTER TABLE public.bets ADD CONSTRAINT bets_amount_check CHECK ((amount > 0));
ALTER TABLE public.bets ADD CONSTRAINT bets_pkey PRIMARY KEY (id);
ALTER TABLE public.bets ADD CONSTRAINT bets_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.coin_deposit_requests ADD CONSTRAINT coin_deposit_requests_amount_check CHECK (((amount >= 10) AND (amount <= 50000)));
ALTER TABLE public.coin_deposit_requests ADD CONSTRAINT coin_deposit_requests_pkey PRIMARY KEY (id);
ALTER TABLE public.coin_deposit_requests ADD CONSTRAINT coin_deposit_requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES app_users(id);
ALTER TABLE public.coin_deposit_requests ADD CONSTRAINT coin_deposit_requests_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])));
ALTER TABLE public.coin_deposit_requests ADD CONSTRAINT coin_deposit_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.coin_deposit_requests ADD CONSTRAINT coin_deposit_requests_utr_check CHECK ((utr ~ '^[0-9]{12}$'::text));
ALTER TABLE public.coin_deposit_requests ADD CONSTRAINT coin_deposit_requests_utr_key UNIQUE (utr);
ALTER TABLE public.coin_log ADD CONSTRAINT coin_log_pkey PRIMARY KEY (id);
ALTER TABLE public.coin_log ADD CONSTRAINT coin_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.daily_checkins ADD CONSTRAINT daily_checkins_pkey PRIMARY KEY (user_id);
ALTER TABLE public.daily_checkins ADD CONSTRAINT daily_checkins_streak_day_check CHECK (((streak_day >= 1) AND (streak_day <= 5)));
ALTER TABLE public.daily_checkins ADD CONSTRAINT daily_checkins_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.gold_game_ledger ADD CONSTRAINT gold_game_ledger_entry_type_check CHECK ((entry_type = ANY (ARRAY['round_entry'::text, 'round_win'::text, 'admin_grant'::text])));
ALTER TABLE public.gold_game_ledger ADD CONSTRAINT gold_game_ledger_pkey PRIMARY KEY (id);
ALTER TABLE public.gold_game_ledger ADD CONSTRAINT gold_game_ledger_round_id_fkey FOREIGN KEY (round_id) REFERENCES gold_game_rounds(id) ON DELETE SET NULL;
ALTER TABLE public.gold_game_ledger ADD CONSTRAINT gold_game_ledger_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_entry_amount_check CHECK ((entry_amount > 0));
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_multiplier_check CHECK ((multiplier = ANY (ARRAY[1, 5, 10])));
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_payout_check CHECK ((payout >= 0));
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_pkey PRIMARY KEY (id);
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_selected_cup_check CHECK (((selected_cup >= 0) AND (selected_cup <= 2)));
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_stake_check CHECK ((stake > 0));
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.gold_game_rounds ADD CONSTRAINT gold_game_rounds_winning_cup_check CHECK (((winning_cup >= 0) AND (winning_cup <= 2)));
ALTER TABLE public.gold_game_wallets ADD CONSTRAINT gold_game_wallets_credits_check CHECK ((credits >= 0));
ALTER TABLE public.gold_game_wallets ADD CONSTRAINT gold_game_wallets_pkey PRIMARY KEY (user_id);
ALTER TABLE public.gold_game_wallets ADD CONSTRAINT gold_game_wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.google_wallet_links ADD CONSTRAINT google_wallet_links_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.google_wallet_links ADD CONSTRAINT google_wallet_links_pkey PRIMARY KEY (auth_user_id);
ALTER TABLE public.google_wallet_links ADD CONSTRAINT google_wallet_links_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.google_wallet_links ADD CONSTRAINT google_wallet_links_user_id_key UNIQUE (user_id);
ALTER TABLE public.login_attempts ADD CONSTRAINT login_attempts_attempts_check CHECK ((attempts >= 0));
ALTER TABLE public.login_attempts ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (login_key);
ALTER TABLE public.payment_receiving_upis ADD CONSTRAINT payment_receiving_upis_pkey PRIMARY KEY (id);
ALTER TABLE public.results ADD CONSTRAINT results_num_check CHECK (((num >= 0) AND (num <= 9)));
ALTER TABLE public.results ADD CONSTRAINT results_pkey PRIMARY KEY (round);
ALTER TABLE public.sessions ADD CONSTRAINT sessions_pkey PRIMARY KEY (token);
ALTER TABLE public.sessions ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.user_withdrawal_upi ADD CONSTRAINT user_withdrawal_upi_pkey PRIMARY KEY (user_id);
ALTER TABLE public.user_withdrawal_upi ADD CONSTRAINT user_withdrawal_upi_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
ALTER TABLE public.withdrawal_requests ADD CONSTRAINT withdrawal_requests_amount_check CHECK ((amount >= 100));
ALTER TABLE public.withdrawal_requests ADD CONSTRAINT withdrawal_requests_pkey PRIMARY KEY (id);
ALTER TABLE public.withdrawal_requests ADD CONSTRAINT withdrawal_requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES app_users(id);
ALTER TABLE public.withdrawal_requests ADD CONSTRAINT withdrawal_requests_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'paid'::text, 'rejected'::text])));
ALTER TABLE public.withdrawal_requests ADD CONSTRAINT withdrawal_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;

-- Additional (non-constraint) indexes
CREATE INDEX bets_user_idx ON public.bets USING btree (user_id, id DESC);
CREATE INDEX bets_open_idx ON public.bets USING btree (round) WHERE (NOT settled);
CREATE INDEX coin_deposit_requests_user_idx ON public.coin_deposit_requests USING btree (user_id, created_at DESC);
CREATE INDEX coin_deposit_requests_pending_idx ON public.coin_deposit_requests USING btree (status, created_at DESC);
CREATE INDEX coin_log_user_idx ON public.coin_log USING btree (user_id, id DESC);
CREATE INDEX gold_game_ledger_user_idx ON public.gold_game_ledger USING btree (user_id, id DESC);
CREATE INDEX gold_game_rounds_user_idx ON public.gold_game_rounds USING btree (user_id, id DESC);
CREATE UNIQUE INDEX payment_receiving_upis_lower_unique ON public.payment_receiving_upis USING btree (lower(upi_id));
CREATE UNIQUE INDEX payment_receiving_upis_one_active ON public.payment_receiving_upis USING btree (is_active) WHERE (is_active = true);
CREATE INDEX withdrawal_requests_user_idx ON public.withdrawal_requests USING btree (user_id, created_at DESC);
CREATE INDEX withdrawal_requests_pending_idx ON public.withdrawal_requests USING btree (status, created_at DESC);

-- Row Level Security flags (there are currently 0 policies in public)
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coin_deposit_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coin_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gold_game_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gold_game_rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gold_game_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.google_wallet_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_receiving_upis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_withdrawal_upi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

-- Existing table grants (service_role only; anon/authenticated have no direct table grants)
GRANT DELETE ON TABLE public.app_users TO service_role;
GRANT INSERT ON TABLE public.app_users TO service_role;
GRANT REFERENCES ON TABLE public.app_users TO service_role;
GRANT SELECT ON TABLE public.app_users TO service_role;
GRANT TRIGGER ON TABLE public.app_users TO service_role;
GRANT TRUNCATE ON TABLE public.app_users TO service_role;
GRANT UPDATE ON TABLE public.app_users TO service_role;
GRANT DELETE ON TABLE public.bets TO service_role;
GRANT INSERT ON TABLE public.bets TO service_role;
GRANT REFERENCES ON TABLE public.bets TO service_role;
GRANT SELECT ON TABLE public.bets TO service_role;
GRANT TRIGGER ON TABLE public.bets TO service_role;
GRANT TRUNCATE ON TABLE public.bets TO service_role;
GRANT UPDATE ON TABLE public.bets TO service_role;
GRANT DELETE ON TABLE public.coin_deposit_requests TO service_role;
GRANT INSERT ON TABLE public.coin_deposit_requests TO service_role;
GRANT REFERENCES ON TABLE public.coin_deposit_requests TO service_role;
GRANT SELECT ON TABLE public.coin_deposit_requests TO service_role;
GRANT TRIGGER ON TABLE public.coin_deposit_requests TO service_role;
GRANT TRUNCATE ON TABLE public.coin_deposit_requests TO service_role;
GRANT UPDATE ON TABLE public.coin_deposit_requests TO service_role;
GRANT DELETE ON TABLE public.coin_log TO service_role;
GRANT INSERT ON TABLE public.coin_log TO service_role;
GRANT REFERENCES ON TABLE public.coin_log TO service_role;
GRANT SELECT ON TABLE public.coin_log TO service_role;
GRANT TRIGGER ON TABLE public.coin_log TO service_role;
GRANT TRUNCATE ON TABLE public.coin_log TO service_role;
GRANT UPDATE ON TABLE public.coin_log TO service_role;
GRANT DELETE ON TABLE public.daily_checkins TO service_role;
GRANT INSERT ON TABLE public.daily_checkins TO service_role;
GRANT REFERENCES ON TABLE public.daily_checkins TO service_role;
GRANT SELECT ON TABLE public.daily_checkins TO service_role;
GRANT TRIGGER ON TABLE public.daily_checkins TO service_role;
GRANT TRUNCATE ON TABLE public.daily_checkins TO service_role;
GRANT UPDATE ON TABLE public.daily_checkins TO service_role;
GRANT DELETE ON TABLE public.gold_game_ledger TO service_role;
GRANT INSERT ON TABLE public.gold_game_ledger TO service_role;
GRANT REFERENCES ON TABLE public.gold_game_ledger TO service_role;
GRANT SELECT ON TABLE public.gold_game_ledger TO service_role;
GRANT TRIGGER ON TABLE public.gold_game_ledger TO service_role;
GRANT TRUNCATE ON TABLE public.gold_game_ledger TO service_role;
GRANT UPDATE ON TABLE public.gold_game_ledger TO service_role;
GRANT DELETE ON TABLE public.gold_game_rounds TO service_role;
GRANT INSERT ON TABLE public.gold_game_rounds TO service_role;
GRANT REFERENCES ON TABLE public.gold_game_rounds TO service_role;
GRANT SELECT ON TABLE public.gold_game_rounds TO service_role;
GRANT TRIGGER ON TABLE public.gold_game_rounds TO service_role;
GRANT TRUNCATE ON TABLE public.gold_game_rounds TO service_role;
GRANT UPDATE ON TABLE public.gold_game_rounds TO service_role;
GRANT DELETE ON TABLE public.gold_game_wallets TO service_role;
GRANT INSERT ON TABLE public.gold_game_wallets TO service_role;
GRANT REFERENCES ON TABLE public.gold_game_wallets TO service_role;
GRANT SELECT ON TABLE public.gold_game_wallets TO service_role;
GRANT TRIGGER ON TABLE public.gold_game_wallets TO service_role;
GRANT TRUNCATE ON TABLE public.gold_game_wallets TO service_role;
GRANT UPDATE ON TABLE public.gold_game_wallets TO service_role;
GRANT DELETE ON TABLE public.google_wallet_links TO service_role;
GRANT INSERT ON TABLE public.google_wallet_links TO service_role;
GRANT REFERENCES ON TABLE public.google_wallet_links TO service_role;
GRANT SELECT ON TABLE public.google_wallet_links TO service_role;
GRANT TRIGGER ON TABLE public.google_wallet_links TO service_role;
GRANT TRUNCATE ON TABLE public.google_wallet_links TO service_role;
GRANT UPDATE ON TABLE public.google_wallet_links TO service_role;
GRANT DELETE ON TABLE public.login_attempts TO service_role;
GRANT INSERT ON TABLE public.login_attempts TO service_role;
GRANT REFERENCES ON TABLE public.login_attempts TO service_role;
GRANT SELECT ON TABLE public.login_attempts TO service_role;
GRANT TRIGGER ON TABLE public.login_attempts TO service_role;
GRANT TRUNCATE ON TABLE public.login_attempts TO service_role;
GRANT UPDATE ON TABLE public.login_attempts TO service_role;
GRANT DELETE ON TABLE public.payment_receiving_upis TO service_role;
GRANT INSERT ON TABLE public.payment_receiving_upis TO service_role;
GRANT REFERENCES ON TABLE public.payment_receiving_upis TO service_role;
GRANT SELECT ON TABLE public.payment_receiving_upis TO service_role;
GRANT TRIGGER ON TABLE public.payment_receiving_upis TO service_role;
GRANT TRUNCATE ON TABLE public.payment_receiving_upis TO service_role;
GRANT UPDATE ON TABLE public.payment_receiving_upis TO service_role;
GRANT DELETE ON TABLE public.results TO service_role;
GRANT INSERT ON TABLE public.results TO service_role;
GRANT REFERENCES ON TABLE public.results TO service_role;
GRANT SELECT ON TABLE public.results TO service_role;
GRANT TRIGGER ON TABLE public.results TO service_role;
GRANT TRUNCATE ON TABLE public.results TO service_role;
GRANT UPDATE ON TABLE public.results TO service_role;
GRANT DELETE ON TABLE public.sessions TO service_role;
GRANT INSERT ON TABLE public.sessions TO service_role;
GRANT REFERENCES ON TABLE public.sessions TO service_role;
GRANT SELECT ON TABLE public.sessions TO service_role;
GRANT TRIGGER ON TABLE public.sessions TO service_role;
GRANT TRUNCATE ON TABLE public.sessions TO service_role;
GRANT UPDATE ON TABLE public.sessions TO service_role;
GRANT DELETE ON TABLE public.user_withdrawal_upi TO service_role;
GRANT INSERT ON TABLE public.user_withdrawal_upi TO service_role;
GRANT REFERENCES ON TABLE public.user_withdrawal_upi TO service_role;
GRANT SELECT ON TABLE public.user_withdrawal_upi TO service_role;
GRANT TRIGGER ON TABLE public.user_withdrawal_upi TO service_role;
GRANT TRUNCATE ON TABLE public.user_withdrawal_upi TO service_role;
GRANT UPDATE ON TABLE public.user_withdrawal_upi TO service_role;
GRANT DELETE ON TABLE public.withdrawal_requests TO service_role;
GRANT INSERT ON TABLE public.withdrawal_requests TO service_role;
GRANT REFERENCES ON TABLE public.withdrawal_requests TO service_role;
GRANT SELECT ON TABLE public.withdrawal_requests TO service_role;
GRANT TRIGGER ON TABLE public.withdrawal_requests TO service_role;
GRANT TRUNCATE ON TABLE public.withdrawal_requests TO service_role;
GRANT UPDATE ON TABLE public.withdrawal_requests TO service_role;

-- Function execute grants for API roles
GRANT EXECUTE ON FUNCTION public._admin(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public._cur_round() TO service_role;
GRANT EXECUTE ON FUNCTION public._payout(n integer, t text, a bigint) TO service_role;
GRANT EXECUTE ON FUNCTION public._rand10() TO service_role;
GRANT EXECUTE ON FUNCTION public._settle() TO service_role;
GRANT EXECUTE ON FUNCTION public._uid(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_add_coins(p_token text, p_id text, p_amount bigint) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_add_coins(p_token text, p_id text, p_amount bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_add_coins(p_token text, p_id text, p_amount bigint) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_add_payment_upi(p_token text, p_upi_id text, p_payee_name text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_add_payment_upi(p_token text, p_upi_id text, p_payee_name text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_add_payment_upi(p_token text, p_upi_id text, p_payee_name text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_bets(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_bets(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_bets(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_create_user(p_token text, p_id text, p_pw text, p_phone text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_create_user(p_token text, p_id text, p_pw text, p_phone text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_user(p_token text, p_id text, p_pw text, p_phone text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_delete_payment_upi(p_token text, p_id bigint) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_delete_payment_upi(p_token text, p_id bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_payment_upi(p_token text, p_id bigint) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_delete_user(p_token text, p_id text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_delete_user(p_token text, p_id text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_user(p_token text, p_id text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_grant_gold_credits(p_token text, p_user_id text, p_amount bigint) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_grant_gold_credits(p_token text, p_user_id text, p_amount bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_grant_gold_credits(p_token text, p_user_id text, p_amount bigint) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_list_coin_deposits(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_list_coin_deposits(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_list_coin_deposits(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_list_payment_upis(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_list_payment_upis(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_list_payment_upis(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_list_users(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_list_users(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_list_users(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_list_withdrawal_requests(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_list_withdrawal_requests(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_list_withdrawal_requests(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_review_coin_deposit(p_token text, p_deposit_id bigint, p_status text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_review_coin_deposit(p_token text, p_deposit_id bigint, p_status text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_review_coin_deposit(p_token text, p_deposit_id bigint, p_status text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_review_withdrawal(p_token text, p_request_id bigint, p_status text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_review_withdrawal(p_token text, p_request_id bigint, p_status text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_review_withdrawal(p_token text, p_request_id bigint, p_status text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_set_active_payment_upi(p_token text, p_id bigint) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_set_active_payment_upi(p_token text, p_id bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_active_payment_upi(p_token text, p_id bigint) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_set_password(p_token text, p_id text, p_new text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_set_password(p_token text, p_id text, p_new text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_password(p_token text, p_id text, p_new text) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_set_phone(p_token text, p_id text, p_phone text) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_set_phone(p_token text, p_id text, p_phone text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_phone(p_token text, p_id text, p_phone text) TO service_role;
GRANT EXECUTE ON FUNCTION public.change_password(p_token text, p_old text, p_new text) TO anon;
GRANT EXECUTE ON FUNCTION public.change_password(p_token text, p_old text, p_new text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.change_password(p_token text, p_old text, p_new text) TO service_role;
GRANT EXECUTE ON FUNCTION public.claim_daily_reward(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.claim_daily_reward(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.claim_daily_reward(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.create_withdrawal_request(p_token text, p_amount bigint) TO anon;
GRANT EXECUTE ON FUNCTION public.create_withdrawal_request(p_token text, p_amount bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_withdrawal_request(p_token text, p_amount bigint) TO service_role;
GRANT EXECUTE ON FUNCTION public.daily_reward_status(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.daily_reward_status(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.daily_reward_status(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_active_payment_upi(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_active_payment_upi(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_active_payment_upi(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_my_withdrawal_upi(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_my_withdrawal_upi(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_withdrawal_upi(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_state(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_state(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_state(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.gold_game_state(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.gold_game_state(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.gold_game_state(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.gold_pick_cup(p_token text, p_round_id bigint, p_cup integer) TO anon;
GRANT EXECUTE ON FUNCTION public.gold_pick_cup(p_token text, p_round_id bigint, p_cup integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.gold_pick_cup(p_token text, p_round_id bigint, p_cup integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.gold_start_round(p_token text, p_amount bigint, p_multiplier integer) TO anon;
GRANT EXECUTE ON FUNCTION public.gold_start_round(p_token text, p_amount bigint, p_multiplier integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.gold_start_round(p_token text, p_amount bigint, p_multiplier integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.google_wallet_login() TO authenticated;
GRANT EXECUTE ON FUNCTION public.google_wallet_login() TO service_role;
GRANT EXECUTE ON FUNCTION public.has_admin() TO anon;
GRANT EXECUTE ON FUNCTION public.has_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_admin() TO service_role;
GRANT EXECUTE ON FUNCTION public.login(p_id text, p_pw text) TO anon;
GRANT EXECUTE ON FUNCTION public.login(p_id text, p_pw text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.login(p_id text, p_pw text) TO service_role;
GRANT EXECUTE ON FUNCTION public.logout_session(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.logout_session(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.logout_session(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.my_coin_deposits(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.my_coin_deposits(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.my_coin_deposits(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.my_coin_log(p_token text, p_user text) TO anon;
GRANT EXECUTE ON FUNCTION public.my_coin_log(p_token text, p_user text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.my_coin_log(p_token text, p_user text) TO service_role;
GRANT EXECUTE ON FUNCTION public.my_history(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.my_history(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.my_history(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.my_withdrawal_requests(p_token text) TO anon;
GRANT EXECUTE ON FUNCTION public.my_withdrawal_requests(p_token text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.my_withdrawal_requests(p_token text) TO service_role;
GRANT EXECUTE ON FUNCTION public.place_bet(p_token text, p_target text, p_amount bigint) TO anon;
GRANT EXECUTE ON FUNCTION public.place_bet(p_token text, p_target text, p_amount bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.place_bet(p_token text, p_target text, p_amount bigint) TO service_role;
GRANT EXECUTE ON FUNCTION public.save_withdraw_upi(p_token text, p_upi_id text) TO anon;
GRANT EXECUTE ON FUNCTION public.save_withdraw_upi(p_token text, p_upi_id text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.save_withdraw_upi(p_token text, p_upi_id text) TO service_role;
GRANT EXECUTE ON FUNCTION public.setup_admin(p_id text, p_pw text) TO service_role;
GRANT EXECUTE ON FUNCTION public.submit_coin_deposit(p_token text, p_amount bigint, p_utr text, p_reference text) TO anon;
GRANT EXECUTE ON FUNCTION public.submit_coin_deposit(p_token text, p_amount bigint, p_utr text, p_reference text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.submit_coin_deposit(p_token text, p_amount bigint, p_utr text, p_reference text) TO service_role;


-- ================================================================
-- PUBLIC FUNCTION DEFINITIONS (44 functions)
-- ================================================================

-- Play2Win: current public PostgreSQL function snapshot
-- Generated from Supabase project tcirnuhynvtwbprbogqp on 2026-11-10.
-- IMPORTANT:
-- 1) This file is a snapshot of existing public functions, not a full database backup.
-- 2) It does NOT create the tables, indexes, triggers, RLS policies, grants, or extensions they depend on.
-- 3) Review on a staging database before running. CREATE OR REPLACE FUNCTION may change live behavior.
-- 4) Tiger vs Dragon functions/table are intentionally absent; that feature was rolled back.

CREATE OR REPLACE FUNCTION public._admin(p_token text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare u text := _uid(p_token);
begin
  if not exists (select 1 from app_users where id = u and role = 'admin') then raise exception 'Admin access required.'; end if;
  return u;
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public._cur_round()
 RETURNS bigint
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'extensions'
AS $function$ select floor(extract(epoch from now())/35)::bigint $function$


-- ========================================

CREATE OR REPLACE FUNCTION public._payout(n integer, t text, a bigint)
 RETURNS bigint
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'public', 'extensions'
AS $function$
declare k text := split_part(t,':',1); v text := split_part(t,':',2);
begin
  if k='num' then return case when v::int = n then a*9 else 0 end; end if;
  if k='size' then return case when (n>=5 and v='big') or (n<5 and v='small') then a*2 else 0 end; end if;
  if v='violet' then return case when n in (0,5) then (a*9)/2 else 0 end; end if;
  if v='green' then return case when n in (1,3,5,7,9) then a*2 else 0 end; end if;
  return case when n in (0,2,4,6,8) then a*2 else 0 end;
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public._rand10()
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare v int;
begin
  loop v := get_byte(gen_random_bytes(1),0); exit when v < 250; end loop;  -- no modulo bias
  return v % 10;
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public._settle()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare r bigint; n int; cur bigint := _cur_round();
begin
  perform pg_advisory_xact_lock(7001);
  insert into results(round,num) values (cur-1, _rand10()) on conflict do nothing;
  for r in select distinct round from bets where not settled and round < cur order by round loop
    insert into results(round,num) values (r, _rand10()) on conflict do nothing;
    select num into n from results where round = r;
    update bets set payout = _payout(n,target,amount), settled = true where round = r and not settled;
    update app_users u set balance = u.balance + s.p
      from (select user_id, sum(payout) p from bets where round = r group by user_id) s
      where u.id = s.user_id;
  end loop;
  -- Auto-clean: keep approximately the last 2 hours of results (205 rounds x 35 s).
  delete from results where round < cur - 205;
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public._uid(p_token text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare u text;
begin
  if p_token is null or length(p_token) < 40 then
    raise exception 'Session expired. Please log in again.';
  end if;

  select user_id into u
  from public.sessions
  where token=p_token and expires_at > now();

  if u is null then
    delete from public.sessions where token=p_token or expires_at <= now();
    raise exception 'Session expired. Please log in again.';
  end if;

  update public.sessions set last_seen_at=now() where token=p_token;
  return u;
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_add_coins(p_token text, p_id text, p_amount bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare b bigint;
begin
  perform _admin(p_token);
  -- Positive amount adds coins, negative amount deducts coins.
  if p_amount = 0 or abs(p_amount) > 1000000 then raise exception 'Amount must be between 1 and 1,000,000.'; end if;
  select balance into b from app_users where id = p_id and role = 'user' for update;
  if not found then raise exception 'User not found.'; end if;
  if b + p_amount < 0 then raise exception 'This user only has % coins. You cannot deduct more.', b; end if;
  update app_users set balance = balance + p_amount where id = p_id;
  insert into coin_log(user_id, amount, by_admin) values (p_id, p_amount, _uid(p_token));
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_add_payment_upi(p_token text, p_upi_id text, p_payee_name text DEFAULT 'Play2Win'::text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare new_id bigint; should_activate boolean;
begin
  perform public._admin(p_token);
  if p_upi_id is null or p_upi_id !~ '^[A-Za-z0-9][A-Za-z0-9._-]{1,}@[A-Za-z]{2,}$' then
    raise exception 'Enter a valid UPI ID.';
  end if;
  if length(coalesce(p_payee_name,''))>60 then raise exception 'Payee name is too long.'; end if;
  select not exists(select 1 from public.payment_receiving_upis where is_active=true)
    into should_activate;
  insert into public.payment_receiving_upis(upi_id,payee_name,is_active)
  values(lower(trim(p_upi_id)),coalesce(nullif(trim(p_payee_name),''),'Play2Win'),should_activate)
  returning id into new_id;
  return json_build_object('success',true,'id',new_id,'is_active',should_activate);
exception when unique_violation then
  raise exception 'This UPI ID is already saved.';
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_bets(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare cur bigint := _cur_round();
begin
  perform _admin(p_token);
  perform _settle();
  return json_build_object(
    'round', cur,
    'left', 35 - (floor(extract(epoch from now()))::bigint % 35),
    'current', (select coalesce(json_agg(x),'[]'::json) from (
        select b.user_id, u.email, u.display_name, b.target, b.amount
        from bets b join app_users u on u.id=b.user_id
        where b.round = cur order by b.id desc limit 500) x),
    'recent', (select coalesce(json_agg(y),'[]'::json) from (
        select b.user_id, u.email, u.display_name, b.round, b.target, b.amount, b.payout, b.settled
        from bets b join app_users u on u.id=b.user_id
        where b.round < cur order by b.id desc limit 100) y));
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_create_user(p_token text, p_id text, p_pw text, p_phone text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform public._admin(p_token);
  if p_id !~ '^[A-Za-z0-9_.-]{3,20}$' then
    raise exception 'User ID must be 3-20 letters, numbers, or _ . -';
  end if;
  if p_pw is null or length(p_pw)<10 or p_pw !~ '[A-Za-z]' or p_pw !~ '[0-9]' then
    raise exception 'Password must be at least 10 characters and include letters and numbers.';
  end if;
  if p_phone !~ '^\+?[0-9]{7,15}$' then
    raise exception 'Enter a valid phone number (7-15 digits, optional + at the start).';
  end if;
  if exists(select 1 from public.app_users where id=p_id) then
    raise exception 'This User ID already exists.';
  end if;
  insert into public.app_users(id,pw,role,balance,phone)
  values(p_id,crypt(p_pw,gen_salt('bf',12)),'user',100,p_phone);
  insert into public.coin_log(user_id,amount,by_admin)
  values(p_id,100,public._uid(p_token));
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_delete_payment_upi(p_token text, p_id bigint)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform public._admin(p_token);
  delete from public.payment_receiving_upis where id=p_id;
  if not found then raise exception 'UPI ID not found.'; end if;
  return json_build_object('success',true);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_delete_user(p_token text, p_id text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform _admin(p_token);
  delete from app_users where id = p_id and role = 'user';
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_grant_gold_credits(p_token text, p_user_id text, p_amount bigint)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare admin_id text := public._admin(p_token); c bigint;
begin
  if p_amount < 1 or p_amount > 100000 then raise exception 'Grant must be 1 to 100,000 credits.'; end if;
  if not exists(select 1 from public.app_users where id=p_user_id and role='user') then
    raise exception 'User not found.';
  end if;
  insert into public.gold_game_wallets(user_id) values(p_user_id) on conflict(user_id) do nothing;
  update public.gold_game_wallets set credits=credits+p_amount,updated_at=now()
    where user_id=p_user_id returning credits into c;
  insert into public.gold_game_ledger(user_id,amount,entry_type)
    values(p_user_id,p_amount,'admin_grant');
  return json_build_object('user_id',p_user_id,'credits',c);
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_list_coin_deposits(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform _admin(p_token);
  return (
    select coalesce(json_agg(x order by x.created_at desc),'[]'::json)
    from (
      select d.id,d.user_id,u.email,u.display_name,u.phone,d.amount,d.utr,d.payment_reference,
             d.status,d.created_at,d.reviewed_at,d.reviewed_by
      from coin_deposit_requests d
      join app_users u on u.id=d.user_id
      order by d.created_at desc limit 300
    ) x
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_list_payment_upis(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform public._admin(p_token);
  return (
    select coalesce(json_agg(x order by x.created_at desc),'[]'::json)
    from (
      select id,upi_id,payee_name,is_active,created_at
      from public.payment_receiving_upis
    ) x
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_list_users(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform _admin(p_token);
  return (select coalesce(json_agg(x),'[]'::json) from (
    select id, display_name, email, phone, balance, created_at from app_users where role = 'user' order by created_at desc) x);
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_list_withdrawal_requests(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform _admin(p_token);
  return (select coalesce(json_agg(x order by x.created_at desc),'[]'::json)
    from (select w.id,w.user_id,u.email,u.display_name,w.upi_id,w.amount,w.status,w.created_at,w.reviewed_at,w.reviewed_by
      from withdrawal_requests w join app_users u on u.id=w.user_id
      order by w.created_at desc limit 300) x);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_review_coin_deposit(p_token text, p_deposit_id bigint, p_status text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare admin_id text := _admin(p_token); d coin_deposit_requests; new_balance bigint;
begin
  if p_status not in ('approved','rejected') then
    raise exception 'Invalid deposit decision.';
  end if;

  select * into d from coin_deposit_requests
  where id=p_deposit_id for update;

  if not found then raise exception 'Deposit request not found.'; end if;
  if d.status <> 'pending' then raise exception 'This deposit request has already been reviewed.'; end if;

  update coin_deposit_requests
  set status=p_status, reviewed_by=admin_id, reviewed_at=now()
  where id=p_deposit_id;

  if p_status='approved' then
    update app_users set balance=balance+d.amount
    where id=d.user_id returning balance into new_balance;

    if new_balance is null then raise exception 'Wallet user not found.'; end if;

    insert into coin_log(user_id,amount,by_admin)
    values(d.user_id,d.amount,admin_id);
  end if;

  return json_build_object(
    'success',true,'status',p_status,
    'amount',d.amount,'user_id',d.user_id,'balance',new_balance
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_review_withdrawal(p_token text, p_request_id bigint, p_status text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare aid text := _admin(p_token); w withdrawal_requests; new_balance bigint;
begin
  if p_status not in ('paid','rejected') then raise exception 'Invalid withdrawal decision.'; end if;
  select * into w from withdrawal_requests where id=p_request_id for update;
  if not found then raise exception 'Withdrawal request not found.'; end if;
  if w.status <> 'pending' then raise exception 'This withdrawal has already been reviewed.'; end if;
  update withdrawal_requests set status=p_status,reviewed_by=aid,reviewed_at=now() where id=p_request_id;
  if p_status='rejected' then
    update app_users set balance=balance+w.amount where id=w.user_id returning balance into new_balance;
    insert into coin_log(user_id,amount,by_admin) values(w.user_id,w.amount,'withdrawal refund #'||w.id);
  end if;
  return json_build_object('success',true,'status',p_status,'amount',w.amount,'user_id',w.user_id,'balance',new_balance);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_set_active_payment_upi(p_token text, p_id bigint)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform public._admin(p_token);
  if not exists(select 1 from public.payment_receiving_upis where id=p_id) then
    raise exception 'UPI ID not found.';
  end if;
  update public.payment_receiving_upis set is_active=false,updated_at=now() where is_active=true;
  update public.payment_receiving_upis set is_active=true,updated_at=now() where id=p_id;
  return json_build_object('success',true,'active_id',p_id);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_set_password(p_token text, p_id text, p_new text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform public._admin(p_token);
  if p_new is null or length(p_new)<10 or p_new !~ '[A-Za-z]' or p_new !~ '[0-9]' then
    raise exception 'Password must be at least 10 characters and include letters and numbers.';
  end if;
  update public.app_users
    set pw=crypt(p_new,gen_salt('bf',12))
    where id=p_id and role='user';
  if not found then raise exception 'User not found.'; end if;
  delete from public.sessions where user_id=p_id;
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.admin_set_phone(p_token text, p_id text, p_phone text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  perform _admin(p_token);
  if p_phone !~ '^\+?[0-9]{7,15}$' then raise exception 'Enter a valid phone number (7-15 digits, optional + at the start).'; end if;
  update app_users set phone = p_phone where id = p_id and role = 'user';
  if not found then raise exception 'User not found.'; end if;
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.change_password(p_token text, p_old text, p_new text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := public._uid(p_token); current_hash text;
begin
  select pw into current_hash from public.app_users where id=uid;
  if current_hash is null or current_hash <> crypt(p_old,current_hash) then
    raise exception 'Current password is incorrect.';
  end if;
  if p_new is null or length(p_new)<10 or p_new !~ '[A-Za-z]' or p_new !~ '[0-9]' then
    raise exception 'New password must be at least 10 characters and include letters and numbers.';
  end if;
  if p_new=p_old then raise exception 'New password must differ from the current password.'; end if;
  update public.app_users set pw=crypt(p_new,gen_salt('bf',12)) where id=uid;
  delete from public.sessions where user_id=uid and token<>p_token;
  update public.sessions set expires_at=now()+interval '2 hours',last_seen_at=now()
    where token=p_token and user_id=uid;
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.claim_daily_reward(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_uid text := public._uid(p_token);
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
  v_last date;
  v_prev_streak integer := 0;
  v_day integer := 1;
  v_reward integer;
  v_balance bigint;
begin

  -- Prevent simultaneous duplicate claims
  perform pg_advisory_xact_lock(hashtext(v_uid));

  select last_claim_date, streak_day
  into v_last, v_prev_streak
  from public.daily_checkins
  where user_id = v_uid
  for update;

  if found then

    if v_last = v_today then
      raise exception 'Today’s daily reward has already been claimed.';

    elsif v_last = v_today - 1 then
      v_day := least(v_prev_streak + 1, 5);

    else
      v_day := 1;
    end if;

  end if;


  -- UPDATED REWARD VALUES
  v_reward := case v_day
    when 1 then 1
    when 2 then 2
    when 3 then 3
    when 4 then 5
    else 10
  end;


  -- Add coins to user wallet
  update public.app_users
  set balance = balance + v_reward
  where id = v_uid
    and role = 'user'
  returning balance into v_balance;

  if not found then
    raise exception 'User account not found.';
  end if;


  -- Save coin transaction history
  insert into public.coin_log(
    user_id,
    amount,
    by_admin
  )
  values (
    v_uid,
    v_reward,
    'daily_checkin'
  );


  -- Save daily check-in
  insert into public.daily_checkins(
    user_id,
    last_claim_date,
    streak_day,
    updated_at
  )
  values (
    v_uid,
    v_today,
    v_day,
    now()
  )
  on conflict (user_id)
  do update set
    last_claim_date = excluded.last_claim_date,
    streak_day = excluded.streak_day,
    updated_at = now();


  return json_build_object(
    'success', true,
    'day', v_day,
    'reward', v_reward,
    'balance', v_balance,
    'claimed_today', true
  );

end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.create_withdrawal_request(p_token text, p_amount bigint)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token); u text; b bigint; req_id bigint;
begin
  if exists(select 1 from app_users where id=uid and role='admin') then
    raise exception 'Admin accounts cannot request withdrawals.';
  end if;
  if p_amount is null or p_amount < 100 or p_amount > 1000000 then
    raise exception 'Minimum withdrawal is 100 coins.';
  end if;
  select upi_id into u from public.user_withdrawal_upi where user_id=uid;
  if u is null then raise exception 'Please save your UPI ID first.'; end if;
  update app_users set balance=balance-p_amount
  where id=uid and balance>=p_amount returning balance into b;
  if b is null then raise exception 'Insufficient wallet coins.'; end if;
  insert into withdrawal_requests(user_id,upi_id,amount)
  values(uid,u,p_amount) returning id into req_id;
  insert into coin_log(user_id,amount,by_admin)
  values(uid,-p_amount,'withdrawal request #'||req_id);
  return json_build_object('success',true,'request_id',req_id,'status','pending','balance',b);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.daily_reward_status(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  v_uid text := public._uid(p_token);
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
  v_last date;
  v_streak integer := 0;
  v_next integer := 1;
  v_claimed boolean := false;
begin

  select last_claim_date, streak_day
  into v_last, v_streak
  from public.daily_checkins
  where user_id = v_uid;

  if found then

    v_claimed := (v_last = v_today);

    if v_claimed or v_last = v_today - 1 then
      v_next := least(v_streak + 1, 5);
    else
      v_next := 1;
    end if;

  end if;

  return json_build_object(
    'claimed_today', v_claimed,
    'streak_day', case when v_claimed then v_streak else 0 end,
    'next_day', v_next,
    'last_claim_date', v_last
  );

end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.get_active_payment_upi(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := public._uid(p_token);
begin
  if exists(select 1 from public.app_users where id=uid and role='admin') then
    -- Admin may also preview the active receiving account.
    null;
  end if;
  return (
    select json_build_object('upi_id',upi_id,'payee_name',payee_name)
    from public.payment_receiving_upis where is_active=true limit 1
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.get_my_withdrawal_upi(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token); u text;
begin
  select upi_id into u from public.user_withdrawal_upi where user_id=uid;
  return json_build_object('upi_id',u);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.get_state(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token); u app_users; cur bigint := _cur_round();
begin
  perform _settle();
  select * into u from app_users where id = uid;
  return json_build_object(
    'round', cur,
    'left', 35 - (floor(extract(epoch from now()))::bigint % 35),
    'role', u.role, 'balance', u.balance, 'phone', u.phone,
    'results', (select coalesce(json_agg(json_build_object('round',round,'num',num) order by round desc),'[]'::json)
                from (select * from results where round >= cur - 240 order by round desc) x),
    'pending', (select coalesce(json_agg(json_build_object('target',target,'amount',amount) order by id),'[]'::json)
                from bets where user_id = uid and round = cur));
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.gold_game_state(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  uid text := public._uid(p_token);
  c bigint;
begin
  if exists(select 1 from public.app_users where id=uid and role='admin') then
    raise exception 'Admin accounts cannot play.';
  end if;

  select balance into c from public.app_users where id=uid;
  if c is null then raise exception 'User account not found.'; end if;

  return json_build_object(
    'credits', c,
    'balance', c,
    'history', (
      select coalesce(json_agg(x order by x.id desc),'[]'::json)
      from (
        select id, stake, entry_amount, multiplier, selected_cup, won, payout, created_at
        from public.gold_game_rounds
        where user_id=uid and settled=true
        order by id desc limit 30
      ) x
    )
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.gold_pick_cup(p_token text, p_round_id bigint, p_cup integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  uid text := public._uid(p_token);
  r public.gold_game_rounds;
  new_balance bigint;
  paid bigint := 0;
  is_win boolean;
begin
  if p_cup is null or p_cup not between 0 and 2 then
    raise exception 'Invalid cup.';
  end if;

  select * into r
    from public.gold_game_rounds
   where id=p_round_id and user_id=uid
   for update;

  if not found then raise exception 'Round not found.'; end if;
  if r.settled then raise exception 'This round has already been settled.'; end if;

  is_win := (r.winning_cup=p_cup);
  if is_win then paid := r.stake * 2; end if;

  update public.gold_game_rounds
     set selected_cup=p_cup, won=is_win, payout=paid,
         settled=true, settled_at=now()
   where id=r.id;

  if paid > 0 then
    update public.app_users
       set balance=balance+paid
     where id=uid
     returning balance into new_balance;

    insert into public.gold_game_ledger(user_id,round_id,amount,entry_type)
    values(uid,r.id,paid,'round_win');
  else
    select balance into new_balance from public.app_users where id=uid;
  end if;

  return json_build_object(
    'won',is_win,
    'payout',paid,
    'credits',new_balance,
    'balance',new_balance,
    'winning_cup',r.winning_cup
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.gold_start_round(p_token text, p_amount bigint, p_multiplier integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  uid text := public._uid(p_token);
  total bigint;
  new_balance bigint;
  rid bigint;
  cup smallint;
begin
  if exists(select 1 from public.app_users where id=uid and role='admin') then
    raise exception 'Admin accounts cannot play.';
  end if;

  if p_amount is null or p_amount < 1 or p_amount > 10000
     or p_multiplier is null or p_multiplier not in (1,5,10) then
    raise exception 'Invalid entry amount or multiplier.';
  end if;

  total := p_amount * p_multiplier;
  if total > 10000 then
    raise exception 'Maximum Gold Ball entry is 10,000 coins.';
  end if;

  -- Atomic debit from the SAME wallet used by Number Game.
  update public.app_users
     set balance = balance - total
   where id=uid and role='user' and balance >= total
   returning balance into new_balance;

  if new_balance is null then
    raise exception 'Not enough wallet coins.';
  end if;

  -- Result remains server-side until the user makes a pick.
  cup := (get_byte(extensions.gen_random_bytes(1),0) % 3)::smallint;

  insert into public.gold_game_rounds
    (user_id,stake,entry_amount,multiplier,winning_cup)
  values (uid,total,p_amount,p_multiplier,cup)
  returning id into rid;

  insert into public.gold_game_ledger(user_id,round_id,amount,entry_type)
  values(uid,rid,-total,'round_entry');

  return json_build_object(
    'round_id',rid,
    'credits',new_balance,
    'balance',new_balance,
    'total_entry',total
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.google_wallet_login()
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'auth'
AS $function$
declare
  auid uuid := auth.uid();
  jwt_data jsonb := auth.jwt();
  mail text;
  email_confirmed timestamptz;
  uname text;
  uid text;
  tok text;
  is_new boolean := false;
begin
  if auid is null then
    raise exception 'A verified Google account is required. Please sign in again.';
  end if;

  select lower(coalesce(email,'')), email_confirmed_at
    into mail, email_confirmed
  from auth.users
  where id=auid;

  if mail is null or mail='' or email_confirmed is null
     or not exists(select 1 from auth.identities where user_id=auid and provider='google') then
    raise exception 'A verified Google account is required. Please sign in again.';
  end if;

  uname := coalesce(
    nullif(jwt_data->'user_metadata'->>'full_name',''),
    nullif(jwt_data->'user_metadata'->>'name',''),
    nullif(trim(coalesce(jwt_data->'user_metadata'->>'given_name','') || ' ' ||
                coalesce(jwt_data->'user_metadata'->>'family_name','')),''),
    split_part(mail,'@',1)
  );

  select user_id into uid
  from public.google_wallet_links where auth_user_id=auid;

  if uid is null then
    is_new := true;
    uid := 'G' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
    insert into public.app_users(id,pw,role,balance,phone,display_name,email)
    values(uid,crypt(encode(gen_random_bytes(32),'hex'),gen_salt('bf',12)),
           'user',20,null,uname,mail);
    insert into public.google_wallet_links(auth_user_id,user_id) values(auid,uid);
    insert into public.coin_log(user_id,amount,by_admin) values(uid,20,'google signup bonus');
  else
    update public.app_users set display_name=uname,email=mail where id=uid;
    if not exists(select 1 from public.coin_log where user_id=uid and by_admin='google signup bonus') then
      update public.app_users set balance=balance+20 where id=uid;
      insert into public.coin_log(user_id,amount,by_admin) values(uid,20,'google signup bonus');
    end if;
  end if;

  delete from public.sessions where expires_at <= now();
  tok := encode(gen_random_bytes(32),'hex');
  insert into public.sessions(token,user_id,created_at,expires_at,last_seen_at)
  values(tok,uid,now(),now()+interval '12 hours',now());

  return json_build_object(
    'success',true,'token',tok,'id',uid,'role','user',
    'name',uname,'display_name',uname,'email',mail,'is_new_user',is_new
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.has_admin()
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$ select exists (select 1 from app_users where role='admin') $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.login(p_id text, p_pw text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare
  u public.app_users;
  t text;
  v_key text;
  v_ip text := null;
  v_locked timestamptz;
  v_reset boolean;
begin
  begin
    v_ip := current_setting('request.headers', true)::jsonb ->> 'cf-connecting-ip';
  exception when others then
    v_ip := null;
  end;

  v_key := encode(digest(lower(trim(coalesce(p_id,''))) || '|' || coalesce(v_ip,'shared'), 'sha256'),'hex');
  perform pg_advisory_xact_lock(hashtextextended(v_key,0));

  select locked_until into v_locked
  from public.login_attempts where login_key=v_key;

  if v_locked is not null and v_locked > now() then
    return json_build_object('success',false,'error','Too many failed attempts. Please wait 15 minutes and try again.');
  end if;

  select * into u from public.app_users where id=trim(coalesce(p_id,''));

  if not found or p_pw is null or u.pw <> crypt(p_pw,u.pw) then
    insert into public.login_attempts(login_key,attempts,window_started,locked_until)
    values(v_key,1,now(),null)
    on conflict(login_key) do update
      set attempts = case
            when public.login_attempts.window_started < now()-interval '15 minutes' then 1
            else public.login_attempts.attempts+1 end,
          window_started = case
            when public.login_attempts.window_started < now()-interval '15 minutes' then now()
            else public.login_attempts.window_started end,
          locked_until = case
            when public.login_attempts.window_started < now()-interval '15 minutes' then null
            when public.login_attempts.attempts+1 >= 5 then now()+interval '15 minutes'
            else public.login_attempts.locked_until end;
    delete from public.login_attempts where window_started < now()-interval '1 day';
    return json_build_object('success',false,'error','Invalid User ID or password, or login temporarily locked.');
  end if;

  delete from public.login_attempts where login_key=v_key;
  delete from public.sessions where expires_at <= now();

  t := encode(gen_random_bytes(32),'hex');
  insert into public.sessions(token,user_id,created_at,expires_at,last_seen_at)
  values(
    t,u.id,now(),
    now()+case when u.role='admin' then interval '2 hours' else interval '12 hours' end,
    now()
  );

  return json_build_object('success',true,'token',t,'id',u.id,'role',u.role);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.logout_session(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  if p_token is not null then
    delete from public.sessions where token=p_token;
  end if;
  return json_build_object('success',true);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.my_coin_deposits(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token);
begin
  return (
    select coalesce(json_agg(x order by x.created_at desc),'[]'::json)
    from (
      select id,amount,utr,payment_reference,status,created_at,reviewed_at
      from coin_deposit_requests where user_id=uid
      order by created_at desc limit 50
    ) x
  );
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.my_coin_log(p_token text, p_user text DEFAULT NULL::text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token); adm boolean;
begin
  select role = 'admin' into adm from app_users where id = uid;
  return (select coalesce(json_agg(x),'[]'::json) from (
    select c.user_id, u.email, u.display_name, c.amount, c.created_at
    from coin_log c join app_users u on u.id=c.user_id
    where (adm and (p_user is null or c.user_id = p_user)) or (not adm and c.user_id = uid)
    order by c.id desc limit 200) x);
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.my_history(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token);
begin
  perform _settle();
  return (select coalesce(json_agg(x),'[]'::json) from (
    select round, target, amount, payout, settled from bets where user_id = uid order by id desc limit 50) x);
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.my_withdrawal_requests(p_token text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token);
begin
  return (select coalesce(json_agg(x order by x.created_at desc),'[]'::json)
    from (select id,upi_id,amount,status,created_at,reviewed_at
      from withdrawal_requests where user_id=uid order by created_at desc limit 50) x);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.place_bet(p_token text, p_target text, p_amount bigint)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token); b bigint;
begin
  perform _settle();
  if p_target !~ '^(color:(green|red|violet)|size:(big|small)|num:[0-9])$' then raise exception 'Invalid bet.'; end if;
  if p_amount < 1 or p_amount > 100000 then raise exception 'Invalid amount.'; end if;
  if (floor(extract(epoch from now()))::bigint % 35) >= 30 then raise exception 'Betting is closed for this round.'; end if;
  if exists (select 1 from app_users where id = uid and role = 'admin') then raise exception 'Admin accounts cannot play.'; end if;
  update app_users set balance = balance - p_amount where id = uid and balance >= p_amount returning balance into b;
  if b is null then raise exception 'Not enough coins.'; end if;
  insert into bets(user_id,round,target,amount) values (uid, _cur_round(), p_target, p_amount);
  return json_build_object('balance', b);
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.save_withdraw_upi(p_token text, p_upi_id text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token);
begin
  if exists(select 1 from app_users where id=uid and role='admin') then
    raise exception 'Admin account cannot register a withdrawal UPI ID.';
  end if;
  if p_upi_id !~ '^[A-Za-z0-9][A-Za-z0-9._-]{1,}@[A-Za-z]{2,}$' then
    raise exception 'Enter a valid UPI ID.';
  end if;
  insert into public.user_withdrawal_upi(user_id,upi_id,updated_at)
  values(uid,p_upi_id,now())
  on conflict(user_id) do update set upi_id=excluded.upi_id,updated_at=now();
  return json_build_object('success',true,'upi_id',p_upi_id);
end;
$function$


-- ========================================

CREATE OR REPLACE FUNCTION public.setup_admin(p_id text, p_pw text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  if has_admin() then raise exception 'An admin account already exists.'; end if;
  if length(p_pw) < 6 then raise exception 'Password must be at least 6 characters.'; end if;
  insert into app_users(id,pw,role,balance) values (p_id, crypt(p_pw, gen_salt('bf')), 'admin', 0);
end $function$


-- ========================================

CREATE OR REPLACE FUNCTION public.submit_coin_deposit(p_token text, p_amount bigint, p_utr text, p_reference text DEFAULT NULL::text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare uid text := _uid(p_token); new_id bigint;
begin
  if exists (select 1 from app_users where id=uid and role='admin') then
    raise exception 'Admin accounts cannot submit wallet deposits.';
  end if;
  if p_amount < 10 or p_amount > 50000 then
    raise exception 'Amount must be between 10 and 50,000.';
  end if;
  if p_utr !~ '^[0-9]{12}$' then
    raise exception 'Enter a valid 12 digit UTR number.';
  end if;
  insert into coin_deposit_requests(user_id,amount,utr,payment_reference)
  values(uid,p_amount,p_utr,p_reference)
  returning id into new_id;
  return json_build_object('success',true,'request_id',new_id,'status','pending');
exception
  when unique_violation then
    raise exception 'This UTR number has already been submitted.';
end;
$function$


