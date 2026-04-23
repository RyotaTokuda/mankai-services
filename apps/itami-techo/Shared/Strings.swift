import Foundation

/// 全 UI 文言・通知文言を一元管理
/// 法務レビュー時にこのファイルを確認するだけで全文言をチェックできる
///
/// ルール:
/// - View 内に文言をハードコードしない
/// - 法規制に関わる表現は必ずここで管理する
/// - 診断・治療・予防・原因断定の表現を絶対に入れない
enum S {

    // ── アプリ全般 ───────────────────────────────────────
    enum App {
        static let name = "痛み手帳"
        static let tagline = "しんどい瞬間を、手首からすぐ記録"
        static let description = "しんどい瞬間を、Apple Watch や iPhone からすぐ記録。あとから自分の傾向を振り返り、通院時にも使える形にまとめられるアプリです。"
    }

    // ── オンボーディング ──────────────────────────────────
    enum Onboarding {
        static let step1Title = "しんどい瞬間を、手首からすぐ記録"
        static let step1Body = "Apple Watch でも\niPhone でもすぐ残せます"
        static let step2Title = "天気や体調データと一緒に振り返れる"
        static let step2Body = "天気・気圧・Health との関係を\nあとから確認できます"
        static let step3Title = "通院時に見せやすいレポート"
        static let step3Body = "いつ・どのくらい・どんな状況で\n起きたかをまとめられます"
        static let step4Title = "診断ではなく、記録と振り返りに特化"
        static let step4Body = "あなたの記録を整理するアプリです"
        static let startButton = "さっそく記録する"
    }

    // ── 症状 ─────────────────────────────────────────────
    enum Symptom {
        static let headache = "頭痛"
        static let fatigue = "だるさ"
        static let dizziness = "めまい"
        static let nausea = "吐き気"
        static let stiffness = "肩こり"
        static let drowsiness = "眠気"
        static let stomachache = "腹痛"
        static let palpitations = "動悸"
        static let heavyHead = "頭重感"
        static let custom = "カスタム"

        static func name(for type: SymptomType) -> String {
            switch type {
            case .headache: headache
            case .fatigue: fatigue
            case .dizziness: dizziness
            case .nausea: nausea
            case .stiffness: stiffness
            case .drowsiness: drowsiness
            case .stomachache: stomachache
            case .palpitations: palpitations
            case .heavyHead: heavyHead
            }
        }
    }

    // ── 強さ ─────────────────────────────────────────────
    enum Severity {
        static let level1 = "軽い"
        static let level2 = "少しつらい"
        static let level3 = "つらい"
        static let level4 = "かなりつらい"
        static let level5 = "とてもつらい"

        static func label(for level: Int) -> String {
            switch level {
            case 1: level1
            case 2: level2
            case 3: level3
            case 4: level4
            case 5: level5
            default: level3
            }
        }
    }

    // ── 記録 ─────────────────────────────────────────────
    enum Record {
        static let title = "記録する"
        static let selectSymptom = "どこがつらい？"
        static let selectSeverity = "どのくらい？"
        static let done = "記録しました"
        static let medication = "薬を飲んだ"
        static let medicationTaken = "薬を飲んだ"
        static let settled = "落ち着いた"
        static let settledButton = "完了"
        static let addNote = "メモを追加"
        static let edit = "編集"
        static let delete = "削除"
        static let deleteConfirm = "この記録を削除しますか？"
        static let whySettled = "どうして落ち着きましたか？"
        static let settledFooter = "症状が治まったら記録しておくと、通院時のレポートに持続時間が表示されます"
        static let premiumUnlockCustom = "プレミアムでカスタム症状を無制限追加"
    }

    // ── 履歴 ─────────────────────────────────────────────
    enum History {
        static let title = "履歴"
        static let today = "今日"
        static let noRecords = "記録がありません"
        static let last14Days = "直近14日"
        static let olderRecords = "それ以前の記録はプレミアムで確認できます"
    }

