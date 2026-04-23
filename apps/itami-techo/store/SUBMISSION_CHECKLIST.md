# 痛み手帳 — App Store 提出チェックリスト

最終更新: 2026-04-24

> App Store Connect での作業は Safari / Chrome で行う。
> Xcode の操作は Mac ローカルで行う。

---

## Phase 1: App Store Connect の準備

### 1-1. Apple Developer Program

- [ ] Apple Developer Program に登録済み（年額 $99）
  - https://developer.apple.com/account/
- [ ] Team ID が `R7B3AEZ7TA` であることを確認

### 1-2. App Store Connect でアプリを新規作成

1. https://appstoreconnect.apple.com → 「マイ App」→「＋」→「新規 App」
2. 入力内容:
   - プラットフォーム: iOS（Watch は自動で含まれる）
   - 名前: `痛み手帳`
   - 主要言語: Japanese
   - Bundle ID: `com.mankai.itamitecho`（Certificates, IDs から事前に登録しておく）
   - SKU: `itamitecho` （任意の一意な文字列）

### 1-3. Bundle ID の登録

1. https://developer.apple.com → Certificates, Identifiers & Profiles → Identifiers
2. 「＋」→ App IDs → App
3. Bundle ID: `com.mankai.itamitecho`
4. Capabilities で以下を有効化:
   - [x] App Groups（`group.com.mankai.itami-techo`）
   - [x] HealthKit
   - [x] WeatherKit
   - [x] iCloud（CloudKit と Key-Value storage）
   - [x] Push Notifications（通知用）
   - [x] Associated Domains（不要なら外す）

### 1-4. IAP（サブスクリプション）の登録

> App Store Connect → 対象アプリ → 収益化 → サブスクリプション

1. サブスクリプショングループを作成
   - グループ名: `Premium`
   - グループ参照名: `itamitecho.premium`

2. 月額プランを追加:
   - 参照名: `Premium Monthly`
   - Product ID: `itamitecho.premium.monthly`（**コードと完全一致必須**）
   - 価格: ¥390（Tier 3 相当）
   - 無料トライアル: 7日間
   - 日本語表示名: `Premium 月額`
   - 日本語説明: `月額プラン（7日間無料トライアル付き）`

3. 年額プランを追加:
   - 参照名: `Premium Yearly`
   - Product ID: `itamitecho.premium.yearly`（**コードと完全一致必須**）
   - 価格: ¥3,900（Tier 30 相当）
   - 無料トライアル: 7日間
   - 日本語表示名: `Premium 年額`
   - 日本語説明: `年額プラン（10ヶ月分の価格、7日間無料トライアル付き）`

---

## Phase 2: Xcode でアーカイブ・アップロード

### 2-1. 署名設定

1. Xcode → ItamiTecho.xcodeproj → TARGETS → ItamiTecho → Signing & Capabilities
2. Team: R7B3AEZ7TA を選択
3. Bundle Identifier: `com.mankai.itamitecho`
4. 同様に ItamiTechoWatch / ItamiTechoWidgetExtension / ItamiTechoWatchWidgetExtension も設定

### 2-2. バージョン番号の確認

- project.yml の `MARKETING_VERSION` が `1.0.0`、`CURRENT_PROJECT_VERSION` が `1` になっていることを確認
- 2回目以降の提出: `CURRENT_PROJECT_VERSION` をインクリメント（1→2→3…）

### 2-3. xcodegen で .xcodeproj を再生成

```bash
cd apps/itami-techo
xcodegen generate
```

### 2-4. Sandbox テスト

1. Xcode → Product → Scheme → Edit Scheme → Run → StoreKit Configuration → `ItamiTecho.storekit` を選択
2. シミュレーターまたは実機で起動
3. 以下を確認:
   - [ ] 月額プランの購入フロー（7日トライアル）が動く
   - [ ] 年額プランの購入フロー（7日トライアル）が動く
   - [ ] 「購入を復元」が動く
   - [ ] プレミアム機能（PDF出力、90日履歴）が解放される
   - [ ] トライアル終了後に無料プランに戻る

### 2-5. アーカイブ

```
Xcode メニュー → Product → Archive
```

- Scheme: `ItamiTecho`
- Destination: Any iOS Device（実機接続 or Generic iOS Device）

### 2-6. App Store Connect にアップロード

1. Archives ウィンドウ → Validate App → すべてのチェックが通ることを確認
2. Distribute App → App Store Connect → Upload
3. アップロード完了後、App Store Connect に「処理中」で表示されるまで待つ（10〜30分）

---

## Phase 3: App Store Connect でメタデータ入力

### 3-1. アプリ情報（日本語）

`store/metadata-ja.md` の内容をそのまま入力する。

- アプリ名: `痛み手帳`
- サブタイトル: `だるさ・めまい・不調をすぐ記録`
- カテゴリ: ヘルスケア/フィットネス
- 説明文: metadata-ja.md の「説明文」セクションをコピー
- キーワード: `頭痛,だるさ,めまい,不調,記録,手帳,体調,気圧,ログ,通院`
  - キーワードは100文字以内、カンマ区切り

### 3-2. スクリーンショット（必須）

> 実機 or シミュレーターで撮影すること（合成・モックアップ不可）

必要なサイズ:
- iPhone 6.9インチ（iPhone 16 Pro Max 相当: 1320 x 2868px）← **最低でもこれ1種類**
- Apple Watch（Ultra: 410 x 502px、または Series 10 45mm: 396 x 484px）

