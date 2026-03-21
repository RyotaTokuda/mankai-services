# CLAUDE.md — mankai-services

Mankai Software の全アプリを収めるモノレポ。

> **新しいアプリを作るなら、先に [`SETUP_NEW_APP.md`](./SETUP_NEW_APP.md) を読むこと。**

## 構造

```
apps/
  _template/               新規アプリのテンプレート（コピーして使う）
  file-converter/          画像・動画変換サービス（Next.js / Vercel）
  parking-fee-calculator/  駐車料金看板読取サービス（Next.js / Vercel）
  parking-reader/          駐車料金リーダー モバイルアプリ（Expo / EAS Build）
  home-stock/              おうちストック — 消耗品管理アプリ（Next.js / Vercel）
  shouhyou-box/            証憑ボックス — 副業者向け証憑整理アプリ（Expo / EAS Build）
  shimedoki/               しめどき — 会議の締めどき通知アプリ（SwiftUI / iOS + watchOS）
  api/                     Webhook + OCR API サーバー（Next.js / Vercel）
packages/
  auth/                    @mankai/auth — Supabase 認証一式
  billing/                 @mankai/billing — 課金一式（Lemon Squeezy / Stripe / App Store / Google Play）
  ui/                      @mankai/ui — UI 基盤（tokens / components / a11y / ESLint preset）
  parking-shared/          @mankai/parking-shared — 駐車料金計算ロジック・型定義
supabase/
  migrations/              Supabase DB スキーマ定義（SQL）
```

## 新しいアプリを追加するとき

**`apps/_template/` をコピーして始める。** テンプレートには以下が全て含まれている:

1. `cp -r apps/_template apps/<app-name>`
2. `{{APP_NAME}}` `{{app-name}}` 等のプレースホルダーを置換
3. `npm install`（ルートで実行すればワークスペースが解決する）
4. Vercel プロジェクトの Root Directory を `apps/<app-name>` に設定
5. Vercel の Environment Variables に Supabase の値を設定

テンプレートに含まれているもの:
- `package.json`（@mankai/auth, @mankai/billing, @mankai/ui が依存済み）
- `next.config.ts`（セキュリティヘッダー設定済み）
- `middleware.ts`（Supabase セッションリフレッシュ設定済み）
- `app/auth/callback/route.ts`（OAuth コールバック設定済み）
- `app/layout.tsx`（AuthProvider + AuthButton + @mankai/ui tokens 設定済み）
- `app/page.tsx`（Server Component 実装例: getUser + isPro + UI コンポーネント + 課金導線）
- `app/api/example/route.ts`（API Route 実装例: 認証チェック + プラン判定 + RLS 付きデータ取得）
- `app/globals.css`（Tailwind + @mankai/ui tokens + packages/ のスキャン設定済み）
- `eslint.config.mjs`（jsx-a11y ルール設定済み）
- `postcss.config.mjs` / `tsconfig.json`（統一設定）
- `.env.local.example`（必要な環境変数とセットアップ手順）
- `CLAUDE.md`（アプリ固有ルールのテンプレート）

**車輪の再開発禁止**: 認証・課金・UI ロジックは必ず `packages/` から import する。
実装前に `packages/` に既存コードがないか確認すること。

## 共通インフラ

| サービス | 用途 | 備考 |
|---|---|---|
| Supabase | 認証・DB | **全アプリで1プロジェクト共有** |
| Lemon Squeezy | 課金（Web・デフォルト） | MOR のため消費税対応不要 |
| Stripe | 課金（Web・アプリによる） | file-converter 等で使用 |
| App Store | 課金（iOS） | StoreKit / Server Notifications V2（実装予定） |
| Google Play | 課金（Android） | Billing Library / RTDN（実装予定） |

- Webhook URL: `https://mankai-api.vercel.app/api/webhooks/lemon`（apps/api）
- Supabase マイグレーション: `supabase/migrations/` の SQL を Supabase Dashboard で実行

## 課金アーキテクチャ

全プラットフォームの購入結果は同じ `subscriptions` テーブルに統合される。

```
Web（Lemon Squeezy） → apps/api webhook → subscriptions (platform: "lemon")
Web（Stripe）         → apps/api webhook → subscriptions (platform: "stripe")  ← file-converter 等
iOS（App Store）      → apps/api webhook → subscriptions (platform: "apple")   ← 実装予定
Android（Google Play）→ apps/api webhook → subscriptions (platform: "google")  ← 実装予定
```

**どの課金プロバイダーを使うかはアプリごとに決める。** デフォルトは Lemon Squeezy。アプリ固有の CLAUDE.md に記載する。

プラン判定（`getPlanStatus` / `isPro`）はプラットフォーム横断で共通。
アプリ側は購入元を意識せず `isPro(supabase, userId)` だけ呼べばよい。

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

### 課金
- Webhook は必ず署名検証してから処理する
  - Lemon Squeezy: `verifyWebhookSignature`
  - Stripe: `stripe.webhooks.constructEvent`
- Webhook ハンドラーはペイロードをログ出力しない（顧客情報を含む）
- チェックアウト URL の `redirectUrl` / `success_url` は自サービスのオリジンのみ許可
- ユーザー紐付けは UUID で行う（メールアドレスではなく `user_id`）
- `STRIPE_SECRET_KEY` / `STRIPE_WEBHOOK_SECRET` は `apps/api` のみで使用。クライアントに渡さない

### セキュリティヘッダー
- 全アプリで HSTS・X-Frame-Options・X-Content-Type-Options 等を設定（各 next.config.ts）
- file-converter のみ COOP/COEP が必要（ffmpeg.wasm の SharedArrayBuffer）

### アクセシビリティ
- 全アプリで `@mankai/ui/a11y/eslint-config` を ESLint に追加する（テンプレートに設定済み）
- UI コンポーネントは `@mankai/ui` の Button / Input / Alert を優先使用する（a11y 属性が組み込み済み）

## ブランチ・コミット

- main 直接 push 禁止（CI で検知）
- conventional commits（`feat:` `fix:` `chore:` など）
- Node.js v20 必須（`source ~/.nvm/nvm.sh && nvm use 20`）
