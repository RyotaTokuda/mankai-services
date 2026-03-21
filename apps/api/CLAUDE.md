# CLAUDE.md — api

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

Lemon Squeezy / Stripe の Webhook を受信し、Supabase のサブスクリプション状態を更新する専用サーバー。
UI は一切持たない。API エンドポイントのみ。

## Stack

- Next.js 16（API Routes のみ使用）
- `@mankai/auth`（admin クライアント）
- `@mankai/billing`（webhook 検証・処理）
- Vercel デプロイ（Root Directory: `apps/api`）

## セキュリティ — このアプリ固有の制約

- `SUPABASE_SERVICE_ROLE_KEY` を使う唯一のアプリ。他のアプリには絶対に追加しない
- Webhook ハンドラーはペイロードをログ出力しない（顧客情報を含む）
- 署名検証に失敗したリクエストは 400 で返す（500 にすると LS がリトライし続ける）
- 新しいエンドポイントを追加するときは必ず認証・認可を検討する

## エンドポイント

| Method | Path | 説明 |
|---|---|---|
| POST | `/api/webhooks/lemon` | Lemon Squeezy Webhook 受信 |
| POST | `/api/webhooks/stripe` | Stripe Webhook 受信 |
