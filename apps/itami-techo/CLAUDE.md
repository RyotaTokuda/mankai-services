# CLAUDE.md — 痛み手帳 (itami-techo)

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

不調の瞬間を Apple Watch または iPhone からすぐに記録し、
あとから自分の傾向を振り返り、通院時にも使える形にするセルフログアプリ。

### アプリ名（言語別）
| 言語 | アプリ名 | 備考 |
|------|---------|------|
| 日本語 | 痛み手帳 | 確定 |
| 英語 | Symptom Log | 採用（Pain Diary は不採用） |
| 簡体字 | 症状日记 | 暫定 |
| 繁体字 | 症狀日記 | 暫定 |

`S.App.name` は `L()` で4言語に対応済み。`AppLanguage.current` が端末言語を自動判定する。

App Store サブタイトル: 「だるさ・めまい・不調をすぐ記録」

**このアプリは医療アプリではない。**
診断・治療提案・疾病リスク判定・原因断定は一切行わない。
記録・表示・振り返り・相関の示唆に限定する。

## 多言語対応

### アーキテクチャ
- `Shared/LocalizationSupport.swift` — `AppLanguage` enum + `L()` 関数
- `Shared/Strings.swift` — 全文言を `L(ja:en:zhHans:zhHant:)` で管理
- `AppLanguage.current` は `Locale.preferredLanguages` から起動時に1回評価（`static let` でキャッシュ）

### サポート言語
| コード | 言語 |
|--------|------|
| `ja` | 日本語 |
| `en` | English |
| `zh-Hans` | 简体中文 |
| `zh-Hant` | 繁體中文 |

### 翻訳の追加・修正方法
1. `Strings.swift` の該当 `L()` 呼び出しを編集する
2. `static let` ではなく `static var` （computed property）になっている
3. 配列型（`weekdayLabels` 等）は `switch AppLanguage.current` で切り替え
4. フォーマット関数は switch を関数内に持つ
5. **法的注意書き（`S.Legal`）は全言語で原意が変わらないこと**

### 法規制チェック（多言語版）
`Shared/Strings.swift` の `S.Legal.*` および `S.Report.disclaimer` / `mohWarning` を全言語でレビューする。
禁止表現（診断・治療・予防・原因断定）が混入していないこと。

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

## 開発ルール

**仕様書を正とする、実機を正としない。必ず仕様書を変更する。**

- 実機・シミュレーターで挙動が仕様と異なる場合、仕様書（この CLAUDE.md）を正として実装を直す
- 実機動作が「そっちの方が良い」と感じても、まず仕様書を更新してから実装を変更する
- 仕様書を変更せずに実装だけ変えることは禁止
- 動作確認の前に想定する仕様を文書化してから確認する

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

### UX 仕様

#### 症状ボタン
- minHeight: 58pt、cornerRadius: 12pt
- 選択状態: accentColor 15% 背景 + 2pt border
- 非選択: systemGray6 背景

#### 「落ち着いた」の記録方法（4つの動線）
1. **記録タブ上部** — 直近の未解消レコードを常時表示し、緑丸ボタンでシートを開く
2. **履歴リスト** — 未解消行の右端に「完了」ボタン（ハート+テキスト、タップでシートを開く）
3. **履歴リスト** — 左スワイプ → 「落ち着いた」スワイプアクション（allowsFullSwipe: false）
4. **記録詳細画面** — 未解消の場合、緑の「落ち着いた」全幅ボタン → シートを開く

#### 落ち着いた時刻ピッカー（SettleTimePickerView / WatchSettleTimePickerView）
- **刻み**: 5分刻み（minuteSteps = [0,5,10,...,55]、Watch は 288ステップ = 24×12）
- **デフォルト**: 現在時刻を5分ブロックに切り捨て（秒を無視）
- **バリデーション**: 記録時刻より前はNG（5分ブロック単位で比較）。未来は制限なし
- **解消要因**: iPhone ピッカーでは `SettleCause` を同一シートで選択
- コールバック: `onConfirm: (Date, SettleCause?) -> Void`（Watch は `(Date) -> Void`）

#### HealthKit / 環境データ の空状態
- **HealthKit 未承認**: 「Apple Healthの連携を許可する」ボタン → requestAuthorization()
- **HealthKit 承認済みだがデータなし**: 「記録されていません」+ trendHint テキスト
- **位置情報拒否**: 「設定で位置情報を許可する」ボタン → openSettingsURLString

#### データ管理（設定画面）
- 「すべてのデータを削除」ボタンを設定画面のデータ管理セクションに配置
- `recordStore.deleteAll()` + `customSymptomStore.deleteAll()` を呼ぶ
- 実行前に `confirmationDialog` で確認（破壊的操作のため）

### UI コンポーネントパターン

#### MiniBarRow（TrendsView 共通バーチャート行）
横バーチャート行の共通パターン。TrendsView 内の `private struct MiniBarRow` として実装済み。
症状別・天気別・気圧帯別などで再利用する。

```swift
MiniBarRow(label: name, count: count, maxCount: maxCount, color: .accentColor)
```

