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
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA vault;
CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA pg_catalog;

-- Sequences
CREATE SEQUENCE IF NOT EXISTS public.bets_id_seq;
ALTER SEQUENCE public.bets_id_seq OWNED BY public.bets.id;

CREATE SEQUENCE IF NOT EXISTS public.coin_deposit_requests_id_seq;
ALTER SEQUENCE public.coin_deposit_requests_id_seq OWNED BY public.coin_deposit_requests.id;

CREATE SEQUENCE IF NOT EXISTS public.coin_log_id_seq;
ALTER SEQUENCE public.coin_log_id_seq OWNED BY public.coin_log.id;

CREATE SEQUENCE IF NOT EXISTS public.gold_game_ledger_id_seq;
ALTER SEQUENCE public.gold_game_ledger_id_seq OWNED BY public.gold_game_ledger.id;

CREATE SEQUENCE IF NOT EXISTS public.gold_game_rounds_id_seq;
ALTER SEQUENCE public.gold_game_rounds_id_seq OWNED BY public.gold_game_rounds.id;

CREATE SEQUENCE IF NOT EXISTS public.payment_receiving_upis_id_seq;
ALTER SEQUENCE public.payment_receiving_upis_id_seq OWNED BY public.payment_receiving_upis.id;

CREATE SEQUENCE IF NOT EXISTS public.withdrawal_requests_id_seq;
ALTER SEQUENCE public.withdrawal_requests_id_seq OWNED BY public.withdrawal_requests.id;

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
