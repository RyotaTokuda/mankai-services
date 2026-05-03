# CLAUDE.md — しめどき（Shimedoki）

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

会議・1on1・商談・雑談・集中作業の"終わらせどき"を Apple Watch の触覚通知で本人だけに伝えるアプリ。タイマーではなく「静かな締めどき」。

## Stack

- SwiftUI / iOS 17.0+ / watchOS 10.0+
- StoreKit 2（auto-renewable subscription）
- App Group（`group.com.mankai.shimedoki`）で iPhone ↔ Watch データ共有
- JSON + Codable（SwiftData は使わない）
- xcodegen（`project.yml`）でプロジェクト生成
- サーバー不要・認証不要・ローカルファースト

## 構造

```
Shared/          iPhone・Watch 共通（Models, Services）
Shimedoki/       iOS アプリ（MVVM）
ShimedokiWatch/  watchOS アプリ（MVVM）
ShimedokiTests/  ユニットテスト
```

## 判断基準

**確認してから進める**
- 技術スタック・課金の設計変更
- 外部 API の本採用・依存ライブラリの追加
- Git の破壊的操作

**確認せず進めてよい**
- 軽微な UI 調整・文言修正・命名改善

## セキュリティ — このアプリ固有の制約

- サーバーサイドなし。全てローカル処理
- App Group のデータは端末内に閉じる
- StoreKit 2 のトランザクション検証はクライアントサイドのみ（MVP）
- ユーザーの個人情報（メール等）は一切取得・保存しない

## 課金

- StoreKit 2 auto-renewable subscription
- Product IDs: `shimedoki.plus.monthly`, `shimedoki.plus.yearly`
- ペイウォール表示: 4件目テンプレ作成時 / カレンダー連携タップ時 / 履歴フル表示タップ時

## ストア公開チェックリスト（アプリ固有）

> 共通ガイド → `/STORE_SUBMISSION_GUIDE.md`

### 必須対応

- [ ] 「購入を復元」ボタンが Settings 画面に存在する
- [ ] サブスクリプション画面に Apple の要求する定型文を含む:
  - 自動更新の説明
  - 利用規約・プライバシーポリシーへのリンク
  - 解約方法（設定 > Apple ID > サブスクリプション）
- [ ] 無料プランでも基本機能が使える（テンプレート3件、基本履歴表示）
- [ ] watchOS Extension が正しく動作する（Apple Watch 実機テスト済み）
- [ ] iPhone-Watch 間のデータ同期が安定動作する
- [ ] 通知パーミッション拒否時にクラッシュしない
- [ ] `store/metadata-ja.md` を作成する（ストアメタデータ）
- [ ] StoreKit Configuration ファイル（`.storekit`）で Sandbox テスト完了
- [ ] Xcode プロジェクトの Signing & Capabilities が Apple Developer アカウントに紐付いている

### サードパーティログインについて

このアプリはサーバー不要・認証不要のローカルファーストアプリのため:
- Sign in with Apple は**不要**（サードパーティログインを使用していないため）
- アカウント削除機能も**不要**（アカウントが存在しないため）

### Info.plist の UsageDescription

| キー | 設定値 | 備考 |
|---|---|---|
| `NSUserNotificationsUsageDescription` | 会議の締めどきを通知でお知らせするために使用します | 触覚通知に必要 |
| `NSCalendarsUsageDescription` | カレンダーから予定を読み取り、テンプレートに反映するために使用します | Plus 機能で使用する場合 |

**不要なパーミッションキーは削除する。** カメラ・位置情報・マイク等を使わないなら残さない。

### 暗号化

- `ITSAppUsesNonExemptEncryption`: `false`（独自暗号化なし、ローカル保存のみ）
- Info.plist に設定する

### IAP 申請情報

| 商品 | Product ID | 種別 | 価格 |
|---|---|---|---|
| Plus 月額 | shimedoki.plus.monthly | Auto-Renewable | （要定義） |
| Plus 年額 | shimedoki.plus.yearly | Auto-Renewable | （要定義） |

Subscription Group: `shimedoki.plus`

### 審査メモに書くこと

1. アプリの主な使い方: 「テンプレートを作成 → セッション開始 → Apple Watch で触覚通知を受け取る」
2. Apple Watch が必要: Watch アプリの触覚通知がコア機能
3. 課金テスト: サンドボックス環境で Plus プランの購入が可能
4. ログイン不要: ローカルファーストのため、デモアカウントは不要

### App Privacy Details（iOS 栄養ラベル）

| データ種類 | 収集 | 利用目的 | ユーザー紐付 | トラッキング |
|---|---|---|---|---|
| 購入履歴（StoreKit） | はい | アプリ機能 | はい | いいえ |

**このアプリはユーザーデータをほとんど収集しない。** サーバー通信なし、認証なし、アナリティクスなし（MVP）。

### watchOS 固有の審査ポイント

- [ ] Watch アプリが iPhone なしでも起動する（必須ではないが推奨）
- [ ] Watch の UI が watchOS HIG に準拠している
- [ ] Complication / Widget がある場合、正しいデータを表示する
- [ ] Watch アプリのスクリーンショットも用意する（Apple Watch 画面サイズ）
