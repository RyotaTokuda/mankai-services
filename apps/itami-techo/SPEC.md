# 痛み手帳 — 実装仕様書

最終更新: 2026-05-02

---

## 実装ステータス凡例

| 記号 | 意味 |
|------|------|
| ✅ | 実装済み・動作確認済み |
| ⚠️ | 実装済みだが未確認 or 部分実装 |
| ❌ | 未実装 |

---

## Phase 1: コア記録

### データモデル

| モデル | ファイル | ステータス |
|--------|----------|-----------|
| SymptomRecord | Shared/Models/SymptomRecord.swift | ✅ |
| SymptomType | Shared/Models/SymptomType.swift | ✅ |
| CustomSymptom | Shared/Models/CustomSymptom.swift | ✅ |
| CustomMedication | Shared/Models/CustomMedication.swift | ✅ |
| EnvironmentSnapshot | Shared/Models/EnvironmentSnapshot.swift | ✅ |
| HealthSnapshot | Shared/Models/HealthSnapshot.swift | ✅ |
| SourceDevice | Shared/Models/SourceDevice.swift | ✅ |
| PlanLimits | Shared/Models/PlanLimits.swift | ✅ |

### サービス層

| サービス | ファイル | ステータス | 備考 |
|----------|----------|-----------|------|
| RecordStore | Shared/Services/RecordStore.swift | ✅ | NSFileCoordinator・CRUD・バックアップ |
| CustomSymptomStore | Shared/Services/CustomSymptomStore.swift | ✅ | |
| WatchSyncService | Shared/Services/WatchSyncService.swift | ✅ | WCSession 双方向同期 |

### iPhone 画面

| 画面 | ファイル | ステータス | 備考 |
|------|----------|-----------|------|
| 記録タブ | ItamiTecho/Views/Record/RecordView.swift | ✅ | 症状・強さ・服薬・メモ・過去日 |
| 履歴一覧 | ItamiTecho/Views/History/HistoryView.swift | ✅ | 14日制限(無料)・スワイプ操作 |
| カレンダー | ItamiTecho/Views/History/CalendarView.swift | ✅ | |
| 記録詳細 | ItamiTecho/Views/History/RecordDetailView.swift | ✅ | 環境・Health データ表示 |
| 記録編集 | ItamiTecho/Views/History/RecordEditView.swift | ✅ | |
| 設定 | ItamiTecho/Views/Settings/SettingsView.swift | ✅ | |
| 通知設定 | ItamiTecho/Views/Settings/NotificationSettingsView.swift | ⚠️ | 感度調整 UI スタブあり |
| Health 設定 | ItamiTecho/Views/Settings/HealthSettingsView.swift | ✅ | 許可ボタン・設定アプリへのリンク |
| バックアップ設定 | ItamiTecho/Views/Settings/BackupSettingsView.swift | ✅ | |
| 法的通知 | ItamiTecho/Views/Settings/LegalView.swift | ✅ | |
| オンボーディング | ItamiTecho/Views/Onboarding/ | ✅ | 4スライド + 位置・Health・通知権限 |

### Apple Watch 画面

| 画面 | ファイル | ステータス |
|------|----------|-----------|
| ホーム | ItamiTechoWatch/Views/WatchHomeView.swift | ✅ |
| 症状選択 | ItamiTechoWatch/Views/WatchSymptomSelectView.swift | ✅ |
| 強さ選択 | ItamiTechoWatch/Views/WatchSeveritySelectView.swift | ✅ |
| 記録完了 | ItamiTechoWatch/Views/WatchRecordCompleteView.swift | ✅ |
| 落ち着いた時刻 | ItamiTechoWatch/Views/WatchSettleTimePickerView.swift | ✅ |
| クイックアクション | ItamiTechoWatch/Views/WatchQuickActionButton.swift | ✅ |

---

## Phase 2: 環境・HealthKit 連携

### サービス層

| サービス | ファイル | ステータス | 備考 |
|----------|----------|-----------|------|
| HealthService | Shared/Services/HealthService.swift | ✅ | 7種類読み取り・UserDefaults 永続化 |
| EnvironmentService | Shared/Services/EnvironmentService.swift | ✅ | 気圧・天気・空気質・バックフィル |
| WeatherService | Shared/Services/WeatherService.swift | ✅ | WeatherKit + Open-Meteo(空気質) |
| LocationService | Shared/Services/LocationService.swift | ✅ | When In Use・市区町村レベル丸め |
| PressureHistoryStore | Shared/Services/PressureHistoryStore.swift | ✅ | CMAltimeter ポーリング |

### HealthKit 取得データ

