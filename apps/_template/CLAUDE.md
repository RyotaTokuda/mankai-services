# CLAUDE.md — [アプリ名]

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

[アプリの説明]

## Stack

- Next.js 16 / Tailwind CSS v4 / TypeScript
- `@mankai/auth`（認証）・`@mankai/billing`（課金）← packages/ から import する
- Vercel デプロイ（Root Directory: `apps/[app-name]`）

## 判断基準

**確認してから進める**
- 技術スタック・認証・課金の設計変更
- 外部 API の本採用・依存ライブラリの追加

**確認せず進めてよい**
- 軽微な UI 調整・文言修正
- ROADMAP.md の更新

## このアプリ固有の制約

- [アプリ固有のルールをここに書く]