    // ── 傾向 ─────────────────────────────────────────────
    enum Trends {
        static let title = "傾向"
        static let bySymptom = "症状別"
        static let byTimeOfDay = "時間帯別"
        static let byDayOfWeek = "曜日別"
        static let severityDistribution = "強さの分布"
        static let monthComparison = "先月との比較"
        static let periodPremium = "直近90日間の傾向"
        static let periodFree = "直近14日間の傾向（無料プラン）"
        static let recordCount = "記録件数"
        static let medicationCount = "服薬回数"
        static let dayOfWeekLocked = "曜日別傾向はプレミアム機能です"
        static let upgrade = "アップグレード"
        static let avgDuration = "平均持続時間"
    }

    // ── 環境分析 ─────────────────────────────────────────
    enum Environment {
        static let title = "環境との関係"
        static let pressure = "気圧"
        static let weather = "天気"
        static let temperature = "気温"
        static let humidity = "湿度"
        static let airQuality = "空気質"
        static let pm25 = "PM2.5"
        /// 相関ヒントの表現（原因断定しない）
        static let hintPressure = "気圧が下がった日に記録が多い傾向があります"
        static let hintAirQuality = "空気質が低い日に不調記録が重なる可能性があります"
        static let hintTemperature = "気温差が大きい日に記録が見られます"
        static let hintGeneral = "記録と環境データの関係を参考情報として表示しています"
        // 空状態
        static let noDataTitle = "天気・気圧データがありません"
        static let noDataBody = "天気・気圧との関係を見るには、位置情報の許可が必要です。気圧はセンサーで取得しているため、位置を許可しなくても気圧データは収集されます。"
        static let noDataButton = "設定で位置情報を許可する"
        static let noDataYet = "環境データがまだ記録されていません"
    }

    // ── Health 分析 ──────────────────────────────────────
    enum Health {
        static let title = "Healthとの関係"
        static let sleep = "睡眠"
        static let heartRate = "心拍"
        static let steps = "歩数"
        static let permissionTitle = "Apple Healthと連携"
        static let permissionBody = "睡眠・心拍・歩数などと不調記録の関係を振り返れるようになります"
        /// 相関ヒントの表現（原因断定しない）
        static let hintSleep = "睡眠時間が短い日の前後で記録が多い傾向があります"
        static let hintHeartRate = "安静時心拍が高めの日に不調記録が重なることがあります"
        // 空状態・接続誘導
        static let connectTitle = "Apple Healthと連携すると"
        static let connectBody = "睡眠・安静時心拍・歩数と症状の関係が見えるようになります。"
        static let connectButton = "Apple Healthの連携を許可する"
        static let noDataYet = "Healthデータがまだ記録されていません"
        // データラベル
        static let shortSleepRecord = "6時間未満の日の記録"
        static let normalSleepRecord = "6時間以上の日の記録"
        static let highHRRecord = "安静時心拍高めの日の記録"
        static let normalHRRecord = "通常の日の記録"
        static let avgStepsRecord = "記録日の平均歩数"
    }

    // ── レポート ─────────────────────────────────────────
    enum Report {
        static let title = "通院向けレポート"
        static let summary = "要約"
        static let detail = "詳細"
        static let exportPDF = "PDFで出力"
        static let exportCSV = "CSVで出力"
        static let periodSelect = "期間を選択"
        static let startDate = "開始"
        static let endDate = "終了"
        static let recordCount = "記録件数"
        static let medicationCount = "服薬回数"
        static let avgSettleTime = "落ち着くまでの平均"
        static let exportSection = "出力"
        static let upgradeToExport = "アップグレードして出力する"
        static let disclaimer = "このレポートは記録データに基づく参考情報です。医療上の判断に代わるものではありません。"
        static let doctorCTA = "通院前にレポートをまとめますか？"
        static let doctorCTABody = "記録をPDFにまとめて、医師と共有しやすくなります"
        static let doctorCTAButton = "レポートを見る"
        static let premiumRequiredPDF = "PDF出力はプレミアム機能です"
        static let premiumRequiredCSV = "CSV出力はプレミアム機能です"
    }