| データ型 | ステータス |
|----------|-----------|
| 睡眠（昨夜合算） | ✅ |
| 心拍数（直近） | ✅ |
| 安静時心拍 | ✅ |
| 心拍変動 (SDNN) | ✅ |
| 歩数（今日） | ✅ |
| 呼吸数 | ✅ |
| ワークアウト（今日） | ✅ |

### 環境データ取得

| データ | 取得元 | ステータス |
|--------|--------|-----------|
| 気圧（リアルタイム） | CMAltimeter | ✅ |
| 気圧変化量（3h） | ローカル計算 | ✅ |
| 天気・気温・湿度 | WeatherKit | ✅ |
| 空気質 (AQI) | Open-Meteo | ✅ |
| PM2.5 | Open-Meteo | ✅ |
| 過去天気バックフィル | WeatherKit | ⚠️ 動作未確認 |

---

## Phase 3: 分析・レポート

### 傾向分析

| カード | 無料/有料 | ファイル | ステータス |
|--------|----------|----------|-----------|
| サマリーカード | 無料 | TrendsView.swift | ✅ |
| 日別バーチャート | 無料 | TrendsView.swift | ✅ |
| 症状別カード | 無料 | TrendsView.swift | ✅ |
| 時間帯別カード | 有料 | TrendsView.swift | ✅ |
| 曜日別カード | 有料 | TrendsView.swift | ✅ |
| 天気別カード | 有料 | TrendsView.swift | ✅ |
| 気圧帯別カード | 有料 | TrendsView.swift | ✅ |
| 気圧変化カード | 有料 | TrendsView.swift | ✅ |
| 環境分析（詳細） | 有料 | EnvironmentAnalysisView.swift | ✅ |
| Health 分析（詳細） | 有料 | HealthAnalysisView.swift | ✅ |

### 期間フィルター

| 期間 | 無料 | 有料 |
|------|------|------|
| 直近7日 | ✅ | ✅ |
| 直近30日 | ❌（非表示） | ✅ |
| 全期間（14日制限） | ✅ | ✅（無制限） |

### レポート

| 機能 | ファイル | ステータス | 備考 |
|------|----------|-----------|------|
| レポート画面 | ItamiTecho/Views/Report/ReportView.swift | ✅ | 有料ゲート |
| PDF 出力 | ItamiTecho/Services/ReportPDFRenderer.swift | ✅ | MOH 警告・全列含む |
| CSV 出力 | ItamiTecho/Services/ReportCSVGenerator.swift | ✅ | 23列定義済み |

---

## Phase 4: 課金・通知

### StoreKit 2

| 機能 | ファイル | ステータス | 備考 |
|------|----------|-----------|------|
| 商品ロード | Shared/Services/PlanService.swift | ✅ | |
| 購入フロー | PlanService.swift + PaywallView.swift | ✅ | 商品nil時エラーメッセージあり |
| 購入復元 | PlanService.swift | ✅ | |
| エンタイトルメント確認 | PlanService.swift | ✅ | Transaction.currentEntitlements |
| ペイウォール UI | ItamiTecho/Views/Paywall/PaywallView.swift | ✅ | |
| プラン管理画面 | PlanManagementView.swift | ✅ | |

### 商品設定

| 商品 | Product ID | 価格 | ステータス |
|------|-----------|------|-----------|
| 月額 | itamitecho.premium.monthly | ¥390 | ✅ StoreKit設定済み |
| 年額 | itamitecho.premium.yearly | ¥3,900 | ✅ StoreKit設定済み |
| 7日トライアル | 両プランに付与 | 無料 | ✅ |

### 機能ゲート

| 機能 | 無料上限 | 有料 | ステータス |
|------|---------|------|-----------|
| カスタム症状 | 2件 | 無制限 | ✅ |
| 履歴期間 | 14日 | 無制限 | ✅ |
| PDF/CSV 出力 | ❌ | ✅ | ✅ |
| 環境・Health 詳細分析 | ❌ | ✅ | ✅ |
| 高度分析カード（時間帯・曜日・天気・気圧） | ❌ | ✅ | ✅ |
| 月次レポート | ❌ | ✅ | ⚠️ 期間指定レポートのみ、月次自動生成なし |

### 通知

| 機能 | ファイル | ステータス | 備考 |
|------|----------|-----------|------|
| 気圧下降通知 | NotificationService.swift | ✅ | 3hPa閾値・1日1回・週4回制限 |
| 天気急変通知 | NotificationService.swift | ⚠️ | 関数定義あり、呼び出し未確認 |
| 通知感度調整 | NotificationSettingsView.swift | ⚠️ | UI スタブ、ロジック未完成 |

