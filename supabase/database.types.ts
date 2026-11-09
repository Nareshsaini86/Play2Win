// Generated from current Supabase schema on 2026-11-10.\nexport type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  public: {
    Tables: {
      app_users: {
        Row: {
          balance: number
          created_at: string
          display_name: string | null
          email: string | null
          id: string
          phone: string | null
          pw: string
          role: string
        }
        Insert: {
          balance?: number
          created_at?: string
          display_name?: string | null
          email?: string | null
          id: string
          phone?: string | null
          pw: string
          role?: string
        }
        Update: {
          balance?: number
          created_at?: string
          display_name?: string | null
          email?: string | null
          id?: string
          phone?: string | null
          pw?: string
          role?: string
        }
        Relationships: []
      }
      bets: {
        Row: {
          amount: number
          created_at: string
          id: number
          payout: number
          round: number
          settled: boolean
          target: string
          user_id: string
        }
        Insert: {
          amount: number
          created_at?: string
          id?: number
          payout?: number
          round: number
          settled?: boolean
          target: string
          user_id: string
        }
        Update: {
          amount?: number
          created_at?: string
          id?: number
          payout?: number
          round?: number
          settled?: boolean
          target?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "bets_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      coin_deposit_requests: {
        Row: {
          amount: number
          created_at: string
          id: number
          payment_reference: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          status: string
          user_id: string
          utr: string
        }
        Insert: {
          amount: number
          created_at?: string
          id?: number
          payment_reference?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string
          user_id: string
          utr: string
        }
        Update: {
          amount?: number
          created_at?: string
          id?: number
          payment_reference?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string
          user_id?: string
          utr?: string
        }
        Relationships: [
          {
            foreignKeyName: "coin_deposit_requests_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "coin_deposit_requests_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      coin_log: {
        Row: {
          amount: number
          by_admin: string | null
          created_at: string
          id: number
          user_id: string
        }
        Insert: {
          amount: number
          by_admin?: string | null
          created_at?: string
          id?: number
          user_id: string
        }
        Update: {
          amount?: number
          by_admin?: string | null
          created_at?: string
          id?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "coin_log_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      daily_checkins: {
        Row: {
          last_claim_date: string
          streak_day: number
          updated_at: string
          user_id: string
        }
        Insert: {
          last_claim_date: string
          streak_day: number
          updated_at?: string
          user_id: string
        }
        Update: {
          last_claim_date?: string
          streak_day?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "daily_checkins_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      gold_game_ledger: {
        Row: {
          amount: number
          created_at: string
          entry_type: string
          id: number
          round_id: number | null
          user_id: string
        }
        Insert: {
          amount: number
          created_at?: string
          entry_type: string
          id?: number
          round_id?: number | null
          user_id: string
        }
        Update: {
          amount?: number
          created_at?: string
          entry_type?: string
          id?: number
          round_id?: number | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "gold_game_ledger_round_id_fkey"
            columns: ["round_id"]
            isOneToOne: false
            referencedRelation: "gold_game_rounds"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "gold_game_ledger_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      gold_game_rounds: {
        Row: {
          created_at: string
          entry_amount: number
          id: number
          multiplier: number
          payout: number
          selected_cup: number | null
          settled: boolean
          settled_at: string | null
          stake: number
          user_id: string
          winning_cup: number
          won: boolean | null
        }
        Insert: {
          created_at?: string
          entry_amount: number
          id?: number
          multiplier: number
          payout?: number
          selected_cup?: number | null
          settled?: boolean
          settled_at?: string | null
          stake: number
          user_id: string
          winning_cup: number
          won?: boolean | null
        }
        Update: {
          created_at?: string
          entry_amount?: number
          id?: number
          multiplier?: number
          payout?: number
          selected_cup?: number | null
          settled?: boolean
          settled_at?: string | null
          stake?: number
          user_id?: string
          winning_cup?: number
          won?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "gold_game_rounds_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      gold_game_wallets: {
        Row: {
          credits: number
          updated_at: string
          user_id: string
        }
        Insert: {
          credits?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          credits?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "gold_game_wallets_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      google_wallet_links: {
        Row: {
          auth_user_id: string
          created_at: string
          user_id: string
        }
        Insert: {
          auth_user_id: string
          created_at?: string
          user_id: string
        }
        Update: {
          auth_user_id?: string
          created_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "google_wallet_links_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      login_attempts: {
        Row: {
          attempts: number
          locked_until: string | null
          login_key: string
          window_started: string
        }
        Insert: {
          attempts?: number
          locked_until?: string | null
          login_key: string
          window_started?: string
        }
        Update: {
          attempts?: number
          locked_until?: string | null
          login_key?: string
          window_started?: string
        }
        Relationships: []
      }
      payment_receiving_upis: {
        Row: {
          created_at: string
          id: number
          is_active: boolean
          payee_name: string
          updated_at: string
          upi_id: string
        }
        Insert: {
          created_at?: string
          id?: number
          is_active?: boolean
          payee_name?: string
          updated_at?: string
          upi_id: string
        }
        Update: {
          created_at?: string
          id?: number
          is_active?: boolean
          payee_name?: string
          updated_at?: string
          upi_id?: string
        }
        Relationships: []
      }
      results: {
        Row: {
          created_at: string
          num: number
          round: number
        }
        Insert: {
          created_at?: string
          num: number
          round: number
        }
        Update: {
          created_at?: string
          num?: number
          round?: number
        }
        Relationships: []
      }
      sessions: {
        Row: {
          created_at: string
          expires_at: string
          last_seen_at: string | null
          token: string
          user_id: string
        }
        Insert: {
          created_at?: string
          expires_at: string
          last_seen_at?: string | null
          token: string
          user_id: string
        }
        Update: {
          created_at?: string
          expires_at?: string
          last_seen_at?: string | null
          token?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "sessions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_withdrawal_upi: {
        Row: {
          updated_at: string
          upi_id: string
          user_id: string
        }
        Insert: {
          updated_at?: string
          upi_id: string
          user_id: string
        }
        Update: {
          updated_at?: string
          upi_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_withdrawal_upi_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
      withdrawal_requests: {
        Row: {
          amount: number
          created_at: string
          id: number
          reviewed_at: string | null
          reviewed_by: string | null
          status: string
          upi_id: string
          user_id: string
        }
        Insert: {
          amount: number
          created_at?: string
          id?: number
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string
          upi_id: string
          user_id: string
        }
        Update: {
          amount?: number
          created_at?: string
          id?: number
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string
          upi_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "withdrawal_requests_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "withdrawal_requests_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "app_users"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      _admin: { Args: { p_token: string }; Returns: string }
      _cur_round: { Args: never; Returns: number }
      _payout: { Args: { a: number; n: number; t: string }; Returns: number }
      _rand10: { Args: never; Returns: number }
      _settle: { Args: never; Returns: undefined }
      _uid: { Args: { p_token: string }; Returns: string }
      admin_add_coins: {
        Args: { p_amount: number; p_id: string; p_token: string }
        Returns: undefined
      }
      admin_add_payment_upi: {
        Args: { p_payee_name?: string; p_token: string; p_upi_id: string }
        Returns: Json
      }
      admin_bets: { Args: { p_token: string }; Returns: Json }
      admin_create_user: {
        Args: { p_id: string; p_phone: string; p_pw: string; p_token: string }
        Returns: undefined
      }
      admin_delete_payment_upi: {
        Args: { p_id: number; p_token: string }
        Returns: Json
      }
      admin_delete_user: {
        Args: { p_id: string; p_token: string }
        Returns: undefined
      }
      admin_grant_gold_credits: {
        Args: { p_amount: number; p_token: string; p_user_id: string }
        Returns: Json
      }
      admin_list_coin_deposits: { Args: { p_token: string }; Returns: Json }
      admin_list_payment_upis: { Args: { p_token: string }; Returns: Json }
      admin_list_users: { Args: { p_token: string }; Returns: Json }
      admin_list_withdrawal_requests: {
        Args: { p_token: string }
        Returns: Json
      }
      admin_review_coin_deposit: {
        Args: { p_deposit_id: number; p_status: string; p_token: string }
        Returns: Json
      }
      admin_review_withdrawal: {
        Args: { p_request_id: number; p_status: string; p_token: string }
        Returns: Json
      }
      admin_set_active_payment_upi: {
        Args: { p_id: number; p_token: string }
        Returns: Json
      }
      admin_set_password: {
        Args: { p_id: string; p_new: string; p_token: string }
        Returns: undefined
      }
      admin_set_phone: {
        Args: { p_id: string; p_phone: string; p_token: string }
        Returns: undefined
      }
      change_password: {
        Args: { p_new: string; p_old: string; p_token: string }
        Returns: undefined
      }
      claim_daily_reward: { Args: { p_token: string }; Returns: Json }
      create_withdrawal_request: {
        Args: { p_amount: number; p_token: string }
        Returns: Json
      }
      daily_reward_status: { Args: { p_token: string }; Returns: Json }
      get_active_payment_upi: { Args: { p_token: string }; Returns: Json }
      get_my_withdrawal_upi: { Args: { p_token: string }; Returns: Json }
      get_state: { Args: { p_token: string }; Returns: Json }
      gold_game_state: { Args: { p_token: string }; Returns: Json }
      gold_pick_cup: {
        Args: { p_cup: number; p_round_id: number; p_token: string }
        Returns: Json
      }
      gold_start_round: {
        Args: { p_amount: number; p_multiplier: number; p_token: string }
        Returns: Json
      }
      google_wallet_login: { Args: never; Returns: Json }
      has_admin: { Args: never; Returns: boolean }
      login: { Args: { p_id: string; p_pw: string }; Returns: Json }
      logout_session: { Args: { p_token: string }; Returns: Json }
      my_coin_deposits: { Args: { p_token: string }; Returns: Json }
      my_coin_log: { Args: { p_token: string; p_user?: string }; Returns: Json }
      my_history: { Args: { p_token: string }; Returns: Json }
      my_withdrawal_requests: { Args: { p_token: string }; Returns: Json }
      place_bet: {
        Args: { p_amount: number; p_target: string; p_token: string }
        Returns: Json
      }
      save_withdraw_upi: {
        Args: { p_token: string; p_upi_id: string }
        Returns: Json
      }
      setup_admin: { Args: { p_id: string; p_pw: string }; Returns: undefined }
      submit_coin_deposit: {
        Args: {
          p_amount: number
          p_reference?: string
          p_token: string
          p_utr: string
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
