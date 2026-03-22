# CLAUDE.md — 痛み手帳 (itami-techo)

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

不調の瞬間を Apple Watch または iPhone からすぐに記録し、
あとから自分の傾向を振り返り、通院時にも使える形にするセルフログアプリ。
App Store サブタイトル: 「だるさ・めまい・不調をすぐ記録」

**このアプリは医療アプリではない。**
診断・治療提案・疾病リスク判定・原因断定は一切行わない。
記録・表示・振り返り・相関の示唆に限定する。

## Stack

- Swift / SwiftUI / iOS 17+ / watchOS 10+
- StoreKit 2（月額 ¥390 / 年額 ¥3,900 / 7日トライアル）
- HealthKit（睡眠・心拍・歩数・安静時心拍・心拍変動・呼吸数・ワークアウト）
- CoreLocation + WeatherKit or 外部 API（天気・気圧・空気質）
- App Group（`group.com.mankai.itami-techo`）でデバイス間データ共有
- WatchConnectivity（`WCSession`）でリアルタイム同期
- JSON + Codable + NSFileCoordinator（並行アクセス安全）
- xcodegen（project.yml → .xcodeproj 生成）
- ローカル保存中心、将来 CloudKit 移行しやすい抽象化

## ディレクトリ構成

```
apps/itami-techo/
  Shared/              iOS + watchOS 共有コード
    Models/            データモデル（Codable 型）
    Services/          Store・同期・通知等のサービス層
    Constants.swift    App Group ID・Product ID 等
    Strings.swift      法規制対応の文言一元管理
  ItamiTecho/             iOS アプリターゲット
    App/               @main エントリポイント
    Resources/         Assets・StoreKit 設定
    ViewModels/        MVVM の ViewModel 層
    Views/             画面別に整理
    Services/          iOS 固有サービス（PDF生成等）
  ItamiTechoWatch/        watchOS アプリターゲット
    App/               @main エントリポイント
    Resources/         Assets
    ViewModels/        Watch 用 ViewModel
    Views/             Watch 画面
    Services/          Watch 固有サービス（Haptics等）
  ItamiTechoTests/        ユニットテスト
  project.yml          xcodegen 設定
```

## 判断基準

**確認してから進める**
- 技術スタック・認証・課金の設計変更
- 外部 API の本採用・依存ライブラリの追加
- HealthKit / CoreLocation の権限要求タイミング変更
- 法規制に関わる文言の追加・変更
- Git の破壊的操作・本番に影響する変更

**確認せず進めてよい**
- 軽微な UI 調整・文言修正・命名改善

## 法規制ルール（最重要）

### 絶対禁止表現
- 診断します / 病気がわかります / 原因を特定します
- 治します / 改善します / 予防します
- 医師の代わりになります
- AI が健康状態を判断します
- 頭痛になることを予測します
- この通知で不調を防げます

### 許容表現
- 記録できます / 振り返れます
- 傾向が見える可能性があります
- 通院時にまとめやすくなります
- 気圧が下がった日に記録が多い傾向があります
- 必要な時だけ残せます

### 必須注意書き（アプリ内 + ストア）
- 本アプリは診断、治療、予防を目的としたものではありません
- 本アプリの内容は医療上の判断に代わるものではありません
- 体調に不安がある場合は医療機関に相談してください
- 表示される傾向は記録データに基づく参考情報です

### 文言管理
全ての UI 文言・通知文言は `Shared/Strings.swift` に一元管理する。
法務レビュー時に一括確認できるようにするため、
View 内にハードコードされた文言を置かない。

## 環境データ取得方針

### 取得元

| データ | 取得元 | 備考 |
|--------|--------|------|
| 気圧（リアルタイム） | `CMAltimeter`（端末内蔵センサー） | API不要・位置不要・オフライン可 |
| 気圧変化量（3h） | CMAltimeter 履歴から自前計算 | 直近の気圧をローカル保存して差分算出 |
| 天気・気温・湿度 | WeatherKit（Apple純正） | APIキー不要・Watch対応・Developer Programに含まれる |
| 空気質・PM2.5 | WeatherKit（Apple純正） | カバー外地域は nil |
| 位置情報 | CoreLocation（When In Use） | 記録時のみ取得・市区町村レベルに丸めて保存 |

### 取得フロー

1. ユーザーが「記録」を押す
2. `CMAltimeter` → 気圧を即取得（オフライン可）
3. `CoreLocation` → 現在地を取得（When In Use）
4. `WeatherKit`（位置情報を渡す） → 天気・気温・湿度・AQI・PM2.5
5. 全て `EnvironmentSnapshot` にまとめて記録に紐付け

### 補完ルール

- 位置OK + WeatherKit一時失敗 → `needsBackfill = true` で保存し、次回起動時に24h以内なら補完
- 位置NG（権限なし） → 補完しない（どこにいたか不明）
- 24h超過 → 補完しない（精度が落ちるため諦め）
- 気圧はセンサーから取得するため、ほぼ常に取得可能

