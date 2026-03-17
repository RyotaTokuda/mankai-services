-- ─────────────────────────────────────────────────────────────────────────────
-- webhook_events テーブル
-- Webhook の冪等性を保証するためのイベント記録テーブル
--
-- Lemon Squeezy は同一イベントを複数回送信することがある。
-- このテーブルに処理済みイベント ID を記録し、重複処理を防ぐ。
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE public.webhook_events (
  -- "{subscription_id}:{event_name}" の複合キー
  id         text        PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- RLS
--
-- 読み書きすべて service_role のみ。
-- ユーザーが自分の webhook 処理履歴を読む必要はない。
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.webhook_events ENABLE ROW LEVEL SECURITY;

-- ポリシーなし = service_role のみアクセス可能

-- ─────────────────────────────────────────────────────────────────────────────
-- 古いイベントを定期削除（30日以上前のものは不要）
-- Supabase Dashboard → Database → Scheduled Functions で設定可能
-- ─────────────────────────────────────────────────────────────────────────────
-- DELETE FROM public.webhook_events WHERE created_at < now() - interval '30 days';