#### DashCard（カードコンテナ）
TrendsView の各分析カードを包む共通コンテナ。`private struct DashCard<Content>` として実装済み。
`title` は省略可能（省略するとタイトルなしカード）。

#### lockedCard(title:)（プレミアムロックカード）
プレミアム未加入時に表示するロックカード。`TrendsView` のメソッドとして実装済み。

```swift
lockedCard(title: S.Trends.byTimeOfDay)
```

プレミアムゲートが必要な `@ViewBuilder` var では `planService.isPremium` で分岐し、
else ブランチで `lockedCard(title:)` を呼ぶパターンを使うこと。

#### TrendsView カード構成（無料 / プレミアム）
| カード | 無料 | プレミアム |
|--------|------|------------|
| サマリーカード | ✓ | ✓ |
| 日別バーチャート（week/month のみ） | ✓ | ✓ |
| 症状別カード | ✓ | ✓ |
| 時間帯別カード | ロック表示 | ✓ |
| 曜日別カード | ロック表示 | ✓ |
| 天気別カード | ロック表示 | ✓（環境データなし時はヒント表示） |
| 気圧帯別カード | ロック表示 | ✓（環境データなし時はヒント表示） |
| 気圧変化カード | ロック表示 | ✓（環境データなし時はヒント表示） |
| 詳細リンクカード | ✓（環境・Health はロック） | ✓ |

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
- **無制限**履歴（全期間）、月次レポート、PDF/CSV
- 時間帯別・曜日別傾向（全期間対象）
- 天気別・気圧帯別の記録分析、気圧変化との相関表示
- カスタム症状・薬タグ無制限
- Health 高度分析（EnvironmentAnalysisView / HealthAnalysisView）
- 通院向け要約、高度コンプリケーション
- Siri ショートカット、通知感度調整、個別最適化通知
- 先月比較・長期比較

## 通院向けレポート仕様 (PDF / CSV)

### 設計思想
「医者に出したものに価値がある」を目標とする。
日本頭痛学会・IHS (International Headache Society) の頭痛日誌フォーマット準拠。

### PDF 構成

1. **ヘッダー**
   - アプリ名 + "通院向けレポート"
   - 集計期間 / 出力日時
   - 法的注意書き（先頭に小さく）

2. **サマリー**
   - 症状のあった日数 / 期間日数（月換算 X日/月）
   - 総記録件数
   - 服薬回数（服薬した日数 X日）
   - ⚠️ **MOH警告**: 月換算服薬日数 ≥10 の場合「薬物乱用頭痛（MOH）のリスクがあります。受診時に医師にお伝えください。」を表示
   - 平均持続時間・最長持続時間（settledAt があるもの限定）

3. **症状別内訳**（件数 + %）

4. **強さの分布**（1〜5 件数 + %）

5. **時間帯別分布**（朝5-12時 / 昼12-17時 / 夕17-21時 / 夜21-5時）

6. **曜日別分布**（月〜日 件数）

7. **環境データサマリー**（環境記録がある場合のみ）
   - 気圧下降時（前3時間 -2hPa 以上）の記録件数と割合
   - 天気別件数
   - 平均気温・湿度

8. **Health データサマリー**（HealthKit 記録がある場合のみ）
   - 睡眠6時間未満の日の記録件数
   - 平均安静時心拍（bpm）

9. **記録一覧**（全件、新しい順、複数ページ対応）
   - 列: 日時 / 症状 / 強さ / 持続時間 / 服薬 / 天気・気圧 / メモ

10. **フッター**
    - 法的注意書き再掲

### CSV 列定義（順序固定・追加は末尾のみ）

| # | 列名 | 内容 |
|---|------|------|
| 1 | 日時 | ISO 8601 |
| 2 | 症状 | 症状名（日本語） |
| 3 | 強さ | 1〜5 の数値 |
| 4 | 強さラベル | 日本語ラベル |
| 5 | 服薬 | はい/いいえ |
| 6 | 服薬時刻 | ISO 8601 or 空 |
| 7 | 落ち着いた時刻 | ISO 8601 or 空 |
| 8 | **持続時間(分)** | settledAt - createdAt の分数。未解消は空 |
| 9 | **落ち着いた要因** | 服薬/休息/時間経過/その他/空 |
| 10 | メモ | テキスト |
| 11 | 記録元 | Watch/iPhone |
| 12 | 天気 | 天気状態文字列 |
| 13 | 気圧(hPa) | 数値 |
| 14 | 気圧変化3h(hPa) | 数値（負=下降） |
| 15 | 気温(℃) | 数値 |
| 16 | 湿度(%) | 数値 |
| 17 | 空気質(AQI) | 数値 |
| 18 | PM2.5 | 数値 |
| 19 | 睡眠(時間) | 数値 |
| 20 | 安静時心拍(bpm) | 数値 |
| 21 | 歩数 | 数値 |
| 22 | **曜日** | 月/火/水/木/金/土/日 |
| 23 | **時間帯** | 朝/昼/夕/夜 |

### MOH（薬物乱用頭痛）判定基準
- 服薬日数 ≥ 10日/月（月換算）のとき警告表示
- 警告はオレンジの枠付きボックスで強調
- 診断はしない。「医師にお伝えください」に留める

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