    // ── 課金 ─────────────────────────────────────────────
    enum Paywall {
        static let title = "プレミアムプラン"
        static let subtitle = "傾向を深く知り、通院時にも役立てる"
        static let description = "必要な時だけ、より深く振り返れます"
        static let monthlyLabel = "月額"
        static let yearlyLabel = "年額"
        static let yearlySaving = "月換算 ¥300（37% オフ）"
        static let trialLabel = "7日間無料で試す"
        static let restoreLabel = "購入を復元"
        static let freeNote = "無料でも記録・基本履歴・カレンダーはずっと使えます"
        // トライアルタイムライン
        static let trialBothPlans = "どちらのプランも7日間の無料トライアル付き"
        static let trialTimelineToday = "今日"
        static let trialTimelineDay7 = "7日後"
        static let ctaStart = "7日間無料で始める"
        static let trialAutoRenew = "無料期間終了後に自動更新。いつでもキャンセル可。"
        /// Apple 必須の定型開示文（変更禁止）
        static let subscriptionDisclosure = "サブスクリプションは確認時にApple IDに課金されます。現在の期間終了の少なくとも24時間前にキャンセルしない限り自動更新されます。"
        // 機能一覧
        static let featureHistory = "90日間の無制限履歴"
        static let featureReport = "通院向けPDF / CSVレポート"
        static let featureEnvironment = "天気・気圧・空気質の詳細分析"
        static let featureHealth = "Health連携の詳細分析"
        static let featureTrends = "曜日別・強さ分布の傾向分析"
        static let featureCustom = "カスタム症状・薬タグ無制限"
        // プランカード
        static let planYearly = "年額"
        static let planMonthly = "月額"
        static let yearlyDetail = "月換算 ¥300"
        static let monthlyDetail = "いつでも解約可"
        static let recommended = "おすすめ"
    }

    // ── 通知 ─────────────────────────────────────────────
    enum Notification {
        /// 使う表現
        static let weatherChange = "天気の変化が大きい予報です。必要ならすぐ記録できます"
        static let pressureChange = "気圧変化が大きめの見込みです。必要な時はすぐ記録できます"
        static let reminder = "体調が気になる時だけ残してください"
        /// 記録後の見返り
        static let countToday = "件目です"
        static let eveningTrend = "今週は夕方の記録が多めです"
        static let severityLower = "前回より強さが低めです"
    }

    // ── 記録後の見返り ───────────────────────────────────
    enum Feedback {
        static func todayCount(_ count: Int) -> String {
            "今日\(count)件目です"
        }
        static let eveningTrend = "今週は夕方の記録が多めです"
        static let severityLower = "前回より強さが低めです"
    }

