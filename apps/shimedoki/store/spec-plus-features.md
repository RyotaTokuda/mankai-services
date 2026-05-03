# しめどき Plus 機能仕様書

## 1. 概要

### アプリ概要

しめどき（Shimedoki）は、会議・1on1・商談などの「終わらせどき」をApple Watchの触覚通知で本人だけに静かに伝えるタイマーアプリ。

主な特徴:
- テンプレート管理: よく使う会議時間をシーン化（例: MTG 45分、営業面接 30分）
- アラート機能: 「残り5分」「残り1分」で触覚振動通知
- セッション履歴: 開始時刻・終了時刻・延長回数を記録
- iPhone + watchOS 連携: アプリグループ経由でデータ同期

### Plus 課金の位置づけ

| 機能 | 無料版 | Plus版 |
|---|---|---|
| テンプレート数 | 3件まで | 無制限 |
| セッション履歴 | 7日間 | 無制限 |
| アラート設定 | 固定（残り5分・残り1分） | カスタマイズ可能 |
| **Live Activity** | ✗ | ✓ |
| **Watch Complication** | ✗ | ✓ |
| **ホーム画面Widget** | ✗ | ✓ |
| **週次サマリー通知** | ✗ | ✓ |
| **カスタムアイコン** | ✗ | ✓ |
| **セッションメモ** | ✗ | ✓ |
| カレンダー連携 | ✗ | ✓ |
| Siri Shortcut連携 | ✗ | ✓ |

---

## 2. 課金プラン

### 価格体系

| プラン | 価格（JPY） | 請求周期 | 月額換算 |
|---|---|---|---|
| Plus 月額 | ¥150 | 毎月 | ¥150 (1日5円) |
| Plus 年額 | ¥1,200 | 毎年 | ¥100 (33%オフ・推奨) |

### Product ID

- Subscription Group: `shimedoki.plus`
- 月額: `shimedoki.plus.monthly` (P1M)
- 年額: `shimedoki.plus.yearly` (P1Y)
- StoreKit設定: `Shimedoki/Resources/StoreKitConfiguration.storekit`

---

## 3. 各Plus機能の仕様

### 3.1 Live Activity

- **概要**: ロックスクリーン/Dynamic Islandにセッション残り時間をリアルタイム表示
- **トリガー**: `PhoneSessionViewModel.startLiveActivity()` — セッション開始時
- **更新**: 15秒ごと自動更新 (`remainingSeconds % 15 == 0`)
- **終了**: セッション終了4秒後に自動消去 (`.after(.now + 4)`)
- **条件**: `ActivityAuthorizationInfo().areActivitiesEnabled` が true のみ
- **属性**: `ShimedokiActivityAttributes` (templateTitle, colorHex, totalSeconds)
- **状態**: `ContentState` (remainingSeconds, isPaused, isFinished)
- **UI**: Dynamic Island 展開/コンパクト/ミニマル + ロックスクリーン全幅バナー

### 3.2 Watch Complication

- **概要**: Watch文字盤にテンプレート名と残り時間を表示
- **ターゲット**: `ShimedokiWatchWidget` (Widget Extension, watchOS)
- **サポートファミリー**: `.accessoryCircular` / `.accessoryCorner` / `.accessoryRectangular` / `.accessoryInline`
- **データ共有**: App Group UserDefaults (`group.com.mankai.shimedoki`)
  - `widget.lastTemplateTitle` / `widget.lastTemplateColor` / `widget.sessionRunning` / `widget.remainingSeconds`
- **リフレッシュ**: 実行中30秒ごと、待機中5分ごと

### 3.3 ホーム画面ウィジェット

- **概要**: ホーム画面/ロック画面から最後のテンプレートにワンタップアクセス
- **ターゲット**: `ShimedokiWidget` (Widget Extension, iOS)
- **サポートサイズ**: `.systemSmall` / `.systemMedium`
- **タイムラインポリシー**: `.never` (セッション開始/終了時に手動更新)
- **UI**: timer アイコン + テンプレート名 + カラーアクセント

### 3.4 週次サマリー通知

- **概要**: 毎週日曜20時に週のセッション統計を通知
- **実装**: `WeeklySummaryService` (UNCalendarNotificationTrigger)
- **集計対象**: `completed == true` のセッションのみ
- **表示内容**: セッション数 + 合計分数
- **通知ID**: `shimedoki.weekly.summary`
- **制御**: Settings > 週次サマリー Toggle（Plus のみ表示）
- **依存**: 通知パーミッション必須

### 3.5 カスタムアプリアイコン

- **概要**: 4種類のアイコンから選択可能
- **実装**: `AppIconService` + `UIApplication.setAlternateIconName`
- **アイコン種類**: `AppIcon`(デフォルト) / `AppIconDark`(ダーク) / `AppIconMinimal`(ミニマル) / `AppIconBlue`(ブルー)
- **制御**: Settings > アプリアイコン セクション（Plus のみ有効）
- **注意**: PNG画像ファイルを Assets.xcassets に手動追加が必要

### 3.6 セッションメモ

