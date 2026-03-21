# CLAUDE.md — file-converter

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

ブラウザ上でローカル処理のみで動作する、ファイル変換・圧縮・PDF整理サービス。
**ファイルの内容はサーバーに送らない**がこのサービスの核。設計上の制約でもある。

価値は「変換そのもの」ではなく、提出・納品・整理の作業を継続的に楽にすること。

ロードマップ → `ROADMAP.md`

## Stack

- Next.js 16 / Tailwind CSS v4 / TypeScript
- Canvas API（画像変換）・heic2any（HEIC変換）・ffmpeg.wasm（動画変換）
- pdf-lib（PDF操作）・jspdf（画像→PDF）
- `@mankai/auth`（認証）・`@mankai/ui`（UI基盤）← packages/ から import
- Stripe（課金）
- Vercel デプロイ（Root Directory: `apps/file-converter`）

## 環境

Node v20 必須（システムデフォルトは v16）。

```bash
source ~/.nvm/nvm.sh && nvm use 20
```

## コア原則

1. **ローカル処理**: ファイル本体をサーバーに送信しない。常に意識すること
2. **無料でも便利**: Free プランを露骨に不便にしない。単発利用は十分使える
3. **継続価値は有料**: プリセット保存・履歴・テンプレート・一括処理は Plus/Pro
4. **アップセルは文脈で**: 料金ページではなく「操作中に」導線を出す
5. **「アップロード」禁止**: UI文言で「アップロード中」は使わない。「端末内で処理中」「ブラウザ内で処理中」を使う

## プラン設計

3段階: Free / Plus / Pro
- 機能制御は `lib/plans/feature-gates.ts` の定義ベースで行う
- コンポーネント内にプラン分岐をベタ書きしない
- 年額を「おすすめ」として表示。Plus 年額が主役

## 課金

- **Stripe** を使用（Lemon Squeezy ではない）
- Checkout + Customer Portal + Webhook
- Webhook は `apps/api` で受信し `subscriptions` テーブルを更新
- アプリ側は `getPlanStatus` / `isPro` で判定するだけ

## 判断基準

**確認してから進める**
- 技術スタック・認証・課金の設計変更
- 外部 API の本採用・依存ライブラリの追加
- Git の破壊的操作・本番に影響する変更
- プラン設計・価格変更
- Stripe 商品/価格の変更

**確認せず進めてよい**
- 軽微な UI 調整・文言修正・命名改善
- ROADMAP.md の更新
- テンプレートの追加・修正

## セキュリティ制約

- ファイルのバイナリをサーバーに送らない（このアプリの根幹）
- `next.config.ts` の COOP/COEP ヘッダーを削除しない（ffmpeg.wasm の SharedArrayBuffer に必須）
- `app/auth/callback/route.ts` は `@mankai/auth/callback` の1行 re-export のみ。独自ロジックを書かない
- `middleware.ts` の `config` は静的解析のため各アプリで直接定義する（パッケージから import しない）
- 環境変数を追加したら `.env.local.example` も更新する
- Stripe の秘密鍵は `apps/api` のみで使用。このアプリには持たない

## データ保存方針

保存してよいもの: アカウント情報、プラン情報、Stripe顧客ID、プリセット設定、ジョブ履歴メタデータ、テンプレート定義
保存しないもの: ユーザーのファイル本体、変換後ファイル本体、OCR前後の原本

## ディレクトリ構成

```
app/
  (marketing)/          トップページ・料金ページ（LP系）
  (app)/                ワークスペース・アカウント・テンプレート
  auth/callback/        OAuth コールバック
  api/                  クライアント向けAPI（プラン状態取得等）
components/
  workspace/            ワークスペースUI（DropZone, ToolPanel, ResultPanel）
  marketing/            LP系コンポーネント
  shared/               共通UI（UpsellBanner, PlanBadge, LocalBadge）
lib/
  plans/                プラン定義・機能ゲート・価格定数
  tools/                変換ツール（image, pdf, video）
  services/             プリセット・履歴・バリデーション
```

## 実装時の注意

- プラン分岐をコンポーネント内にベタ書きしない → `feature-gates.ts` を参照
- ファイル処理ロジックと UI ロジックを分離する → `lib/tools/` に処理、`components/` に UI
- 後から新しい変換種別を追加しやすい構造にする
- 制限チェックは必ずクライアント側で行う（サーバー通信しない）
- 違反時は「何が制限に引っかかったか」＋「アップグレード導線」を出す