### 権限リクエスト

iOS のシステムダイアログの**前に**カスタム事前説明画面を表示する。
- 許可した場合 / 許可しない場合の挙動の違いを明示
- 気圧はセンサーから取れるので許可なしでも価値があることを伝える
- プライバシー配慮（丸め保存・外部送信なし）を明示
- 「あとで設定する」でスキップ可能
- 文言は全て `Strings.Permission` で管理

## 設計上の決定事項

- 1レコード = 1症状。複数症状が同時に来た場合は別々に記録する（Watch の最短動線を優先）
- 過去日の追加記録は症状+強さ+メモのみ。環境データは nil（位置が不明なため）
- KPI 計測は Phase 1 では App Store Connect のみ。必要に応じて後から Analytics を検討
- プライバシーポリシーは Mankai Software サイトの既存ページに痛み手帳の内容を追記

## セキュリティ

- Health データはローカル保存のみ。外部送信しない
- 位置情報は市区町村レベルに丸めて保存（`locationApprox`）
- PII（個人を特定できる情報）をログ出力しない
- `.env` 相当の秘密情報は不要（サーバーレス設計）
- StoreKit はクライアント側検証（MVP）

## shimedoki からの改善点

| 問題 | 対策 |
|------|------|
| 同時書き込み保護なし | `NSFileCoordinator` で排他制御 |
| WatchConnectivity 未使用 | `WCSession.transferUserInfo` で即時同期 |
| iPhone 側が再読み込みしない | `scenePhase == .active` で必ず reload |
| JSON 破損時リカバリなし | `.bak` バックアップ + フォールバック |
| App Group fallback が silent | `assertionFailure` + ログで早期検知 |

## 課金設計

- 月額: ¥390
- 年額: ¥3,900（10ヶ月分）
- 7日無料トライアル
- Product ID: `itamitecho.premium.monthly` / `itamitecho.premium.yearly`
- Subscription Group: `itamitecho.premium`

### ペイウォール表示タイミング
1. 記録 5件到達時
2. 14日超の履歴閲覧時
3. PDF/CSV 出力時
4. 環境分析の詳細閲覧時
5. Health 傾向比較の詳細閲覧時
6. 月末レポート閲覧時
7. 通院向け要約作成時

### 無料プラン
- Watch/iPhone 記録、基本症状6種、薬記録、落ち着いた記録
- 直近14日履歴、カレンダー、基本集計
- 記録詳細の環境・Health 簡易表示
- 基本コンプリケーション、基本文脈通知
- カスタム症状 2件まで

### プレミアムプラン
- 無制限履歴、月次レポート、PDF/CSV
- 曜日別・時間帯別傾向、強さ分布
- カスタム症状・薬タグ無制限
- Health 高度分析、環境高度分析
- 通院向け要約、高度コンプリケーション
- Siri ショートカット、通知感度調整、個別最適化通知
- 先月比較・長期比較

## 実装フェーズ

### Phase 1: コア記録
- データモデル全型定義
- RecordStore（NSFileCoordinator 付き）
- WatchConnectivity 同期基盤
- Apple Watch 最短記録フロー（症状→強さ→完了）
- iPhone 記録 UI
- 履歴一覧 / カレンダー / 詳細 / 編集・削除
- 基本設定画面
- 法的注意書き画面
- オンボーディング

### Phase 2: 環境・Health 連携
- HealthKit 連携（読み取り権限・データ取得）
- 天気・気圧・気温・湿度・空気質取得
- EnvironmentSnapshot のスナップショット保存
- HealthSnapshot の保存
- 記録詳細への環境・Health 表示

### Phase 3: 分析・レポート
- 傾向分析画面（症状別件数・時間帯・曜日）
- 環境分析画面（気圧・天気・空気質との相関ヒント）
- Health 分析画面（睡眠・心拍との並列表示）
- 通院向けレポート画面
- PDF / CSV 出力

### Phase 4: 課金・通知
- StoreKit 2 プレミアム課金
- ペイウォール UI + 導線
- 無料/プレミアム機能ゲート
- 予兆通知（気圧変化・天気急変・気温差・空気質悪化）
- 文脈通知ロジック

### Phase 5: 仕上げ
- iPhone ウィジェット / ロック画面ウィジェット
- Siri ショートカット
- 高度コンプリケーション / Smart Stack
- 文言の最終一元レビュー構造
- パフォーマンス最適化

## ストア公開チェックリスト（アプリ固有）

> 共通ガイド → `/STORE_SUBMISSION_GUIDE.md`

### 必須対応（最重要: 医療系リジェクトリスク）

このアプリは**健康データを扱う**ため、Apple の審査が特に厳しい。
Guideline 1.4.1（医療用途）/ 5.1.3（HealthKit）に抵触しないことを徹底する。