    // ── 設定 ─────────────────────────────────────────────
    enum Settings {
        static let title = "設定"
        static let notification = "通知"
        static let notificationEnabled = "予兆通知"
        static let notificationSensitivity = "通知感度"
        static let healthIntegration = "Apple Health連携"
        static let subscription = "プラン管理"
        static let about = "このアプリについて"
        static let legal = "法的情報"
        // 通知設定
        static let notificationPermissionDenied = "通知がオフになっています。設定アプリから許可してください。"
        static let notificationSensitivityLow = "少なめ（週1〜2回）"
        static let notificationSensitivityNormal = "通常（週3〜4回）"
        static let notificationSensitivityHigh = "多め（毎日）"
        static let notificationFooter = "天気・気圧が大きく変化する予報の時にだけお知らせします。診断・予防を目的とするものではありません。"
        static let notificationAuthorized = "通知が許可されています"
        static let notificationOpenSettings = "設定アプリを開く"
        static let notificationAllow = "通知を許可する"
        // プラン管理
        static let planFree = "無料プラン"
        static let planPremium = "プレミアム"
        static let planBadge = "プレミアム"
        static let planTrialActive = "トライアル中"
        static let planUpgrade = "プレミアムにアップグレード"
        static let planRestore = "購入を復元"
        static let planManageSubscription = "サブスクリプションを管理"
        static let planAllFeatures = "すべての機能をご利用いただけます"
        static let planFreeFeatures = "基本的な記録・履歴機能が使えます"
        static let premiumFeaturesTitle = "プレミアム機能"
        static let premiumFeaturesUpgradeTitle = "プレミアムでできること"
        static let planFeatureHistory = "無制限の履歴保存"
        static let planFeatureReport = "通院向けPDF / CSVレポート"
        static let planFeatureTrends = "曜日別・90日間の傾向分析"
        static let planFeatureAnalysis = "天気・気圧・Health 高度分析"
        static let planFeatureCustom = "カスタム症状・薬タグ無制限"
        static let planFeatureHistoryFree = "90日間の無制限履歴"
        static let planFeatureReportFree = "通院向けPDF / CSVレポート出力"
        static let planFeatureTrendsFree = "曜日別傾向・詳細環境分析"
        static let planFeatureHealthFree = "Health連携の詳細分析"
        static let planFeatureCustomFree = "カスタム症状・薬タグ無制限"
        static let planTrialBanner = "7日間無料トライアルあり"
        // Health設定
        static let healthNotAuthorized = "Healthへのアクセスが許可されていません"
        static let healthOpenSettings = "設定でHealthを許可する"
        static let healthAuthorized = "Healthと連携中"
        static let healthDataList = "取得データ：睡眠・安静時心拍・心拍変動・歩数・呼吸数・ワークアウト"
        static let healthDeviceNotSupported = "このデバイスはHealthKitに対応していません"
        static let healthConnectionStatus = "接続状態"
        static let healthDataSection = "取得するデータ"
        static let healthPrivacyNote = "HealthKitデータは端末内でのみ使用し、外部に送信されることはありません。"
        // iCloud
        static let backup = "機種変・バックアップ"
        static let iCloudSyncing = "iCloud と同期中"
        static let iCloudDisabled = "iCloud が無効です"
        static let iCloudHint = "設定 › Apple Account › iCloud でオンにすると機種変後もデータを引き継げます"
        // データ管理
        static let dataManagement = "データ管理"
        static let deleteAllData = "すべてのデータを削除"
        static let deleteAllDataConfirm = "記録・カスタム症状を含む全データを削除します。この操作は元に戻せません。"
        static let deleteAllDataButton = "すべて削除"
    }

    // ── 法的注意書き ─────────────────────────────────────
    enum Legal {
        static let title = "法的情報"
        static let importantNotice = "重要な注意事項"
        static let dataHandlingTitle = "データの取り扱い"
        static let disclaimer1 = "本アプリは診断、治療、予防を目的としたものではありません。"
        static let disclaimer2 = "本アプリの内容は医療上の判断に代わるものではありません。"
        static let disclaimer3 = "体調に不安がある場合は医療機関に相談してください。"
        static let disclaimer4 = "表示される傾向は記録データに基づく参考情報です。"
        static let dataLocal = "すべてのデータは端末内に保存されます"
        static let dataNoExternal = "健康データを外部に送信することはありません"
        static let locationRounded = "位置情報は市区町村レベルに丸めて保存されます"
        static let trendsDisclaimer = "表示される傾向は記録データに基づく参考情報です"
        static let privacyPolicy = "プライバシーポリシー"
        static let termsOfService = "利用規約"
    }

    // ── 共通 UI ──────────────────────────────────────────
    enum Common {
        static let close = "閉じる"
        static let cancel = "キャンセル"
        static let save = "保存"
        static let next = "次へ"
        static let skip = "スキップ"
        static let version = "バージョン"
        static let addSymptom = "症状を追加"
        static let customSymptomLimitPremium = "カスタム症状の追加はプレミアムで無制限に"
        static let pastRecord = "過去の記録"
        static let symptomName = "症状名"
        static let emojiOptional = "絵文字（任意）"
        static let customSymptomHint = "一般的な症状を入力してください。\n病名の入力は推奨しません。"
        static let add = "追加"
        static let symptom = "症状"
        static let severity = "強さ"
        static let recordedAt = "記録日時"
        static let recordSource = "記録元"
        static let medication = "薬"
        static let timeTaken = "かかった時間"
        static let medicationTime = "服薬時刻"
        static let settleCause = "解消の要因"
        static let sourceDevice = "記録元"
        static let sourceWatch = "Apple Watch"
        static let sourceiPhone = "iPhone"
        static let calendar = "カレンダー"
        static let detailView = "詳しく見る"
        static let last14Days = "直近14日"
        static let trendHint = "記録が増えると傾向が見えてきます"
        static let note = "メモ"
        static let dateTime = "日時"
    }

