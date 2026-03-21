# デプロイ設計・運用書 — 車の維持費シミュレーター

## 方針

`kuraberu-lab.com/tools/car-cost/` のサブディレクトリとして公開する。
リバースプロキシやサーバーは使わず、**Next.js の静的エクスポートを Astro サイトのビルド成果物にマージ**する方式。

## なぜこの方式か

- シミュレーターは 100% クライアントサイド計算（API・DB なし）
- Next.js の `output: 'export'` で完全な静的 HTML/CSS/JS を生成できる
- Astro サイト（Cloudflare Pages）の `dist/site/tools/car-cost/` にコピーするだけ
- リバースプロキシ不要、追加インフラ不要、追加ドメイン不要

## アーキテクチャ

```
開発（monorepo: mankai-apps）          公開（web-media-engine）
┌──────────────────────┐          ┌──────────────────────────┐
│ apps/car-cost-simulator │          │ dist/site/               │
│   ↓ next build (export) │          │   ├── index.html         │ ← Astro 記事
│   → out/               │ ──copy──→│   ├── articles/...       │
│     ├── index.html      │          │   └── tools/             │
│     ├── _next/...       │          │       └── car-cost/      │ ← シミュレーター
│     └── ...             │          │           ├── index.html  │
└──────────────────────┘          │           └── _next/...   │
                                    └──────────────────────────┘
                                      ↓
                                    Cloudflare Pages
                                    kuraberu-lab.com
```

## セットアップ手順

### 1. Next.js を静的エクスポート対応にする

`apps/car-cost-simulator/next.config.ts` に以下を追加:

```ts
const nextConfig: NextConfig = {
  output: 'export',           // 静的 HTML を出力
  basePath: '/tools/car-cost', // サブディレクトリ対応
  // ... 既存の headers() 等
};
```

> `basePath` を設定すると、Next.js が生成するアセットパス（`_next/...`）や
> `<Link>` のパスが自動的に `/tools/car-cost/` 始まりになる。

### 2. ビルド確認

```bash
# mankai-apps ルートで
source ~/.nvm/nvm.sh && nvm use 20
npm run build --workspace=apps/car-cost-simulator

# out/ ディレクトリに静的ファイルが生成される
ls apps/car-cost-simulator/out/
```

### 3. web-media-engine にコピー用スクリプトを追加

`web-media-engine/scripts/sync-tools.sh`:

```bash
#!/bin/bash
# car-cost-simulator の静的ビルドを Astro サイトに同期
set -euo pipefail

SIMULATOR_DIR="../../mankai-apps/apps/car-cost-simulator"
TARGET_DIR="./public/tools/car-cost"

# ビルド
echo "Building car-cost-simulator..."
(cd "$SIMULATOR_DIR" && npm run build)

# 同期
echo "Syncing to $TARGET_DIR..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -r "$SIMULATOR_DIR/out/." "$TARGET_DIR/"

echo "Done. Files synced to $TARGET_DIR"
```

> `public/tools/car-cost/` に置くと、Astro ビルド時に `dist/site/tools/car-cost/` に
> そのままコピーされる（Astro の public ディレクトリの仕様）。

### 4. CI（GitHub Actions）での自動化

`web-media-engine/.github/workflows/deploy-site.yml` に以下を追加:

```yaml
on:
  push:
    branches: [master]
    paths:
      - 'content/published/**'
      - 'site/**'
      - 'public/tools/**'     # ← 追加
      - 'astro.config.mjs'
      - 'package.json'
```

**手動デプロイフロー（当面はこれで運用）:**

1. `mankai-apps` で car-cost-simulator を開発・修正
2. `web-media-engine` で `bash scripts/sync-tools.sh` を実行
3. `git add public/tools/ && git commit` → push → CI がデプロイ

**将来の自動化案（必要になったら）:**

- mankai-apps 側の CI で `out/` をアーティファクトとして publish
- web-media-engine 側の CI でダウンロードしてデプロイ
- または Git submodule で参照

## ディレクトリ構成（最終形）

```
web-media-engine/
  public/
    tools/
      car-cost/          ← Next.js 静的エクスポートの成果物
        index.html
        _next/
          static/
            chunks/...
            css/...
    tracking.js
  site/                  ← Astro ソース（既存）
  dist/site/             ← ビルド成果物（Cloudflare Pages にデプロイ）
```

## 開発時のローカル確認

```bash
# シミュレーター単体（開発中はこちらが速い）
cd mankai-apps
npm run dev --workspace=apps/car-cost-simulator
# → http://localhost:3000 で確認（basePath なしで表示される）

# 統合確認（公開前の最終チェック）
cd web-media-engine
bash scripts/sync-tools.sh
npm run dev:site
# → http://localhost:4321/tools/car-cost/ で確認
```

## 注意事項

### basePath の影響

- `next dev` 時も `/tools/car-cost/` がベースパスになる
- 開発時に `http://localhost:3000/tools/car-cost/` でアクセスする必要がある
- これが煩わしい場合は、`next.config.ts` で環境変数による切替が可能:

```ts
basePath: process.env.NODE_ENV === 'production' ? '/tools/car-cost' : '',
```

### 静的エクスポートの制約

- `output: 'export'` では以下が使えない:
  - API Routes（`app/api/`）→ このアプリでは不使用なので問題なし
  - Server Components のデータフェッチ → 不使用なので問題なし
  - middleware.ts → 既に削除済みなので問題なし
  - Image Optimization（`next/image`）→ 使用していないので問題なし
- **このアプリは全てクライアントサイドで完結しているため、制約に一切抵触しない**

### auth/callback ルートについて

テンプレートから残っている `app/auth/callback/route.ts` は静的エクスポートと
互換性がない可能性がある。MVP では認証不要なので削除する。

### キャッシュ戦略

- `_next/static/` 以下のファイルはハッシュ付きファイル名なので、
  Cloudflare Pages のデフォルトキャッシュ（永続）で問題ない
- `index.html` は Cloudflare Pages が自動的に短いキャッシュを設定する

## 将来の拡張

### 別のツールを追加する場合

同じパターンで `public/tools/<tool-name>/` に配置するだけ。

```
public/tools/
  car-cost/        ← 車の維持費シミュレーター
  insurance-calc/  ← 保険料計算（将来）
  loan-compare/    ← ローン比較（将来）
```

### 認証・DB が必要になった場合

静的エクスポートでは対応できないため、その時点で:
- A案: サブドメイン `car-cost.kuraberu-lab.com` に切替（リダイレクト設定）
- B案: Cloudflare Workers でリバースプロキシを追加

**現時点では考えなくてよい。必要になった時に検討する。**
