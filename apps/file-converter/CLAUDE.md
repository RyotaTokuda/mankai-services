# CLAUDE.md

## Project

ブラウザ内だけで動作する完全ローカル処理のファイル変換サービス。
**ファイルの内容はサーバーに送らない**がこのサービスの核。設計上の制約でもある。

ロードマップ → ROADMAP.md

## Stack

- Next.js 16 / Tailwind CSS v4 / TypeScript
- ffmpeg.wasm（動画変換）・heic2any（HEIC変換）・Canvas API（画像変換）
- Vercel デプロイ
- 将来：Supabase Auth・Stripe・PWA

## 環境

Node v20 必須（システムデフォルトは v16）。

```bash
source ~/.nvm/nvm.sh && nvm use 20
```

## ブランチ・コミット

- main 直接 push 禁止。feature / fix / chore ブランチで作業
- conventional commits（`feat:` `fix:` `chore:` など）

## 判断基準

**確認してから進める**
- 技術スタック・認証・課金の設計変更
- 外部 API の本採用・依存ライブラリの追加
- Git の破壊的操作・本番に影響する変更

**確認せず進めてよい**
- 軽微な UI 調整・文言修正・命名改善
- README / ROADMAP の更新

## セキュリティ

### 全般
- ファイルのバイナリをサーバーに送らない
- 新ライブラリ追加時はライセンスを確認（GPL系は CI で禁止）
- `npm audit --audit-level=high` を CI で実行
- シークレットスキャン（Gitleaks）を CI で実行 → 環境変数・APIキーをコードに書かない

### 認証（Supabase Auth）
- `user.email` を `console.log` やカスタム DB テーブルに書かない
  → 必ず `user.id`（UUID）だけを使う
- セッショントークンは `localStorage` に保存しない
  → `@supabase/ssr` が httpOnly Cookie で管理する（変更禁止）
- `getSession()` を信頼しない → `getUser()` でサーバー検証済みデータを取得する
- 全 Supabase テーブルに RLS（Row Level Security）を必ず有効化
- OAuth コールバックのリダイレクト先は相対パス（`/` 始まり）のみ許可
  → `app/auth/callback/route.ts` で検証済み

### セキュリティヘッダー（next.config.ts）
- HSTS・X-Frame-Options・X-Content-Type-Options・Referrer-Policy・Permissions-Policy を全ルートに適用
- COOP/COEP は ffmpeg.wasm の SharedArrayBuffer に必要 → 削除しない
