-- ─────────────────────────────────────────────────────────────────────────────
-- subscriptions テーブル
-- Lemon Squeezy サブスクリプションと Supabase ユーザーを紐付ける
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE public.subscriptions (
  id                     uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lemon_subscription_id  text        NOT NULL UNIQUE,
  lemon_customer_id      text,
  lemon_variant_id       text,
  -- status: on_trial | active | paused | past_due | unpaid | cancelled | expired
  status                 text        NOT NULL DEFAULT 'inactive',
  renews_at              timestamptz,
  ends_at                timestamptz,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now()
);

-- インデックス
CREATE INDEX subscriptions_user_id_idx ON public.subscriptions(user_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- RLS（Row Level Security）
--
-- セキュリティ設計:
-- - ユーザーは自分のサブスク情報のみ読み取れる
-- - 書き込み（INSERT/UPDATE/DELETE）は service_role のみ
--   （= webhook ハンドラーのみが更新できる）
-- - anon・authenticated ロールからの書き込みは一切禁止
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- 読み取り: 自分のサブスク情報のみ
CREATE POLICY "Users can view own subscription"
  ON public.subscriptions
  FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT/UPDATE/DELETE のポリシーは設定しない
-- → service_role（RLS をバイパス）のみが書き込めることになる

-- ─────────────────────────────────────────────────────────────────────────────
-- updated_at を自動更新するトリガー
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER subscriptions_set_updated_at
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