- [ ] **法規制文言の最終確認**: `Shared/Strings.swift` の全文言が「絶対禁止表現」に該当しないこと
- [ ] **ストア説明文の法規制確認**: 診断・治療・予防を示唆する表現がないこと
- [ ] **必須注意書き**がアプリ内に表示されていること:
  - 「本アプリは診断、治療、予防を目的としたものではありません」
  - 「体調に不安がある場合は医療機関に相談してください」
- [ ] ストア説明文にも同様の注意書きを記載する
- [ ] 「購入を復元」ボタンが Settings 画面に存在する
- [ ] サブスクリプション画面に Apple の要求する定型文を含む
- [ ] 無料プランでも基本的な記録機能が使える
- [ ] watchOS Extension が正しく動作する
- [ ] `store/metadata-ja.md` を作成する（ストアメタデータ）
- [ ] StoreKit 2 の Sandbox テスト完了

### HealthKit 固有の審査ポイント（Apple 5.1.3）

**HealthKit を使うアプリは審査が厳格。以下を全て満たすこと。**

- [ ] HealthKit Entitlement が有効（`ItamiTecho.entitlements` に設定）
- [ ] HealthKit の利用目的を明確に記載:
  - Info.plist: `NSHealthShareUsageDescription`（「睡眠・心拍・歩数などの健康データを読み取り、不調との傾向を表示するために使用します」）
- [ ] HealthKit データを外部に送信しない（ローカル保存のみ — セキュリティセクションと整合）
- [ ] HealthKit データの利用目的がアプリの主機能に直結している
- [ ] HealthKit データを広告・マーケティング目的で使用しない
- [ ] HealthKit データを iCloud や外部サーバーに保存しない（Apple のルール）
- [ ] Health アプリとの連携が正しく動作する（読み取り権限の要求・データ取得）
- [ ] 権限拒否時にクラッシュせず、HealthKit なしでもコア機能（記録・閲覧）が使える

### 位置情報・環境データの審査ポイント

- [ ] `NSLocationWhenInUseUsageDescription` が設定されている:
  - 「記録時の天気・気圧データを取得するために現在地を使用します。位置情報は市区町村レベルに丸めて保存され、外部に送信されません」
- [ ] 位置情報の権限拒否時にクラッシュしない（気圧はセンサーから取得可能と案内）
- [ ] WeatherKit の利用が App ID の Capabilities に設定されている
- [ ] CMAltimeter（気圧センサー）は権限不要だが、対応端末でのみ動作することを考慮

### サードパーティログインについて

このアプリはサーバー不要・認証不要のローカルファーストアプリのため:
- Sign in with Apple は**不要**（サードパーティログインを使用していないため）
- アカウント削除機能も**不要**（アカウントが存在しないため）

### 暗号化

- `ITSAppUsesNonExemptEncryption`: `false`（独自暗号化なし、ローカル保存のみ）
- Info.plist に設定する

### IAP 申請情報

| 商品 | Product ID | 種別 | 価格 |
|---|---|---|---|
| Premium 月額 | itamitecho.premium.monthly | Auto-Renewable | ¥390/月 |
| Premium 年額 | itamitecho.premium.yearly | Auto-Renewable | ¥3,900/年 |

Subscription Group: `itamitecho.premium`
無料トライアル: 7日間

### 審査メモに書くこと

1. アプリの主な使い方: 「Apple Watch / iPhone で不調を即記録 → 傾向を振り返る → 通院時にレポートを見せる」
2. **重要: 本アプリは医療機器ではなく、診断・治療・予防を目的としない。** セルフログ・記録整理ツールである
3. Apple Watch: Watch アプリの即記録がコア機能
4. HealthKit: 睡眠・心拍等を読み取り、不調との傾向表示に使用（書き込みは行わない）
5. 位置情報: 天気・気圧データ取得のため When In Use で使用。市区町村レベルに丸めて保存
6. 課金テスト: サンドボックス環境で Premium プランの購入が可能（7日トライアル付き）
7. ログイン不要: ローカルファーストのため、デモアカウントは不要

### App Privacy Details（iOS 栄養ラベル）

| データ種類 | 収集 | 利用目的 | ユーザー紐付 | トラッキング |
|---|---|---|---|---|
| 健康データ（HealthKit） | はい | アプリ機能 | はい | いいえ |
| 位置情報（おおよそ） | はい | アプリ機能 | はい | いいえ |
| 購入履歴（StoreKit） | はい | アプリ機能 | はい | いいえ |

**HealthKit データの取り扱いは特に正確に申告する。** 虚偽申告は即リジェクト。

### watchOS 固有の審査ポイント

- [ ] Watch アプリが iPhone なしでも起動する（基本記録は可能にする）
- [ ] Watch の UI が watchOS HIG に準拠している
- [ ] Complication がある場合、正しいデータを表示する
- [ ] Watch アプリのスクリーンショットも用意する