**iPhone スクリーンショット 6枚:**
1. Apple Watch で記録する画面（症状選択）
2. iPhone 症状選択画面（ボタン一覧）
3. 履歴画面（カレンダー + リスト）
4. 環境分析画面（気圧グラフ）
5. 通院向けレポート画面（PDF プレビュー）
6. ペイウォール画面（Premium 機能一覧）

**Watch スクリーンショット 4枚:**
1. ホーム画面（「今すぐ記録」）
2. 症状選択画面
3. 強さ選択画面
4. 記録完了画面（薬・落ち着いた）

**撮影方法:**
```
シミュレーター → Device → Trigger Screenshot（⌘S）
→ Desktop に保存される
```

### 3-3. App プレビュー動画（任意・効果大）

15〜30秒の画面録画。提出しなくても審査は通る。

### 3-4. サポート情報

- サポートURL: `https://mankai-software.com/support`
- プライバシーポリシーURL: `https://mankai-software.com/privacy`
- マーケティングURL（任意）: `https://mankai-software.com`

### 3-5. 年齢制限

- コンテンツの説明: 年齢制限なし（4+）
- 医療用途の質問: 「いいえ」（診断・治療を行うアプリではないため）

---

## Phase 4: App Privacy（栄養ラベル）

> App Store Connect → 対象アプリ → App プライバシー

以下の内容で申告する:

| データ種類 | 収集 | リンク | 利用目的 |
|---|---|---|---|
| 健康データ | はい | はい（ユーザーに紐付け） | アプリ機能 |
| 位置情報（おおよそ） | はい | はい | アプリ機能 |
| 購入 | はい | はい | アプリ機能 |

**重要な申告ポイント:**
- HealthKit データは外部送信なし（デバイス上のみ）を正確に申告
- 位置情報は市区町村レベルのみ、外部送信なし
- トラッキング目的での使用: なし

---

## Phase 5: 審査提出

### 5-1. 審査メモ（必ず書く）

> App Store Connect → バージョン → App Review → Notes

以下の内容をコピーして貼り付ける:

```
【アプリの概要】
Apple Watch / iPhone で不調（頭痛・だるさ・めまいなど）を即記録し、
傾向を振り返り、通院時にレポートとして活用するセルフログアプリです。

【重要】
本アプリは医療機器ではなく、診断・治療・予防を目的としません。
記録・整理・振り返りに特化したセルフログツールです。

【主要な機能】
- Apple Watch から2〜3タップで記録完了
- 天気・気圧・空気質を記録に自動連動（WeatherKit + CMAltimeter）
- Apple Health の睡眠・心拍データと傾向を並べて確認
- 通院向けPDF/CSVレポート出力（IHS頭痛日誌フォーマット準拠）
- サブスクリプション: 月額¥390 / 年額¥3,900（7日無料トライアル）

【HealthKit】
睡眠・安静時心拍・歩数・HRV を読み取り専用で使用。
HealthKit データは端末内のみで処理し、外部送信しません。

【位置情報】
WeatherKit での天気・気圧取得に使用（記録時のみ）。
市区町村レベルに丸めて保存し、外部に送信しません。

【ログインなし】
ローカルファーストのためデモアカウントは不要です。

【Sandboxテスト用】
月額・年額プランともにSandboxで購入テスト可能です（7日トライアル付き）。
```

### 5-2. バージョンリリース方法

- 手動リリース（審査通過後に自分でリリースボタンを押す）を推奨
  → 告知のタイミングと合わせるため

### 5-3. 提出

「審査へ提出」ボタンをクリック。

---

## Phase 6: 審査中〜リリース後

### 審査期間

- 通常: 1〜3日
- HealthKit / 医療系アプリは追加質問が来る場合がある（7〜14日）

### よくある追加質問と回答

**Q: このアプリは医療機器として規制されますか？**
A: いいえ。診断・治療・予防を行いません。ユーザーが自分の体調を記録・整理するツールです。

**Q: HealthKit データの利用目的を説明してください**
A: 睡眠・心拍・歩数を読み取り、ユーザーが自分の不調記録と並べて傾向を確認するために使います。データは端末内のみで使用し、外部に送信しません。

### リリース後の確認事項

- [ ] TestFlight で動作確認後に一般公開
- [ ] App Store のリンクを mankai-software.com / SNS で告知
- [ ] クラッシュレポートを App Store Connect の Crashes タブで確認
- [ ] レビューに回答する（特に初期の低評価レビュー）

---

## 参照ファイル

| ファイル | 用途 |
|---|---|
| `store/metadata-ja.md` | アプリ名・説明文・キーワード・スクリーンショット仕様 |
| `apps/itami-techo/CLAUDE.md` | 技術仕様・法規制ルール・ストア公開チェックリスト（詳細） |
| `/STORE_SUBMISSION_GUIDE.md` | モノレポ共通のストア公開ガイド |

---

## トラブルシューティング

### `ITMS-90235: Missing required icon`
→ Assets.xcassets の AppIcon に 1024×1024 の画像が設定されているか確認

### `ITMS-91053: Missing purpose string`
→ project.yml の `NSHealthShareUsageDescription` / `NSLocationWhenInUseUsageDescription` が設定されているか確認

### `ERROR ITMS-90338: Non-public API usage`
→ HealthKit API を正しく使っているか確認

### StoreKit の Product ID が見つからない
→ App Store Connect で IAP を「承認待ち」以外の状態にする。「準備完了」になるまで実機では購入不可

### 審査で `Guideline 1.4 - Safety - Medical` に引っかかった
→ アプリ内の表現を確認。`Shared/Strings.swift` の Legal 注意書きが全画面に表示されているか確認。審査メモに「医療機器ではない」旨を詳しく記載して再提出