- **概要**: セッション完了後にメモを保存
- **UI**: 完了画面の TextEditor (3〜6行) + 「メモを保存」ボタン
- **データ**: `SessionLog.note: String?` フィールド
- **保存**: `SessionStore.updateNote(id:note:)`
- **制御**: `PlanLimits.canUseSessionNote(isPro:)` で表示制御

---

## 4. 無料/Plus 機能比較表

| 機能 | 無料 | Plus |
|---|---|---|
| テンプレート作成 | 3件 | 無制限 |
| セッション履歴 | 7日 | 無制限 |
| アラートカスタマイズ | ✗ | ✓ |
| Live Activity | ✗ | ✓ |
| Watch Complication | ✗ | ✓ |
| ホーム画面Widget | ✗ | ✓ |
| 週次サマリー通知 | ✗ | ✓ |
| カスタムアイコン | ✗ | ✓ |
| セッションメモ | ✗ | ✓ |
| カレンダー連携 | ✗ | ✓ |
| Siri Shortcut | ✗ | ✓ |

---

## 5. ペイウォール仕様

### 表示タイミング
1. テンプレート4件目作成試行時
2. カレンダー連携ボタンタップ時
3. カスタムアイコン選択試行時（Plus のみ表示のため到達不可）
4. 週次サマリー有効化試行時（Plus のみ表示のため到達不可）
5. Settings > 「Plus にアップグレード」ボタン

### UI構成
- ヘッダー: アプリ名 + キャッチコピー
- 価格バナー: 月額¥150(1日5円) / 年額¥1,200(月100円・33%オフ) 並列表示
- ベネフィット一覧: NEW バッジ付き新機能 6件 + 既存機能 4件
- プランピッカー: 年額（推奨バッジ）/ 月額
- CTAボタン: 「Plus をはじめる」
- フッター: 購入を復元 + Apple定型文（自動更新説明）

### Apple 必須対応
- 「購入を復元」ボタン: 必須
- 自動更新サブスクリプション説明文: `S.Paywall.legalText` (4言語対応)
- 解約方法の明記: 「設定 > Apple ID > サブスクリプション」

---

## 6. QAチェックリスト

### 基本動作
- [ ] シーン作成・編集・削除
- [ ] セッション開始・一時停止・再開・終了
- [ ] +5分延長（実行中・完了後）
- [ ] Watch でのセッション操作
- [ ] 通知アラート（残り5分・残り1分・終了時）

### Plus 機能
- [ ] Live Activity: セッション中にロックスクリーンに表示される
- [ ] Live Activity: 一時停止時に「一時停止中」表示に切り替わる
- [ ] Live Activity: 終了時に4秒後に消える
- [ ] Watch Complication: 4ファミリーすべてで表示確認（実機）
- [ ] ウィジェット: 小・中サイズで表示確認
- [ ] 週次サマリー: Toggle ON で通知がスケジュールされる
- [ ] 週次サマリー: Toggle OFF で通知がキャンセルされる
- [ ] カスタムアイコン: タップで切り替わる（ダイアログ確認）
- [ ] セッションメモ: 入力・保存・履歴反映

### 課金フロー
- [ ] Sandbox テスト: 月額購入 → isPro = true
- [ ] Sandbox テスト: 年額購入 → isPro = true
- [ ] 購入復元 → isPro = true
- [ ] 無料ユーザーで制限機能タップ → ペイウォール表示
- [ ] ペイウォール閉じる → 元の画面に戻る

### 境界値
- [ ] テンプレート3件: 追加ボタン押下 → ペイウォール表示
- [ ] 無料ユーザー: 履歴7日以前は表示されない
- [ ] 通知パーミッション拒否 → クラッシュしない

### ローカライゼーション
- [ ] 日本語: 全文字列表示確認
- [ ] 英語: Settings > General > Language で英語に切替後確認

---

## 7. リリース準備 手動対応項目

### コード以外で必要な対応

1. **カスタムアイコン PNG 追加**
   - `Shimedoki/Resources/Assets.xcassets` に追加
   - 必要サイズ: 1024x1024 (App Store), 各@1x/@2x/@3x
   - アイコン名: `AppIconDark`, `AppIconMinimal`, `AppIconBlue`

2. **App Store Connect 設定**
   - アプリ登録 (Bundle ID: `com.mankai.shimedoki.Shimedoki`)
   - IAP Product ID 登録: `shimedoki.plus.monthly` / `shimedoki.plus.yearly`
   - Subscription Group: `shimedoki.plus`
   - 価格設定: 月額¥150 / 年額¥1,200

3. **Signing & Capabilities**
   - Apple Developer アカウントでの署名設定
   - App Group (`group.com.mankai.shimedoki`) の有効化
   - Push Notifications Capability（通知のため）

4. **スクリーンショット**
   - iPhone: シーン一覧 / セッション実行中 / Live Activity / ペイウォール
   - Apple Watch: セッション実行中 / 完了画面 / 文字盤コンプリケーション

5. **App Privacy Details（栄養ラベル）**
   - 購入履歴: 収集あり / アプリ機能 / ユーザー紐付けあり / トラッキングなし
   - その他のデータ収集なし

---

*最終更新: 2026-05-03*
