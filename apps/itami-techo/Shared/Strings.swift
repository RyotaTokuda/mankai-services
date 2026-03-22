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
    }

    // ── オンボーディング ──────────────────────────────────
    enum Onboarding {
        static let step1Title = "しんどい瞬間を、手首からすぐ記録"
        static let step1Body = "Apple Watch でもiPhone でもすぐ残せます"
        static let step2Title = "天気や体調データと一緒に振り返れる"
        static let step2Body = "Health や天気・気圧との関係をあとから確認できます"
        static let step3Title = "通院時に見せやすいレポート"
        static let step3Body = "いつ・どのくらい・どんな時に起きたかをまとめられます"
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
        static let custom = "カスタム"

        static func name(for type: SymptomType) -> String {
            switch type {
            case .headache: headache
            case .fatigue: fatigue
            case .dizziness: dizziness
            case .nausea: nausea
            case .stiffness: stiffness
            case .drowsiness: drowsiness
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
        static let addNote = "メモを追加"
        static let edit = "編集"
        static let delete = "削除"
        static let deleteConfirm = "この記録を削除しますか？"
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
    }

    // ── レポート ─────────────────────────────────────────
    enum Report {
        static let title = "通院向けレポート"
        static let summary = "要約"
        static let detail = "詳細"
        static let exportPDF = "PDFで出力"
        static let exportCSV = "CSVで出力"
        static let periodSelect = "期間を選択"
        static let disclaimer = "このレポートは記録データに基づく参考情報です。医療上の判断に代わるものではありません。"
    }

    // ── 課金 ─────────────────────────────────────────────
    enum Paywall {
        static let title = "記録を、振り返れる形に"
        static let subtitle = "長期保存、Health連携、環境分析、通院向けレポートで自分の傾向を見える化"
        static let description = "必要な時だけ、より深く振り返れます"
        static let monthlyLabel = "月額"
        static let yearlyLabel = "年額"
        static let yearlySaving = "10ヶ月分の価格"
        static let trialLabel = "7日間無料で試す"
        static let restoreLabel = "購入を復元"
        static let freeNote = "無料でも記録・基本履歴・カレンダーはずっと使えます"
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
    }

    // ── 法的注意書き ─────────────────────────────────────
    enum Legal {
        static let title = "法的情報"
        static let disclaimer1 = "本アプリは診断、治療、予防を目的としたものではありません。"
        static let disclaimer2 = "本アプリの内容は医療上の判断に代わるものではありません。"
        static let disclaimer3 = "体調に不安がある場合は医療機関に相談してください。"
        static let disclaimer4 = "表示される傾向は記録データに基づく参考情報です。"
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

        // ── 通知 ──
        static let notificationTitle = "必要な時だけお知らせ"
        static let notificationBody = "天気が大きく変わる時など、記録が必要になりそうな場面でだけ通知します。"
    }
}
