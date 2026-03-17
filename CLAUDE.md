# CLAUDE.md — mankai-services

Mankai Software の全アプリを収めるモノレポ。

## 構造

```
apps/
  file-converter/          画像・動画変換サービス（Next.js / Vercel）
  parking-fee-calculator/  駐車料金看板読取サービス（Next.js / Vercel）
  parking-reader/          駐車料金リーダー モバイルアプリ（Expo / EAS Build）
  api/                     Webhook 専用サーバー（Next.js / Vercel）
packages/
  auth/                    @mankai/auth — Supabase 認証一式
  billing/                 @mankai/billing — Lemon Squeezy 課金一式
  parking-shared/          @mankai/parking-shared — 駐車料金計算ロジック・型定義
supabase/
  migrations/              Supabase DB スキーマ定義（SQL）
```

## 新しいアプリを追加するとき

1. `apps/` に Next.js プロジェクトを作成
2. `package.json` の `dependencies` に `@mankai/auth` と `@mankai/billing` を追加
3. 以下をコピー不要で1行だけ書く：
   - `middleware.ts` → `import { updateSession } from "@mankai/auth/middleware"` で呼ぶ
   - `app/auth/callback/route.ts` → `export { GET } from "@mankai/auth/callback"`
4. `layout.tsx` の children を `<AuthProvider>` でラップ
5. `globals.css` に `@source "../../packages/auth/src/**/*.tsx"` を追加
6. Vercel プロジェクトの Root Directory を `apps/<app-name>` に設定

**車輪の再開発禁止**: 認証・課金ロジックは必ず `packages/` から import する。
実装前に `packages/` に既存コードがないか確認すること。

## 共通インフラ

| サービス | 用途 | 備考 |
|---|---|---|
| Supabase | 認証・DB | **全アプリで1プロジェクト共有** |
| Lemon Squeezy | 課金 | MOR のため消費税対応不要 |

- Webhook URL: `https://mankai-api.vercel.app/api/webhooks/lemon`（apps/api）
- Supabase マイグレーション: `supabase/migrations/` の SQL を Supabase Dashboard で実行

## セキュリティ — 全体共通ルール

### 環境変数
- `.env.local` はコミットしない（Gitleaks CI で検知・ブロック）
- `SUPABASE_SERVICE_ROLE_KEY` は `apps/api` のみで使用。`NEXT_PUBLIC_` を絶対につけない
- `LEMON_SQUEEZY_WEBHOOK_SECRET` は `apps/api` のみで使用。クライアントに渡さない
- 環境変数のプレフィックスで公開/非公開を判断する:
  - `NEXT_PUBLIC_*` → ブラウザに露出する（API キー等を入れない）
  - プレフィックスなし → サーバーサイドのみ

### Supabase
- `user.email` をログ出力・独自テーブルに保存しない。`user.id`（UUID）のみ使う
- 全テーブルに RLS を必ず有効化する
- `getSession()` ではなく `getUser()` を使う（サーバー検証済みデータ）
- Service Role Key（`SUPABASE_SERVICE_ROLE_KEY`）は webhook ハンドラーのみで使用

### 課金（Lemon Squeezy）
- Webhook は必ず署名検証してから処理する（`verifyWebhookSignature`）
- Webhook ハンドラーはペイロードをログ出力しない（顧客情報を含む）
- チェックアウト URL の `redirectUrl` は自サービスのオリジンのみ許可
- `user_id` を `custom_data` に埋め込む（メールアドレスではなく UUID）

### セキュリティヘッダー
- 全アプリで HSTS・X-Frame-Options・X-Content-Type-Options 等を設定（各 next.config.ts）
- file-converter のみ COOP/COEP が必要（ffmpeg.wasm の SharedArrayBuffer）

## ブランチ・コミット

- main 直接 push 禁止（CI で検知）
- conventional commits（`feat:` `fix:` `chore:` など）
- Node.js v20 必須（`source ~/.nvm/nvm.sh && nvm use 20`）