    // ── Widget ──────────────────────────────────────────
    enum Widget {
        static func todayCount(_ count: Int) -> String {
            "今日 \(count)件"
        }
        static let noRecords = "記録なし"
        static let noRecordsToday = "今日の記録はまだありません"
        static let tapToRecord = "タップして記録"
        static let latest = "直近"
    }

    // ── Watch ────────────────────────────────────────────
    enum Watch {
        static let recordNow = "今すぐ記録"
        static let recentRecord = "直近の記録"
        static let tookMedicine = "薬を飲んだ"
        static let settledDown = "落ち着いた"
        static let recorded = "記録しました"
    }

    // ── 権限リクエスト（事前説明画面） ────────────────────
    enum Permission {
        // ── 位置情報 ──
        static let locationTitle = "天気・気圧を記録に連動するために"
        static let locationAllowedTitle = "許可した場合"
        static let locationAllowedItem1 = "記録に天気・気温を自動付与"
        static let locationAllowedItem2 = "空気質・PM2.5も記録"
        static let locationAllowedItem3 = "環境と不調の関係を振り返れるようになる"
        static let locationDeniedTitle = "許可しない場合"
        static let locationDeniedItem1 = "記録はもちろんできます"
        static let locationDeniedItem2 = "気圧は端末センサーから自動で取得されます"
        static let locationDeniedItem3 = "天気・空気質は記録に含まれません"
        static let locationPrivacy = "位置情報は市区町村レベルに丸めて保存され、外部に送信されることはありません。"
        static let locationAllowButton = "天気と連動する"
        static let locationSkipButton = "あとで設定する"

        // ── Health ──
        static let healthTitle = "Healthデータと振り返り"
        static let healthBody = "睡眠・心拍・歩数と不調記録の関係を振り返れるようになります。データは端末内でのみ使用します。"
        static let healthAllowedTitle = "許可した場合"
        static let healthAllowedItem1 = "前夜の睡眠時間を記録に自動付与"
        static let healthAllowedItem2 = "安静時心拍・HRVを記録と並べて確認"
        static let healthAllowedItem3 = "歩数・ワークアウトの有無も振り返れる"
        static let healthDeniedTitle = "許可しない場合"
        static let healthDeniedItem1 = "記録・履歴・レポートは全て使えます"
        static let healthDeniedItem2 = "気圧・天気との傾向も引き続き確認できます"
        static let healthDeniedItem3 = "睡眠・心拍との比較はできません"
        static let healthPrivacy = "HealthKitデータは端末内でのみ使用し、外部に送信されることはありません。"
        static let healthAllowButton = "Healthデータと連動する"
        static let healthSkipButton = "あとで設定する"

        // ── 通知 ──
        static let notificationTitle = "必要な時だけお知らせ"
        static let notificationBody = "天気が大きく変わる時など、記録が必要になりそうな場面でだけ通知します。"
        static let notificationPressureDrop = "気圧が大きく下がる見込みの時"
        static let notificationWeatherChange = "天気が急変する予報の時"
        static let notificationNonMedical = "診断や予防を目的としない通知です"
        static let notificationFrequencyNote = "週4回以内・1日1回以内に制限されます。\n通知のオン/オフは設定でいつでも変更できます。"
        static let notificationAllowButton = "通知を許可する"
        static let notificationSkipButton = "あとで設定する"
    }
}
