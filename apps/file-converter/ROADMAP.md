# ローカルファイル変換 リリースロードマップ

## Phase 0 · コア変換体験の完成 ✅

目的： サービスの核となる変換体験を安定させる

- [x] 主要変換機能の実装（画像・動画）
- [x] エラーハンドリング
- [x] 大容量ファイル対応（画像100MB・動画500MB）
- [x] スマホUI基本対応
- [x] 対応形式の整理
- [x] Vercel デプロイ
- [x] CI/CD（lint・typecheck・audit・license・bundle-size）

---

## Phase 1 · PWA対応

目的： アプリのように使える体験と、将来のオフライン利用基盤を作る

- [x] Next.js の PWA 対応（manifest.ts・service worker）
- [x] ホーム画面追加プロンプト
- [x] アプリアイコン（SVG）
- [ ] オフライン専用表示（未ログイン時の案内など）
- [x] キャッシュ戦略の整備（app shell キャッシュ）
- [ ] オフライン時に基本画面が表示されることを確認（スマホ実機で要検証）

---

## Phase 2 · 認証 🚧

目的： ユーザー識別の基盤を作る

- [ ] Supabase プロジェクト作成（Dashboard + Google Cloud Console 設定）
- [x] Google OAuth + メール OTP 認証（コード実装済み）
- [x] ログイン状態をヘッダーに表示（AuthButton）
- [x] 未ログインでも変換は使える
- [ ] Supabase の URL Configuration・Redirect URL 設定
- [ ] Vercel 環境変数設定（NEXT_PUBLIC_SUPABASE_URL / ANON_KEY）
- [ ] 本番動作確認（Google OAuth + OTP）

---

## Phase 3 · 無料プラン制限

目的： 無料ユーザーの上限を設け、ログインや課金の理由を作る

- [ ] Supabase DB に利用回数テーブル
- [ ] 変換前にサーバーで回数チェック
- [ ] 未ログイン：1日2回
- [ ] ログイン無料会員：1日5回
- [ ] UI に「今日あと○回」表示
- [ ] 上限到達時にログイン / 課金導線を表示

---

## Phase 4 · 課金（Stripe）

目的： 収益化と有料特典の提供

- [ ] Stripe Checkout 導入
- [ ] 月額プラン導入
- [ ] Webhook で Supabase のサブスク状態を更新
- [ ] 有料プラン：回数大幅緩和または無制限・広告なし
- [ ] 一定期間のオフライン利用権を端末に保存する仕組みを追加

---

## Phase 5 · マイページ

目的： ユーザーが自分の契約・利用状況を確認できるようにする

- [ ] 契約状況（未ログイン / 無料 / 有料）
- [ ] 今日の残り回数
- [ ] 保存プリセット
- [ ] Stripe Customer Portal へのリンク

---

## Phase 6 · SEO・LP強化

目的： 自然流入を増やす

- [ ] 個別用途ページ作成（「HEICをJPGに」「WebPをPNGに」など）
- [ ] OGP 設定
- [ ] FAQ 整備
- [ ] トップから各用途ページへの導線強化

---

## Phase 7 · 広告（無料プラン）

目的： 無料ユーザーからの追加収益

- [ ] Google AdSense 申請・設置
- [ ] 無料プランのみ広告表示
- [ ] 有料プランでは非表示
