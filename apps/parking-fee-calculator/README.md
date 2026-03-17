# 駐車料金リーダー

駐車場の料金看板を撮影し、「今から何時間停めたらいくらか」を素早く把握するためのアプリ。

現地で迷わないための道具として、料金ルールの整理・最大料金の適用条件・注意事項をわかりやすく表示する。

---

## セットアップ

### 必要なもの

- Node.js v18 以上（推奨: v20）
- npm

### 手順

```bash
# リポジトリをクローン
git clone https://github.com/RyotaTokuda/ParkingFeeCalculator.git
cd ParkingFeeCalculator

# 依存パッケージをインストール
npm install

# git hook を有効化（main への直接 push をブロック）
git config core.hooksPath .githooks

# 開発サーバーを起動
npm run dev
```

ブラウザで [http://localhost:3000](http://localhost:3000) を開く。

iPhone など同じ WiFi のデバイスからは `http://<MacのIPアドレス>:3000` でアクセス可能（`npm run dev` 起動時に表示される Network の URL を使う）。

---

## 画面構成

| パス | 画面 |
|---|---|
| `/` | トップ（アプリ説明・撮影ボタン） |
| `/upload` | 看板画像のアップロード・プレビュー |
| `/result` | 料金シミュレーション・注意事項の表示 |

---

## CI

| ワークフロー | タイミング | 内容 |
|---|---|---|
| Lint & Type Check | push / PR | ESLint・TypeScript 型チェック・npm audit |
| ライセンス検査 | push / PR | GPL 等の商用制限ライセンスを検出 |
| バンドルサイズ確認 | PR | ビルドサイズの記録・表示 |
| main 直接 push ガード | main への push | PR を経由しているか確認・警告 |
| Dependabot | 毎週月曜 | npm 依存パッケージの脆弱性チェック |

---

## ブランチ運用

```
main          # 常に動作する状態を保つ
feature/xxx   # 新機能
fix/xxx       # バグ修正
chore/xxx     # 設定・ドキュメント変更
```

- main への直接 push は禁止（git hook + CI で検知）
- 作業は必ずブランチを切り、PR 経由でマージする

---

## 技術スタック

- **Next.js 16** (App Router)
- **TypeScript**
- **Tailwind CSS**
- **npm**

将来的に追加予定:
- Supabase（データ保存・認証）
- Vercel（本番デプロイ）

---

## TODO（MVP 以降）

- [ ] Vercel へのデプロイ
- [ ] OCR による看板画像の自動解析
- [ ] 料金計算ロジックの精度向上（日跨ぎ・最大料金繰り返し）
- [ ] Supabase による解析結果の保存
- [ ] PWA 対応（オフライン・ホーム画面追加）
- [ ] iOS / Android アプリ化（React Native / Expo）