---

## Phase 5: ウィジェット・Siri

### iPhone ウィジェット

| ウィジェット | サイズ | ファイル | ステータス |
|------------|--------|----------|-----------|
| 今日の記録（スモール） | Small | ItamiTechoWidget.swift | ✅ |
| 今日の記録（ミディアム） | Medium | ItamiTechoWidget.swift | ✅ |
| ロック画面（円形） | Circular | ItamiTechoWidget.swift | ✅ |
| ロック画面（矩形） | Rectangular | ItamiTechoWidget.swift | ✅ |

### Watch コンプリケーション

| コンプリケーション | ファイル | ステータス |
|------------------|----------|-----------|
| 円形 | ItamiTechoWatchWidget.swift | ✅ |
| 矩形 | ItamiTechoWatchWidget.swift | ✅ |
| Smart Stack 関連性スコア | ItamiTechoWatchWidget.swift | ✅ |

### Siri ショートカット

| インテント | ファイル | ステータス |
|-----------|----------|-----------|
| 症状記録 (RecordSymptomIntent) | Shared/ | ✅ |
| 今日のサマリー (TodaySummaryIntent) | Shared/ | ✅ |
| App Shortcuts プロバイダー | ItamiTechoShortcuts | ✅ |

---

## 多言語対応

| 言語 | ステータス |
|------|-----------|
| 日本語 (ja) | ✅ |
| 英語 (en) | ✅ |
| 簡体字中国語 (zh-Hans) | ✅ |
| 繁体字中国語 (zh-Hant) | ✅ |

全文言: `Shared/Strings.swift` で `L()` 関数により一元管理

---

## アプリ名ローカライズ

| 言語 | 表示名 | ステータス |
|------|--------|-----------|
| 日本語 | 痛み手帳 | ✅ |
| 英語 | Symptom Log | ✅ |

InfoPlist.strings (ja/en) + `INFOPLIST_KEY_CFBundleDisplayName` で設定済み

---

## 既知の課題・TODO

### バグ・未確認事項

1. **過去天気バックフィル**: `needsBackfill = true` の補完ロジックは実装済みだが動作未確認
2. **天気急変通知**: `notifyWeatherChange()` の呼び出し箇所が未確認
3. **通知感度調整 UI**: `NotificationSettingsView.swift` のスタブが未完成

### ストア提出前の必須対応

- [ ] Sandbox テストで StoreKit 購入フロー完全確認（7日トライアル含む）
- [ ] `store/metadata-ja.md` の内容を App Store Connect に入力
- [ ] App Privacy Details の申告（HealthKit・位置情報・課金）
- [ ] TestFlight でのβテスト
- [ ] スクリーンショット撮影（iPhone: 6.9", 6.5" / Watch: 44mm, 40mm）
- [ ] `store/SUBMISSION_CHECKLIST.md` の全項目チェック

---

## ファイル構成（主要）

```
Shared/
  Models/
    SymptomRecord.swift
    SymptomType.swift
    CustomSymptom.swift
    CustomMedication.swift
    EnvironmentSnapshot.swift
    HealthSnapshot.swift
    SourceDevice.swift
    PlanLimits.swift
  Services/
    RecordStore.swift
    CustomSymptomStore.swift
    HealthService.swift
    EnvironmentService.swift
    WeatherService.swift
    LocationService.swift
    PressureHistoryStore.swift
    PlanService.swift
    WatchSyncService.swift
    NotificationService.swift
    AnalysisHelper.swift
  LocalizationSupport.swift
  Strings.swift
  Constants.swift

ItamiTecho/
  App/ItamiTechoApp.swift
  Views/
    Record/RecordView.swift
    History/{HistoryView, CalendarView, RecordDetailView, RecordEditView}.swift
    Trends/{TrendsView, EnvironmentAnalysisView, HealthAnalysisView}.swift
    Report/{ReportView}.swift
    Paywall/PaywallView.swift
    Settings/{SettingsView, HealthSettingsView, NotificationSettingsView, BackupSettingsView, LegalView, PlanManagementView}.swift
    Onboarding/{OnboardingView, LocationPermissionView, HealthPermissionView, NotificationPermissionView}.swift
  Services/
    ReportPDFRenderer.swift
    ReportCSVGenerator.swift
  Resources/
    StoreKitConfiguration.storekit
    Assets.xcassets

ItamiTechoWatch/
  App/ItamiTechoWatchApp.swift
  Views/
    {WatchHomeView, WatchSymptomSelectView, WatchSeveritySelectView,
     WatchRecordCompleteView, WatchSettleTimePickerView, WatchQuickActionButton}.swift
```
