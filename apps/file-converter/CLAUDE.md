# CLAUDE.md — file-converter

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

ブラウザ内だけで動作する完全ローカル処理のファイル変換サービス。
**ファイルの内容はサーバーに送らない**がこのサービスの核。設計上の制約でもある。

ロードマップ → `ROADMAP.md`

## Stack

- Next.js 16 / Tailwind CSS v4 / TypeScript
- ffmpeg.wasm（動画変換）・heic2any（HEIC変換）・Canvas API（画像変換）
- `@mankai/auth`（認証）・`@mankai/billing`（課金）← packages/ から import する
- Vercel デプロイ（Root Directory: `apps/file-converter`）

## 環境

Node v20 必須（システムデフォルトは v16）。

```bash
source ~/.nvm/nvm.sh && nvm use 20
```

## 判断基準

**確認してから進める**
- 技術スタック・認証・課金の設計変更
- 外部 API の本採用・依存ライブラリの追加
- Git の破壊的操作・本番に影響する変更

**確認せず進めてよい**
- 軽微な UI 調整・文言修正・命名改善
- ROADMAP.md の更新

## このアプリ固有のセキュリティ制約

- ファイルのバイナリをサーバーに送らない（このアプリの根幹）
- `next.config.ts` の COOP/COEP ヘッダーを削除しない（ffmpeg.wasm の SharedArrayBuffer に必須）
- `app/auth/callback/route.ts` は `@mankai/auth/callback` の1行 re-export のみ。独自ロジックを書かない
- `middleware.ts` の `config` は静的解析のため各アプリで直接定義する（パッケージから import しない）
