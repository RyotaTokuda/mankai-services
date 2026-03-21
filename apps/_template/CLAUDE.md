# CLAUDE.md — {{APP_NAME}}

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

{{アプリの説明}}

## Stack

- Next.js 16 / Tailwind CSS v4 / TypeScript
- `@mankai/auth`（認証）・`@mankai/billing`（課金）・`@mankai/ui`（UI 基盤）← packages/ から import する
- Vercel デプロイ（Root Directory: `apps/{{app-name}}`）

## 判断基準

**確認してから進める**
- 技術スタック・認証・課金の設計変更
- 外部 API の本採用・依存ライブラリの追加
- Git の破壊的操作・本番に影響する変更

**確認せず進めてよい**
- 軽微な UI 調整・文言修正・命名改善

## セキュリティ — このアプリ固有の制約

- `app/auth/callback/route.ts` は `@mankai/auth/callback` の1行 re-export のみ。独自ロジックを書かない
- `middleware.ts` の `config` は静的解析のため各アプリで直接定義する（パッケージから import しない）
- 環境変数を追加したら `.env.local.example` も更新する
- {{アプリ固有のセキュリティルールをここに追加}}
