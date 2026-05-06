import Foundation

/// 全 UI 文言・通知文言を一元管理
/// 法務レビュー時にこのファイルを確認するだけで全文言をチェックできる
///
/// ルール:
/// - View 内に文言をハードコードしない
/// - 法規制に関わる表現は必ずここで管理する
/// - 診断・治療・予防・原因断定の表現を絶対に入れない
/// - 各文言は L(ja:en:zhHans:zhHant:) で4言語分を記載する
enum S {

    // ── アプリ全般 ───────────────────────────────────────
    enum App {
        static var name: String { L("痛み手帳", en: "Symptom Log", zhHans: "症状日记", zhHant: "症狀日記") }
        static var tagline: String { L("しんどい瞬間を、すぐ記録", en: "Log symptoms instantly", zhHans: "立刻记录不适时刻", zhHant: "立刻記錄不適時刻") }
        static var description: String { L(
            "しんどい瞬間を、Apple Watch や iPhone からすぐ記録。あとから自分の傾向を振り返り、通院時にも使える形にまとめられるアプリです。",
            en: "Log discomfort from your Apple Watch or iPhone. Review your trends and create reports you can use at your next medical appointment.",
            zhHans: "随时用 Apple Watch 或 iPhone 记录不适瞬间，回顾自身规律，生成可用于就医的报告。",
            zhHant: "隨時用 Apple Watch 或 iPhone 記錄不適瞬間，回顧自身規律，生成可用於就醫的報告。"
        ) }
    }

    // ── オンボーディング ──────────────────────────────────
    enum Onboarding {
        static var step1Title: String { L("しんどい瞬間を、すぐ記録", en: "Log symptoms instantly", zhHans: "随时记录症状", zhHant: "隨時記錄症狀") }
        static var step1Body: String { L("Apple Watch でも\niPhone でもすぐ残せます", en: "Works on both Apple Watch\nand iPhone", zhHans: "Apple Watch 和 iPhone 均可记录", zhHant: "Apple Watch 和 iPhone 均可記錄") }
        static var step2Title: String { L("天気や体調データと一緒に振り返れる", en: "Review with weather and health data", zhHans: "结合天气与健康数据回顾", zhHant: "結合天氣與健康數據回顧") }
        static var step2Body: String { L("天気・気圧・Health との関係を\nあとから確認できます", en: "Check how weather, pressure,\nand Health data relate", zhHans: "之后可查看天气、气压与 Health 的关联", zhHant: "之後可查看天氣、氣壓與 Health 的關聯") }
        static var step3Title: String { L("通院時に見せやすいレポート", en: "Reports you can share with your doctor", zhHans: "方便就诊时展示的报告", zhHant: "方便就診時展示的報告") }
        static var step3Body: String { L("いつ・どのくらい・どんな状況で\n起きたかをまとめられます", en: "Summarize when, how severe,\nand under what conditions", zhHans: "整理何时、程度及发生情况", zhHant: "整理何時、程度及發生情況") }
        static var step4Title: String { L("診断ではなく、記録と振り返りに特化", en: "Focused on logging and review, not diagnosis", zhHans: "专注记录与回顾，非诊断", zhHant: "專注記錄與回顧，非診斷") }
        static var step4Body: String { L("あなたの記録を整理するアプリです", en: "An app to organize your personal records", zhHans: "整理您记录的应用程序", zhHant: "整理您記錄的應用程式") }
        static var startButton: String { L("さっそく記録する", en: "Start Logging", zhHans: "立即记录", zhHant: "立即記錄") }
    }

    // ── 症状 ─────────────────────────────────────────────
    enum Symptom {
        static var headache: String    { L("頭痛",  en: "Headache",         zhHans: "头痛",     zhHant: "頭痛") }
        static var fatigue: String     { L("だるさ", en: "Fatigue",          zhHans: "疲乏",     zhHant: "疲乏") }
        static var dizziness: String   { L("めまい", en: "Dizziness",        zhHans: "眩晕",     zhHant: "眩暈") }
        static var nausea: String      { L("吐き気", en: "Nausea",           zhHans: "恶心",     zhHant: "噁心") }
        static var stiffness: String   { L("肩こり", en: "Stiff Shoulders",  zhHans: "肩酸",     zhHant: "肩酸") }
        static var drowsiness: String  { L("眠気",  en: "Drowsiness",       zhHans: "困倦",     zhHant: "困倦") }
        static var stomachache: String { L("腹痛",  en: "Stomachache",      zhHans: "腹痛",     zhHant: "腹痛") }
        static var palpitations: String { L("動悸", en: "Palpitations",     zhHans: "心悸",     zhHant: "心悸") }
        static var heavyHead: String   { L("頭重感", en: "Heavy Head",       zhHans: "头部沉重感", zhHant: "頭部沉重感") }
        static var custom: String      { L("カスタム", en: "Custom",         zhHans: "自定义",   zhHant: "自訂") }

        static func name(for type: SymptomType) -> String {
            switch type {
            case .headache:    headache
            case .fatigue:     fatigue
            case .dizziness:   dizziness
            case .nausea:      nausea
            case .stiffness:   stiffness
            case .drowsiness:  drowsiness
            case .stomachache: stomachache
            case .palpitations: palpitations
            case .heavyHead:   heavyHead
            }
        }
    }

    // ── 強さ ─────────────────────────────────────────────
    enum Severity {
        static var level1: String { L("軽い",       en: "Mild",                  zhHans: "轻微",     zhHant: "輕微") }
        static var level2: String { L("少しつらい",  en: "Slightly uncomfortable", zhHans: "稍感不适", zhHant: "稍感不適") }
        static var level3: String { L("つらい",     en: "Uncomfortable",         zhHans: "不适",     zhHant: "不適") }
        static var level4: String { L("かなりつらい", en: "Quite uncomfortable",  zhHans: "相当不适", zhHant: "相當不適") }
        static var level5: String { L("とてもつらい", en: "Very uncomfortable",   zhHans: "非常不适", zhHant: "非常不適") }

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
        static var title: String               { L("記録する",         en: "Log Symptom",              zhHans: "记录症状",     zhHant: "記錄症狀") }
        static var selectSymptom: String       { L("どこがつらい？",    en: "What's bothering you?",    zhHans: "哪里不舒服？",  zhHant: "哪裡不舒服？") }
        static var selectSeverity: String      { L("どのくらい？",      en: "How severe?",              zhHans: "程度如何？",    zhHant: "程度如何？") }
        static var done: String                { L("記録しました",      en: "Logged",                   zhHans: "已记录",       zhHant: "已記錄") }
        static var medication: String          { L("薬を飲んだ",        en: "Took medication",          zhHans: "已服药",       zhHant: "已服藥") }
        static var medicationTaken: String     { L("薬を飲んだ",        en: "Took medication",          zhHans: "已服药",       zhHant: "已服藥") }
        static var settled: String             { L("落ち着いた",        en: "Settled down",             zhHans: "已缓解",       zhHant: "已緩解") }
        static var settledButton: String       { L("完了",             en: "Done",                     zhHans: "完成",         zhHant: "完成") }
        static var addNote: String             { L("メモを追加",        en: "Add note",                 zhHans: "添加备注",     zhHant: "新增備註") }
        static var edit: String                { L("編集",             en: "Edit",                     zhHans: "编辑",         zhHant: "編輯") }
        static var delete: String              { L("削除",             en: "Delete",                   zhHans: "删除",         zhHant: "刪除") }
        static var deleteConfirm: String       { L("この記録を削除しますか？", en: "Delete this record?", zhHans: "确定删除此记录？", zhHant: "確定刪除此記錄？") }
        static var whySettled: String          { L("どうして落ち着きましたか？", en: "Why did it settle down?", zhHans: "是什么原因缓解的？", zhHant: "是什麼原因緩解的？") }
        static var settledFooter: String       { L(
            "症状が治まったら記録しておくと、通院時のレポートに持続時間が表示されます",
            en: "Recording when symptoms settle lets you track duration in your doctor's report",
            zhHans: "症状缓解后记录，就诊报告中将显示持续时间",
            zhHant: "症狀緩解後記錄，就診報告中將顯示持續時間"
        ) }
        static var premiumUnlockCustom: String { L(
            "プレミアムでカスタム症状を無制限追加",
            en: "Add unlimited custom symptoms with Premium",
            zhHans: "升级高级版，无限添加自定义症状",
            zhHant: "升級進階版，無限新增自訂症狀"
        ) }
        static var settleTimeTitle: String     { L("落ち着いた時刻",    en: "Time it settled",          zhHans: "缓解时间",     zhHant: "緩解時間") }
        static var settleConfirm: String       { L("記録する",         en: "Save",                     zhHans: "保存",         zhHant: "儲存") }
        static var settleTimeInvalidPast: String { L(
            "記録した時刻より前は選択できません",
            en: "Cannot select a time before the logged time",
            zhHans: "不能选择记录时间之前",
            zhHant: "不能選擇記錄時間之前"
        ) }
        static var settleTimeInvalidFuture: String { L(
            "まだ未来の時刻は選択できません",
            en: "Cannot select a future time",
            zhHans: "不能选择未来时间",
            zhHant: "不能選擇未來時間"
        ) }
        static var latestUnsettledLabel: String { L("まだ続いていますか？", en: "Still ongoing?", zhHans: "仍在持续吗？", zhHant: "仍在持續嗎？") }
        static var unsettled: String           { L("未解消",            en: "Ongoing",                  zhHans: "未缓解",       zhHant: "未緩解") }
    }

    // ── 履歴 ─────────────────────────────────────────────
    enum History {
        static var title: String        { L("履歴",            en: "History",                      zhHans: "历史",         zhHant: "歷史") }
        static var today: String        { L("今日",            en: "Today",                        zhHans: "今天",         zhHant: "今天") }
        static var noRecords: String    { L("記録がありません",  en: "No records",                   zhHans: "暂无记录",     zhHant: "暫無記錄") }
        static var last14Days: String   { L("直近14日",        en: "Last 14 days",                 zhHans: "近14天",       zhHant: "近14天") }
        static var olderRecords: String { L("それ以前の記録はプレミアムで確認できます", en: "View older records with Premium", zhHans: "升级高级版查看更早的记录", zhHant: "升級進階版查看更早的記錄") }
    }

    // ── 傾向 ─────────────────────────────────────────────
    enum Trends {
        static var title: String               { L("傾向",              en: "Trends",                   zhHans: "趋势",         zhHant: "趨勢") }
        static var bySymptom: String           { L("症状別",            en: "By Symptom",               zhHans: "按症状",       zhHant: "依症狀") }
        static var byTimeOfDay: String         { L("時間帯別",          en: "By Time of Day",           zhHans: "按时段",       zhHant: "依時段") }
        static var byDayOfWeek: String         { L("曜日別",            en: "By Day of Week",           zhHans: "按星期",       zhHant: "依星期") }
        static var severityDistribution: String { L("強さの分布",       en: "Severity Distribution",    zhHans: "程度分布",     zhHant: "程度分布") }
        static var monthComparison: String     { L("先月との比較",      en: "vs. Last Month",           zhHans: "与上月比较",   zhHant: "與上月比較") }
        static var periodPremium: String       { L("全期間の傾向",      en: "All-time Trends",          zhHans: "全期间趋势",   zhHant: "全期間趨勢") }
        static var periodFree: String          { L("直近14日間の傾向（無料プラン）", en: "Last 14-Day Trends (Free Plan)", zhHans: "近14天趋势（免费计划）", zhHant: "近14天趨勢（免費方案）") }
        static var recordCount: String         { L("記録件数",          en: "Records",                  zhHans: "记录件数",     zhHant: "記錄件數") }
        static var medicationCount: String     { L("服薬回数",          en: "Medications",              zhHans: "服药次数",     zhHant: "服藥次數") }
        static var dayOfWeekLocked: String     { L("曜日別傾向はプレミアム機能です", en: "Day-of-week trends require Premium", zhHans: "按星期分析需要高级版", zhHant: "依星期分析需要進階版") }
        static var upgrade: String             { L("アップグレード",    en: "Upgrade",                  zhHans: "升级",         zhHant: "升級") }
        static var avgDuration: String         { L("平均持続時間",      en: "Avg. Duration",            zhHans: "平均持续时间", zhHant: "平均持續時間") }
        static var period7days: String         { L("7日",              en: "7 Days",                   zhHans: "7天",          zhHant: "7天") }
        static var period30days: String        { L("30日",             en: "30 Days",                  zhHans: "30天",         zhHant: "30天") }
        static var periodAll: String           { L("全期間",           en: "All Time",                 zhHans: "全期间",       zhHant: "全期間") }
        static var dailyChart: String          { L("日別記録",          en: "Daily Records",            zhHans: "每日记录",     zhHant: "每日記錄") }
        static var noDataInPeriod: String      { L("この期間の記録はありません", en: "No records in this period", zhHans: "此期间暂无记录", zhHant: "此期間暫無記錄") }
        static var symptomDays: String         { L("記録のあった日",    en: "Days with records",        zhHans: "有记录的天数", zhHant: "有記錄的天數") }
        static var byWeather: String           { L("天気別",           en: "By Weather",               zhHans: "按天气",       zhHant: "依天氣") }
        static var byPressureZone: String      { L("気圧帯別",         en: "By Pressure Zone",         zhHans: "按气压带",     zhHant: "依氣壓帶") }
        static var pressureChange: String      { L("気圧変化との関係",  en: "Pressure Change Correlation", zhHans: "与气压变化的关系", zhHant: "與氣壓變化的關係") }
        static var pressureDrop: String        { L("気圧下降時（前3h -2hPa以上）", en: "Pressure Drop (−2 hPa / 3h+)", zhHans: "气压下降时（前3h -2hPa以上）", zhHant: "氣壓下降時（前3h -2hPa以上）") }
        static var pressureNormal: String      { L("その他の時間",     en: "Other times",              zhHans: "其他时间",     zhHant: "其他時間") }
        static var pressureLow: String         { L("低気圧（<1005hPa）", en: "Low (<1005 hPa)",        zhHans: "低气压（<1005hPa）", zhHant: "低氣壓（<1005hPa）") }
        static var pressureMid: String         { L("通常（1005-1020hPa）", en: "Normal (1005–1020 hPa)", zhHans: "正常（1005-1020hPa）", zhHant: "正常（1005-1020hPa）") }
        static var pressureHigh: String        { L("高気圧（>1020hPa）", en: "High (>1020 hPa)",       zhHans: "高气压（>1020hPa）", zhHant: "高氣壓（>1020hPa）") }
        static var noEnvironmentData: String   { L(
            "位置情報を許可すると天気・気圧データが記録されます",
            en: "Allow location to record weather and pressure data",
            zhHans: "允许位置信息以记录天气和气压数据",
            zhHant: "允許位置資訊以記錄天氣和氣壓數據"
        ) }
        static var premiumFeatureTeaser: String { L("プレミアムで分析を解放", en: "Unlock analysis with Premium", zhHans: "升级高级版解锁分析功能", zhHant: "升級進階版解鎖分析功能") }
        static var timeMorning: String         { L("朝（5〜12時）",    en: "Morning (5–12)",           zhHans: "早晨（5〜12时）", zhHant: "早晨（5〜12時）") }
        static var timeAfternoon: String       { L("昼（12〜17時）",   en: "Afternoon (12–17)",        zhHans: "下午（12〜17时）", zhHant: "下午（12〜17時）") }
        static var timeEvening: String         { L("夕（17〜21時）",   en: "Evening (17–21)",          zhHans: "傍晚（17〜21时）", zhHant: "傍晚（17〜21時）") }
        static var timeNight: String           { L("夜（21〜5時）",    en: "Night (21–5)",             zhHans: "夜晚（21〜5时）",  zhHant: "夜晚（21〜5時）") }
        static var timeMorningShort: String    { L("朝",              en: "Morn.",                    zhHans: "早",           zhHant: "早") }
        static var timeAfternoonShort: String  { L("昼",              en: "Aft.",                     zhHans: "午",           zhHant: "午") }
        static var timeEveningShort: String    { L("夕",              en: "Eve.",                     zhHans: "晚",           zhHant: "晚") }
        static var timeNightShort: String      { L("夜",              en: "Night",                    zhHans: "夜",           zhHant: "夜") }
        static var countSuffix: String         { L("件",              en: "",                         zhHans: "条",           zhHant: "條") }
        /// 曜日ラベル（月曜起点 index 0〜6）
        static var weekdayLabels: [String] {
            switch AppLanguage.current {
            case .ja:     return ["月", "火", "水", "木", "金", "土", "日"]
            case .en:     return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .zhHans: return ["一", "二", "三", "四", "五", "六", "日"]
            case .zhHant: return ["一", "二", "三", "四", "五", "六", "日"]
            }
        }
        static let weekendIndices: Set<Int> = [5, 6]  // 土=5, 日=6（全言語共通）
    }

    // ── 環境分析 ─────────────────────────────────────────
    enum Environment {
        static var title: String       { L("環境との関係",      en: "Environment",              zhHans: "与环境的关系",   zhHant: "與環境的關係") }
        static var pressure: String    { L("気圧",             en: "Pressure",                 zhHans: "气压",         zhHant: "氣壓") }
        static var weather: String     { L("天気",             en: "Weather",                  zhHans: "天气",         zhHant: "天氣") }
        static var temperature: String { L("気温",             en: "Temperature",              zhHans: "气温",         zhHant: "氣溫") }
        static var humidity: String    { L("湿度",             en: "Humidity",                 zhHans: "湿度",         zhHant: "濕度") }
        static var airQuality: String  { L("空気質",           en: "Air Quality",              zhHans: "空气质量",     zhHant: "空氣品質") }
        static var pm25: String        { L("PM2.5",            en: "PM2.5",                    zhHans: "PM2.5",        zhHant: "PM2.5") }
        /// 相関ヒントの表現（原因断定しない）
        static var hintPressure: String { L(
            "気圧が下がった日に記録が多い傾向があります",
            en: "Records tend to be more frequent on days when pressure drops",
            zhHans: "气压下降的日子记录较多的趋势",
            zhHant: "氣壓下降的日子記錄較多的趨勢"
        ) }
        static var hintAirQuality: String { L(
            "空気質が低い日に不調記録が重なる可能性があります",
            en: "Records may be more frequent on days with poor air quality",
            zhHans: "空气质量差的日子可能有更多记录",
            zhHant: "空氣品質差的日子可能有更多記錄"
        ) }
        static var hintTemperature: String { L(
            "気温差が大きい日に記録が見られます",
            en: "Records are observed on days with large temperature changes",
            zhHans: "温差大的日子可见到更多记录",
            zhHant: "溫差大的日子可見到更多記錄"
        ) }
        static var hintGeneral: String { L(
            "記録と環境データの関係を参考情報として表示しています",
            en: "Showing the relationship between records and environmental data as reference information",
            zhHans: "以参考信息的形式显示记录与环境数据的关系",
            zhHant: "以參考資訊的形式顯示記錄與環境數據的關係"
        ) }
        // 空状態
        static var noDataTitle: String  { L("天気・気圧データがありません", en: "No weather / pressure data", zhHans: "暂无天气・气压数据", zhHant: "暫無天氣・氣壓數據") }
        static var noDataBody: String   { L(
            "天気・気圧との関係を見るには、位置情報の許可が必要です。気圧はセンサーで取得しているため、位置を許可しなくても気圧データは収集されます。",
            en: "Location permission is required to see weather and pressure correlations. Pressure data is collected via sensor even without location permission.",
            zhHans: "需要位置信息许可才能查看天气与气压的关系。气压数据通过传感器获取，无需位置许可即可收集。",
            zhHant: "需要位置資訊許可才能查看天氣與氣壓的關係。氣壓數據通過感應器取得，無需位置許可即可收集。"
        ) }
        static var noDataButton: String { L("設定で位置情報を許可する", en: "Allow location in Settings", zhHans: "在设置中允许位置信息", zhHant: "在設定中允許位置資訊") }
        static var noDataYet: String    { L("環境データがまだ記録されていません", en: "No environment data recorded yet", zhHans: "尚未记录环境数据", zhHant: "尚未記錄環境數據") }
    }

    // ── Health 分析 ──────────────────────────────────────
    enum Health {
        static var title: String           { L("Healthとの関係",    en: "Health Correlations",      zhHans: "与Health的关系",  zhHant: "與Health的關係") }
        static var sleep: String           { L("睡眠",             en: "Sleep",                    zhHans: "睡眠",         zhHant: "睡眠") }
        static var heartRate: String       { L("心拍",             en: "Heart Rate",               zhHans: "心率",         zhHant: "心率") }
        static var steps: String           { L("歩数",             en: "Steps",                    zhHans: "步数",         zhHant: "步數") }
        static var permissionTitle: String { L("Apple Healthと連携", en: "Connect Apple Health",   zhHans: "连接 Apple Health", zhHant: "連接 Apple Health") }
        static var permissionBody: String  { L(
            "睡眠・心拍・歩数などと不調記録の関係を振り返れるようになります",
            en: "You can review the relationship between sleep, heart rate, steps, and your symptom records",
            zhHans: "您可以回顾睡眠、心率、步数与症状记录的关系",
            zhHant: "您可以回顧睡眠、心率、步數與症狀記錄的關係"
        ) }
        /// 相関ヒントの表現（原因断定しない）
        static var hintSleep: String { L(
            "睡眠時間が短い日の前後で記録が多い傾向があります",
            en: "Records tend to be more frequent around days with less sleep",
            zhHans: "睡眠不足的前后记录较多的趋势",
            zhHant: "睡眠不足的前後記錄較多的趨勢"
        ) }
        static var hintHeartRate: String { L(
            "安静時心拍が高めの日に不調記録が重なることがあります",
            en: "Records may coincide with days when resting heart rate is elevated",
            zhHans: "安静时心率偏高的日子可能有更多记录",
            zhHant: "安靜時心率偏高的日子可能有更多記錄"
        ) }
        // 空状態・接続誘導
        static var connectTitle: String  { L("Apple Healthと連携すると", en: "When you connect Apple Health", zhHans: "连接 Apple Health 后", zhHant: "連接 Apple Health 後") }
        static var connectBody: String   { L(
            "睡眠・安静時心拍・歩数と症状の関係が見えるようになります。",
            en: "You can see the relationship between sleep, resting heart rate, steps, and symptoms.",
            zhHans: "您可以查看睡眠、安静时心率、步数与症状的关系。",
            zhHant: "您可以查看睡眠、安靜時心率、步數與症狀的關係。"
        ) }
        static var connectButton: String { L("Apple Healthの連携を許可する", en: "Allow Apple Health access", zhHans: "允许 Apple Health 访问", zhHant: "允許 Apple Health 存取") }
        static var noDataYet: String     { L("Healthデータがまだ記録されていません", en: "No Health data recorded yet", zhHans: "尚未记录Health数据", zhHant: "尚未記錄Health數據") }
        // データラベル
        static var shortSleepRecord: String  { L("6時間未満の日の記録",    en: "Records on days with <6h sleep",    zhHans: "睡眠不足6小时的记录",   zhHant: "睡眠不足6小時的記錄") }
        static var normalSleepRecord: String { L("6時間以上の日の記録",    en: "Records on days with ≥6h sleep",    zhHans: "睡眠6小时以上的记录",   zhHant: "睡眠6小時以上的記錄") }
        static var highHRRecord: String      { L("安静時心拍高めの日の記録", en: "Records on days with high resting HR", zhHans: "安静时心率偏高的记录", zhHant: "安靜時心率偏高的記錄") }
        static var normalHRRecord: String    { L("通常の日の記録",         en: "Records on normal days",            zhHans: "正常日的记录",         zhHant: "正常日的記錄") }
        static var avgStepsRecord: String    { L("記録日の平均歩数",        en: "Avg. steps on record days",         zhHans: "记录日的平均步数",     zhHant: "記錄日的平均步數") }
    }

    // ── レポート ─────────────────────────────────────────
    enum Report {
        static var title: String              { L("通院向けレポート",    en: "Doctor's Report",          zhHans: "就诊报告",         zhHant: "就診報告") }
        static var summary: String            { L("要約",              en: "Summary",                  zhHans: "摘要",             zhHant: "摘要") }
        static var detail: String             { L("詳細",              en: "Details",                  zhHans: "详情",             zhHant: "詳情") }
        static var exportPDF: String          { L("PDFで出力",         en: "Export as PDF",            zhHans: "导出PDF",           zhHant: "匯出PDF") }
        static var exportCSV: String          { L("CSVで出力",         en: "Export as CSV",            zhHans: "导出CSV",           zhHant: "匯出CSV") }
        static var periodSelect: String       { L("期間を選択",         en: "Select Period",            zhHans: "选择期间",          zhHant: "選擇期間") }
        static var startDate: String          { L("開始",              en: "Start",                    zhHans: "开始",              zhHant: "開始") }
        static var endDate: String            { L("終了",              en: "End",                      zhHans: "结束",              zhHant: "結束") }
        static var recordCount: String        { L("記録件数",           en: "Records",                  zhHans: "记录件数",          zhHant: "記錄件數") }
        static var medicationCount: String    { L("服薬回数",           en: "Medications",              zhHans: "服药次数",          zhHant: "服藥次數") }
        static var avgSettleTime: String      { L("落ち着くまでの平均",  en: "Avg. time to settle",      zhHans: "平均缓解时间",       zhHant: "平均緩解時間") }
        static var exportSection: String      { L("出力",              en: "Export",                   zhHans: "导出",              zhHant: "匯出") }
        static var upgradeToExport: String    { L("アップグレードして出力する", en: "Upgrade to export", zhHans: "升级后导出",         zhHant: "升級後匯出") }
        static var disclaimer: String         { L(
            "このレポートは記録データに基づく参考情報です。医療上の判断に代わるものではありません。",
            en: "This report is reference information based on recorded data. It does not replace medical judgment.",
            zhHans: "本报告是基于记录数据的参考信息，不代替医疗判断。",
            zhHant: "本報告是基於記錄數據的參考資訊，不代替醫療判斷。"
        ) }
        static var doctorCTA: String          { L("通院前にレポートをまとめますか？", en: "Prepare a report before your appointment?", zhHans: "就诊前整理报告？", zhHant: "就診前整理報告？") }
        static var doctorCTABody: String      { L(
            "記録をPDFにまとめて、医師と共有しやすくなります",
            en: "Compile your records into a PDF to share with your doctor",
            zhHans: "将记录整理为PDF，方便与医生分享",
            zhHant: "將記錄整理為PDF，方便與醫生分享"
        ) }
        static var doctorCTAButton: String    { L("レポートを見る",      en: "View Report",              zhHans: "查看报告",          zhHant: "查看報告") }
        static var premiumRequiredPDF: String { L("PDF出力はプレミアム機能です", en: "PDF export requires Premium", zhHans: "PDF导出需要高级版", zhHant: "PDF匯出需要進階版") }
        static var premiumRequiredCSV: String { L("CSV出力はプレミアム機能です", en: "CSV export requires Premium", zhHans: "CSV导出需要高级版", zhHant: "CSV匯出需要進階版") }

        // ── PDF セクション見出し ──
        static var pdfSectionSummary: String     { L("サマリー",       en: "Summary",                  zhHans: "摘要",             zhHant: "摘要") }
        static var pdfSectionSymptom: String     { L("症状別内訳",     en: "By Symptom",               zhHans: "按症状分类",        zhHant: "依症狀分類") }
        static var pdfSectionSeverity: String    { L("強さの分布",     en: "Severity Distribution",    zhHans: "程度分布",          zhHant: "程度分布") }
        static var pdfSectionTimeOfDay: String   { L("時間帯別分布",   en: "Time of Day Distribution", zhHans: "按时段分布",        zhHant: "依時段分布") }
        static var pdfSectionDayOfWeek: String   { L("曜日別分布",     en: "Day of Week Distribution", zhHans: "按星期分布",        zhHant: "依星期分布") }
        static var pdfSectionEnvironment: String { L("環境データ",     en: "Environment Data",         zhHans: "环境数据",          zhHant: "環境數據") }
        static var pdfSectionHealth: String      { L("Health データ",  en: "Health Data",              zhHans: "Health数据",        zhHant: "Health數據") }

        // ── PDF テーブルヘッダー ──
        static var tableColDate: String       { L("日時",         en: "Date/Time",        zhHans: "日期时间",     zhHant: "日期時間") }
        static var tableColSymptom: String    { L("症状",         en: "Symptom",          zhHans: "症状",         zhHant: "症狀") }
        static var tableColSeverity: String   { L("強さ",         en: "Severity",         zhHans: "程度",         zhHant: "程度") }
        static var tableColDuration: String   { L("持続",         en: "Duration",         zhHans: "持续时间",     zhHant: "持續時間") }
        static var tableColMed: String        { L("服薬",         en: "Medication",       zhHans: "服药",         zhHant: "服藥") }
        static var tableColEnvWeather: String { L("天気/気圧",    en: "Weather/Pressure", zhHans: "天气/气压",    zhHant: "天氣/氣壓") }
        static var tableColMemo: String       { L("メモ",         en: "Notes",            zhHans: "备注",         zhHant: "備註") }

        // ── PDF フォーマット（可変部分） ──
        static func pdfTitle(_ appName: String) -> String {
            switch AppLanguage.current {
            case .ja:     return "\(appName) 通院向けレポート"
            case .en:     return "\(appName) Doctor's Report"
            case .zhHans: return "\(appName) 就诊报告"
            case .zhHant: return "\(appName) 就診報告"
            }
        }
        static func pdfSectionWithCount(_ section: String, count: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "\(section)（記録あり \(count)件）"
            case .en:     return "\(section) (\(count) records)"
            case .zhHans: return "\(section)（有记录 \(count)条）"
            case .zhHant: return "\(section)（有記錄 \(count)條）"
            }
        }
        static func pdfRecordListTitle(_ count: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "記録一覧（全\(count)件・新しい順）"
            case .en:     return "Record List (\(count) total, newest first)"
            case .zhHans: return "记录列表（共\(count)条・时间倒序）"
            case .zhHant: return "記錄列表（共\(count)條・時間倒序）"
            }
        }
        static func symptomDaysSummary(symptomDays: Int, periodDays: Int, monthly: Double) -> String {
            let m = String(format: "%.1f", monthly)
            switch AppLanguage.current {
            case .ja:     return "症状のあった日数: \(symptomDays)日 / \(periodDays)日間（月換算 \(m)日/月）"
            case .en:     return "Days with symptoms: \(symptomDays) / \(periodDays) days (approx. \(m) days/month)"
            case .zhHans: return "有症状的天数: \(symptomDays)天 / \(periodDays)天（月均 \(m)天/月）"
            case .zhHant: return "有症狀的天數: \(symptomDays)天 / \(periodDays)天（月均 \(m)天/月）"
            }
        }
        static func totalRecordsSummary(_ count: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "総記録件数: \(count)件"
            case .en:     return "Total records: \(count)"
            case .zhHans: return "总记录数: \(count)条"
            case .zhHant: return "總記錄數: \(count)條"
            }
        }
        static func medicationSummary(count: Int, days: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "服薬回数: \(count)回（服薬した日数: \(days)日）"
            case .en:     return "Medications taken: \(count) times (\(days) days)"
            case .zhHans: return "服药次数: \(count)次（服药天数: \(days)天）"
            case .zhHant: return "服藥次數: \(count)次（服藥天數: \(days)天）"
            }
        }
        static func avgDurationSummary(avg: Int, max: String) -> String {
            switch AppLanguage.current {
            case .ja:     return "平均持続時間: \(avg)分　最長: \(max)"
            case .en:     return "Avg. duration: \(avg) min  Longest: \(max)"
            case .zhHans: return "平均持续时间: \(avg)分钟  最长: \(max)"
            case .zhHant: return "平均持續時間: \(avg)分鐘  最長: \(max)"
            }
        }
        static func avgDurationSummaryAvgOnly(avg: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "平均持続時間: \(avg)分"
            case .en:     return "Avg. duration: \(avg) min"
            case .zhHans: return "平均持续时间: \(avg)分钟"
            case .zhHant: return "平均持續時間: \(avg)分鐘"
            }
        }
        static func mohWarning(_ days: Int) -> String {
            switch AppLanguage.current {
            case .ja:
                return "⚠️ 月換算で服薬日数が\(days)日を超えています。薬物乱用頭痛（MOH）のリスクがあります。受診時に医師にお伝えください。"
            case .en:
                return "⚠️ Estimated medication days exceed \(days) per month. This may indicate a risk of Medication Overuse Headache (MOH). Please mention this to your doctor."
            case .zhHans:
                return "⚠️ 月均服药天数超过\(days)天，存在药物过度使用性头痛（MOH）风险，请就诊时告知医生。"
            case .zhHant:
                return "⚠️ 月均服藥天數超過\(days)天，存在藥物過度使用性頭痛（MOH）風險，請就診時告知醫生。"
            }
        }
        static func pressureDropStat(count: Int, pct: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "気圧下降時（前3時間で -2hPa 以上）の記録: \(count)件 (\(pct)%)"
            case .en:     return "Records during pressure drop (−2 hPa/3h+): \(count) (\(pct)%)"
            case .zhHans: return "气压下降时（前3小时 -2hPa以上）的记录: \(count)条 (\(pct)%)"
            case .zhHant: return "氣壓下降時（前3小時 -2hPa以上）的記錄: \(count)條 (\(pct)%)"
            }
        }
        static func avgTemperatureStat(_ temp: Double) -> String {
            switch AppLanguage.current {
            case .ja:     return String(format: "平均気温: %.1f℃", temp)
            case .en:     return String(format: "Avg. temperature: %.1f℃", temp)
            case .zhHans: return String(format: "平均气温: %.1f℃", temp)
            case .zhHant: return String(format: "平均氣溫: %.1f℃", temp)
            }
        }
        static func avgHumidityStat(_ humidity: Double) -> String {
            switch AppLanguage.current {
            case .ja:     return String(format: "平均湿度: %.0f%%", humidity)
            case .en:     return String(format: "Avg. humidity: %.0f%%", humidity)
            case .zhHans: return String(format: "平均湿度: %.0f%%", humidity)
            case .zhHant: return String(format: "平均濕度: %.0f%%", humidity)
            }
        }
        static func shortSleepStat(short: Int, total: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "睡眠6時間未満の日の記録: \(short)件 / \(total)件"
            case .en:     return "Records on days with <6h sleep: \(short) / \(total)"
            case .zhHans: return "睡眠不足6小时的记录: \(short)条 / \(total)条"
            case .zhHant: return "睡眠不足6小時的記錄: \(short)條 / \(total)條"
            }
        }
        static func avgRestingHRStat(_ bpm: Double) -> String {
            switch AppLanguage.current {
            case .ja:     return String(format: "平均安静時心拍: %.0f bpm", bpm)
            case .en:     return String(format: "Avg. resting heart rate: %.0f bpm", bpm)
            case .zhHans: return String(format: "平均安静时心率: %.0f bpm", bpm)
            case .zhHant: return String(format: "平均安靜時心率: %.0f bpm", bpm)
            }
        }
        static func avgHRVStat(_ ms: Double) -> String {
            switch AppLanguage.current {
            case .ja:     return String(format: "平均心拍変動 (HRV): %.0f ms", ms)
            case .en:     return String(format: "Avg. heart rate variability (HRV): %.0f ms", ms)
            case .zhHans: return String(format: "平均心率变异性 (HRV): %.0f ms", ms)
            case .zhHant: return String(format: "平均心率變異性 (HRV): %.0f ms", ms)
            }
        }
        static func symptomDistributionRow(name: String, count: Int, pct: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "\(name): \(count)件 (\(pct)%)"
            case .en:     return "\(name): \(count) (\(pct)%)"
            case .zhHans: return "\(name): \(count)条 (\(pct)%)"
            case .zhHant: return "\(name): \(count)條 (\(pct)%)"
            }
        }
        static func timeOfDayRow(label: String, count: Int, pct: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "\(label): \(count)件 (\(pct)%)"
            case .en:     return "\(label): \(count) (\(pct)%)"
            case .zhHans: return "\(label): \(count)条 (\(pct)%)"
            case .zhHant: return "\(label): \(count)條 (\(pct)%)"
            }
        }
        static func weatherStat(_ items: String) -> String {
            switch AppLanguage.current {
            case .ja:     return "天気別: \(items)"
            case .en:     return "By weather: \(items)"
            case .zhHans: return "按天气: \(items)"
            case .zhHant: return "依天氣: \(items)"
            }
        }

        // ── CSV 列ヘッダー（順序固定・変更禁止） ──
        static var csvHeaders: [String] {
            switch AppLanguage.current {
            case .ja:
                return [
                    "日時", "症状", "強さ", "強さラベル", "服薬", "服薬時刻",
                    "落ち着いた時刻", "持続時間(分)", "落ち着いた要因", "メモ", "記録元",
                    "天気", "気圧(hPa)", "気圧変化3h(hPa)", "気温(℃)", "湿度(%)",
                    "空気質(AQI)", "PM2.5", "睡眠(時間)", "安静時心拍(bpm)", "歩数", "曜日", "時間帯",
                ]
            case .en:
                return [
                    "Date/Time", "Symptom", "Severity", "Severity Label", "Medication", "Medication Time",
                    "Settled Time", "Duration (min)", "Settle Cause", "Notes", "Source",
                    "Weather", "Pressure (hPa)", "Pressure Change 3h (hPa)", "Temperature (℃)", "Humidity (%)",
                    "Air Quality (AQI)", "PM2.5", "Sleep (h)", "Resting HR (bpm)", "Steps", "Day of Week", "Time of Day",
                ]
            case .zhHans:
                return [
                    "日期时间", "症状", "程度", "程度标签", "服药", "服药时间",
                    "缓解时间", "持续时间(分)", "缓解原因", "备注", "记录来源",
                    "天气", "气压(hPa)", "气压变化3h(hPa)", "气温(℃)", "湿度(%)",
                    "空气质量(AQI)", "PM2.5", "睡眠(小时)", "安静心率(bpm)", "步数", "星期", "时段",
                ]
            case .zhHant:
                return [
                    "日期時間", "症狀", "程度", "程度標籤", "服藥", "服藥時間",
                    "緩解時間", "持續時間(分)", "緩解原因", "備註", "記錄來源",
                    "天氣", "氣壓(hPa)", "氣壓變化3h(hPa)", "氣溫(℃)", "濕度(%)",
                    "空氣品質(AQI)", "PM2.5", "睡眠(小時)", "安靜心率(bpm)", "步數", "星期", "時段",
                ]
            }
        }
    }

    // ── 課金 ─────────────────────────────────────────────
    enum Paywall {
        static var title: String       { L("プレミアムプラン",             en: "Premium Plan",             zhHans: "高级计划",         zhHant: "進階方案") }
        static var subtitle: String    { L("傾向を深く知り、通院時にも役立てる", en: "Deeper insights, useful at medical appointments", zhHans: "深入了解规律，就诊时更有帮助", zhHant: "深入了解規律，就診時更有幫助") }
        static var description: String { L("必要な時だけ、より深く振り返れます", en: "Dig deeper whenever you need it", zhHans: "需要时进行更深入的回顾", zhHant: "需要時進行更深入的回顧") }
        static var monthlyLabel: String { L("月額", en: "Monthly", zhHans: "月付", zhHant: "月付") }
        static var yearlyLabel: String  { L("年額", en: "Yearly",  zhHans: "年付", zhHant: "年付") }
        static var yearlySaving: String { L("月換算 ¥300（37% オフ）", en: "¥300/mo (37% off)", zhHans: "月均 ¥300（省37%）", zhHant: "月均 ¥300（省37%）") }
        static var trialLabel: String   { L("プレミアムにアップグレード", en: "Upgrade to Premium", zhHans: "升级到高级版", zhHant: "升級到進階版") }
        static var restoreLabel: String { L("購入を復元",                en: "Restore Purchases",        zhHans: "恢复购买",         zhHant: "恢復購買") }
        static var freeNote: String     { L(
            "無料でも記録・基本履歴・カレンダーはずっと使えます",
            en: "Logging, basic history, and calendar are always free",
            zhHans: "免费版可永久使用记录、基本历史和日历",
            zhHant: "免費版可永久使用記錄、基本歷史和日曆"
        ) }
        static var ctaStart: String           { L("今すぐ始める", en: "Get Started", zhHans: "立即开始", zhHant: "立即開始") }
        static var trialAutoRenew: String     { L(
            "自動更新。いつでもキャンセル可。",
            en: "Auto-renews. Cancel anytime.",
            zhHans: "自动续订，随时可取消。",
            zhHant: "自動續訂，隨時可取消。"
        ) }
        /// Apple 必須の定型開示文（変更禁止 — 各言語とも正確に記載すること）
        static var subscriptionDisclosure: String { L(
            "サブスクリプションは確認時にApple IDに課金されます。現在の期間終了の少なくとも24時間前にキャンセルしない限り自動更新されます。",
            en: "Subscriptions are charged to your Apple ID at confirmation. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.",
            zhHans: "订阅在确认时向您的Apple ID收费。除非在当前订阅期结束前至少24小时取消，否则将自动续订。",
            zhHant: "訂閱在確認時向您的Apple ID收費。除非在當前訂閱期結束前至少24小時取消，否則將自動續訂。"
        ) }
        // 機能一覧
        static var featureHistory: String  { L("無制限の履歴保存",              en: "Unlimited history",                        zhHans: "无限历史记录",             zhHant: "無限歷史記錄") }
        static var featureReport: String   { L("通院向けPDF / CSVレポート",      en: "Doctor's PDF / CSV reports",               zhHans: "就诊PDF / CSV报告",        zhHant: "就診PDF / CSV報告") }
        static var featureTrends: String   { L("時間帯別・曜日別・強さ分布の傾向",  en: "Time-of-day, day-of-week & severity trends", zhHans: "时段、星期与程度分析",     zhHant: "時段、星期與程度分析") }
        static var featureWeather: String  { L("天気別・気圧帯別の記録分析",       en: "Weather & pressure zone analysis",         zhHans: "天气别・气压带别分析",      zhHant: "天氣別・氣壓帶別分析") }
        static var featurePressure: String { L("気圧変化と症状の相関表示",         en: "Pressure change correlation display",      zhHans: "气压变化与症状相关性显示",  zhHant: "氣壓變化與症狀相關性顯示") }
        static var featureHealth: String   { L("Health連携の詳細分析",            en: "Detailed Health data analysis",            zhHans: "Health联动详细分析",         zhHant: "Health聯動詳細分析") }
        static var featureCustom: String   { L("カスタム症状・薬タグ無制限",        en: "Unlimited custom symptoms & med tags",     zhHans: "无限自定义症状与药物标签",  zhHant: "無限自訂症狀與藥物標籤") }
        // プランカード
        static var planYearly: String     { L("年額",         en: "Yearly",           zhHans: "年付",     zhHant: "年付") }
        static var planMonthly: String    { L("月額",         en: "Monthly",          zhHans: "月付",     zhHant: "月付") }
        static var yearlyDetail: String   { L("月換算 ¥333",  en: "¥333/mo",          zhHans: "月均 ¥333", zhHant: "月均 ¥333") }
        static var monthlyDetail: String  { L("いつでも解約可", en: "Cancel anytime",  zhHans: "随时可取消", zhHant: "隨時可取消") }
        static var recommended: String    { L("おすすめ",     en: "Best Value",       zhHans: "推荐",      zhHant: "推薦") }
    }

    // ── 通知 ─────────────────────────────────────────────
    enum Notification {
        static var weatherChange: String { L(
            "天気の変化が大きい予報です。必要ならすぐ記録できます",
            en: "Significant weather changes forecast. Log if needed.",
            zhHans: "天气变化较大，需要时随时记录。",
            zhHant: "天氣變化較大，需要時隨時記錄。"
        ) }
        static var pressureChange: String { L(
            "気圧変化が大きめの見込みです。必要な時はすぐ記録できます",
            en: "Significant pressure changes expected. Log when needed.",
            zhHans: "气压变化较大，需要时随时记录。",
            zhHant: "氣壓變化較大，需要時隨時記錄。"
        ) }
        static var reminder: String    { L("体調が気になる時だけ残してください", en: "Log only when you feel something is off", zhHans: "只在感到不适时记录", zhHant: "只在感到不適時記錄") }
        static var countToday: String  { L("件目です", en: " today", zhHans: "条记录", zhHant: "條記錄") }
        static var eveningTrend: String { L("今週は夕方の記録が多めです", en: "More evening records this week", zhHans: "本周傍晚记录较多", zhHant: "本週傍晚記錄較多") }
        static var severityLower: String { L("前回より強さが低めです", en: "Severity is lower than last time", zhHans: "与上次相比程度较轻", zhHant: "與上次相比程度較輕") }
    }

    // ── 記録後の見返り ───────────────────────────────────
    enum Feedback {
        static func todayCount(_ count: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "今日\(count)件目です"
            case .en:     return "Log #\(count) today"
            case .zhHans: return "今天第\(count)条记录"
            case .zhHant: return "今天第\(count)條記錄"
            }
        }
        static var eveningTrend: String  { L("今週は夕方の記録が多めです", en: "More evening records this week", zhHans: "本周傍晚记录较多", zhHant: "本週傍晚記錄較多") }
        static var severityLower: String { L("前回より強さが低めです", en: "Severity is lower than last time", zhHans: "与上次相比程度较轻", zhHant: "與上次相比程度較輕") }
    }

    // ── 設定 ─────────────────────────────────────────────
    enum Settings {
        static var title: String                    { L("設定",                  en: "Settings",                         zhHans: "设置",             zhHant: "設定") }
        static var notification: String             { L("通知",                  en: "Notifications",                    zhHans: "通知",             zhHant: "通知") }
        static var notificationEnabled: String      { L("予兆通知",               en: "Predictive Notifications",         zhHans: "预测通知",         zhHant: "預測通知") }
        static var notificationSensitivity: String  { L("通知感度",               en: "Notification Sensitivity",         zhHans: "通知灵敏度",       zhHant: "通知靈敏度") }
        static var healthIntegration: String        { L("Apple Health連携",       en: "Apple Health Integration",         zhHans: "Apple Health联动", zhHant: "Apple Health聯動") }
        static var subscription: String             { L("プラン管理",              en: "Plan Management",                  zhHans: "计划管理",         zhHant: "方案管理") }
        static var about: String                    { L("このアプリについて",       en: "About This App",                   zhHans: "关于本应用",       zhHant: "關於本應用程式") }
        static var legal: String                    { L("法的情報",               en: "Legal",                            zhHans: "法律信息",         zhHant: "法律資訊") }
        // 通知設定
        static var notificationPermissionDenied: String { L(
            "通知がオフになっています。設定アプリから許可してください。",
            en: "Notifications are off. Please allow them in the Settings app.",
            zhHans: "通知已关闭，请在设置应用中允许。",
            zhHant: "通知已關閉，請在設定應用程式中允許。"
        ) }
        static var notificationSensitivityLow: String    { L("少なめ（週1〜2回）", en: "Low (1–2 times/week)",   zhHans: "较少（每周1〜2次）", zhHant: "較少（每週1〜2次）") }
        static var notificationSensitivityNormal: String { L("通常（週3〜4回）",   en: "Normal (3–4 times/week)", zhHans: "正常（每周3〜4次）", zhHant: "正常（每週3〜4次）") }
        static var notificationSensitivityHigh: String   { L("多め（毎日）",       en: "High (daily)",           zhHans: "较多（每天）",       zhHant: "較多（每天）") }
        static var notificationFooter: String { L(
            "天気・気圧が大きく変化する予報の時にだけお知らせします。診断・予防を目的とするものではありません。",
            en: "Alerts only when weather or pressure is forecast to change significantly. Not intended for diagnosis or prevention.",
            zhHans: "仅在预报天气或气压大幅变化时通知，不以诊断或预防为目的。",
            zhHant: "僅在預報天氣或氣壓大幅變化時通知，不以診斷或預防為目的。"
        ) }
        static var notificationAuthorized: String  { L("通知が許可されています",  en: "Notifications allowed",        zhHans: "已允许通知",       zhHant: "已允許通知") }
        static var notificationOpenSettings: String { L("設定アプリを開く",       en: "Open Settings",                zhHans: "打开设置",         zhHant: "開啟設定") }
        static var notificationAllow: String        { L("通知を許可する",          en: "Allow Notifications",          zhHans: "允许通知",         zhHant: "允許通知") }
        // プラン管理
        static var planFree: String              { L("無料プラン",                en: "Free Plan",                    zhHans: "免费计划",         zhHant: "免費方案") }
        static var planPremium: String           { L("プレミアム",                en: "Premium",                      zhHans: "高级版",           zhHant: "進階版") }
        static var planBadge: String             { L("プレミアム",                en: "Premium",                      zhHans: "高级版",           zhHant: "進階版") }
        static var planTrialActive: String       { L("トライアル中",               en: "Trial Active",                 zhHans: "试用中",           zhHant: "試用中") }
        static var planUpgrade: String           { L("プレミアムにアップグレード",   en: "Upgrade to Premium",           zhHans: "升级到高级版",     zhHant: "升級到進階版") }
        static var planRestore: String           { L("購入を復元",                 en: "Restore Purchases",            zhHans: "恢复购买",         zhHant: "恢復購買") }
        static var planManageSubscription: String { L("サブスクリプションを管理",    en: "Manage Subscription",          zhHans: "管理订阅",         zhHant: "管理訂閱") }
        static var planAllFeatures: String       { L("すべての機能をご利用いただけます", en: "All features available",  zhHans: "所有功能均可使用", zhHant: "所有功能均可使用") }
        static var planFreeFeatures: String      { L("基本的な記録・履歴機能が使えます", en: "Basic logging and history available", zhHans: "可使用基本记录与历史功能", zhHant: "可使用基本記錄與歷史功能") }
        static var premiumFeaturesTitle: String  { L("プレミアム機能",              en: "Premium Features",             zhHans: "高级功能",         zhHant: "進階功能") }
        static var premiumFeaturesUpgradeTitle: String { L("プレミアムでできること", en: "What Premium unlocks",        zhHans: "高级版功能",       zhHant: "進階版功能") }
        static var planFeatureHistory: String    { L("無制限の履歴保存",             en: "Unlimited history",            zhHans: "无限历史记录",     zhHant: "無限歷史記錄") }
        static var planFeatureReport: String     { L("通院向けPDF / CSVレポート",    en: "Doctor's PDF / CSV reports",   zhHans: "就诊PDF / CSV报告", zhHant: "就診PDF / CSV報告") }
        static var planFeatureTrends: String     { L("時間帯別・曜日別・全期間の傾向分析", en: "Time-of-day, day-of-week & all-time trend analysis", zhHans: "时段、星期与全期间趋势分析", zhHant: "時段、星期與全期間趨勢分析") }
        static var planFeatureAnalysis: String   { L("天気別・気圧帯別・気圧変化の分析", en: "Weather, pressure zone & pressure change analysis", zhHans: "天气别、气压带别与气压变化分析", zhHant: "天氣別、氣壓帶別與氣壓變化分析") }
        static var planFeatureCustom: String     { L("カスタム症状・薬タグ無制限",    en: "Unlimited custom symptoms & med tags", zhHans: "无限自定义症状与药物标签", zhHant: "無限自訂症狀與藥物標籤") }
        static var planFeatureHistoryFree: String  { L("無制限の履歴保存",            en: "Unlimited history",               zhHans: "无限历史记录",           zhHant: "無限歷史記錄") }
        static var planFeatureReportFree: String   { L("通院向けPDF / CSVレポート出力", en: "Doctor's PDF / CSV export",       zhHans: "就诊PDF / CSV导出",       zhHant: "就診PDF / CSV匯出") }
        static var planFeatureTrendsFree: String   { L("曜日別傾向・詳細環境分析",     en: "Day-of-week trends & detailed environment analysis", zhHans: "星期别趋势与详细环境分析", zhHant: "星期別趨勢與詳細環境分析") }
        static var planFeatureHealthFree: String   { L("Health連携の詳細分析",         en: "Detailed Health data analysis",   zhHans: "Health联动详细分析",        zhHant: "Health聯動詳細分析") }
        static var planFeatureCustomFree: String   { L("カスタム症状・薬タグ無制限",    en: "Unlimited custom symptoms & med tags", zhHans: "无限自定义症状与药物标签", zhHant: "無限自訂症狀與藥物標籤") }
        static var planTrialBanner: String         { L("プレミアム機能を解放する",       en: "Unlock Premium Features",         zhHans: "解锁高级功能",             zhHant: "解鎖進階功能") }
        // Health設定
        static var healthNotAuthorized: String  { L("Healthへのアクセスが許可されていません", en: "Health access not authorized", zhHans: "Health访问未授权", zhHant: "Health存取未授權") }
        static var healthAllow: String          { L("Apple Healthの連携を許可する", en: "Allow Apple Health Access",    zhHans: "允许访问Apple Health",  zhHant: "允許存取Apple Health") }
        static var healthOpenSettings: String   { L("設定でHealthを許可する",     en: "Allow Health in Settings",     zhHans: "在设置中允许Health",   zhHant: "在設定中允許Health") }
        static var healthAuthorized: String     { L("Healthと連携中",             en: "Connected to Health",          zhHans: "已连接Health",         zhHant: "已連接Health") }
        static var healthDataList: String       { L(
            "取得データ：睡眠・安静時心拍・心拍変動・歩数・呼吸数・ワークアウト",
            en: "Data accessed: Sleep, Resting Heart Rate, HRV, Steps, Respiratory Rate, Workouts",
            zhHans: "获取数据：睡眠・安静时心率・心率变异性・步数・呼吸频率・锻炼",
            zhHant: "取得數據：睡眠・安靜時心率・心率變異性・步數・呼吸頻率・鍛鍊"
        ) }
        static var healthDeviceNotSupported: String { L("このデバイスはHealthKitに対応していません", en: "This device does not support HealthKit", zhHans: "此设备不支持HealthKit", zhHant: "此裝置不支援HealthKit") }
        static var healthConnectionStatus: String   { L("接続状態",             en: "Connection Status",            zhHans: "连接状态",         zhHant: "連接狀態") }
        static var healthDataSection: String        { L("取得するデータ",         en: "Data Accessed",                zhHans: "获取的数据",       zhHant: "取得的數據") }
        static var healthPrivacyNote: String        { L(
            "HealthKitデータは端末内でのみ使用し、外部に送信されることはありません。",
            en: "HealthKit data is used on-device only and never sent externally.",
            zhHans: "HealthKit数据仅在设备内使用，不会发送到外部。",
            zhHant: "HealthKit數據僅在裝置內使用，不會傳送到外部。"
        ) }
        // iCloud
        static var backup: String       { L("機種変・バックアップ",   en: "Backup & Transfer",    zhHans: "备份与换机",   zhHant: "備份與換機") }
        static var iCloudSyncing: String { L("iCloud と同期中",      en: "Syncing with iCloud",  zhHans: "与iCloud同步中", zhHant: "正在與iCloud同步") }
        static var iCloudDisabled: String { L("iCloud が無効です",    en: "iCloud is disabled",   zhHans: "iCloud已禁用",  zhHant: "iCloud已停用") }
        static var iCloudHint: String   { L(
            "設定 › Apple Account › iCloud でオンにすると機種変後もデータを引き継げます",
            en: "Enable in Settings › Apple Account › iCloud to transfer data after changing devices",
            zhHans: "在「设置 › Apple账户 › iCloud」中开启，以便换机后转移数据",
            zhHant: "在「設定 › Apple帳號 › iCloud」中開啟，以便換機後轉移數據"
        ) }
        // データ管理
        static var dataManagement: String       { L("データ管理",           en: "Data Management",          zhHans: "数据管理",         zhHant: "資料管理") }
        static var deleteAllData: String        { L("すべてのデータを削除",  en: "Delete All Data",          zhHans: "删除所有数据",     zhHant: "刪除所有資料") }
        static var deleteAllDataConfirm: String { L(
            "記録・カスタム症状を含む全データを削除します。この操作は元に戻せません。",
            en: "All data including records and custom symptoms will be deleted. This cannot be undone.",
            zhHans: "将删除包括记录和自定义症状在内的所有数据，此操作无法撤销。",
            zhHant: "將刪除包括記錄和自訂症狀在內的所有資料，此操作無法復原。"
        ) }
        static var deleteAllDataButton: String  { L("すべて削除", en: "Delete All", zhHans: "全部删除", zhHant: "全部刪除") }
    }

    // ── 法的注意書き ─────────────────────────────────────
    enum Legal {
        static var title: String              { L("法的情報",                      en: "Legal",                                zhHans: "法律信息",                     zhHant: "法律資訊") }
        static var importantNotice: String    { L("重要な注意事項",                 en: "Important Notice",                     zhHans: "重要注意事项",                 zhHant: "重要注意事項") }
        static var dataHandlingTitle: String  { L("データの取り扱い",               en: "Data Handling",                        zhHans: "数据处理",                     zhHant: "資料處理") }
        static var disclaimer1: String        { L("本アプリは診断、治療、予防を目的としたものではありません。", en: "This app is not intended for diagnosis, treatment, or prevention.", zhHans: "本应用程序不以诊断、治疗或预防为目的。", zhHant: "本應用程式不以診斷、治療或預防為目的。") }
        static var disclaimer2: String        { L("本アプリの内容は医療上の判断に代わるものではありません。", en: "The content of this app does not replace medical judgment.", zhHans: "本应用程序的内容不能代替医疗判断。", zhHant: "本應用程式的內容不能取代醫療判斷。") }
        static var disclaimer3: String        { L("体調に不安がある場合は医療機関に相談してください。", en: "If you have health concerns, please consult a medical professional.", zhHans: "如有健康问题，请咨询医疗机构。", zhHant: "如有健康問題，請諮詢醫療機構。") }
        static var disclaimer4: String        { L("表示される傾向は記録データに基づく参考情報です。", en: "Trends shown are reference information based on recorded data.", zhHans: "显示的趋势是基于记录数据的参考信息。", zhHant: "顯示的趨勢是基於記錄數據的參考資訊。") }
        static var dataLocal: String          { L("すべてのデータは端末内に保存されます",    en: "All data is stored on-device",                 zhHans: "所有数据均保存在设备内",           zhHant: "所有資料均保存在裝置內") }
        static var dataNoExternal: String     { L("健康データを外部に送信することはありません", en: "Health data is never sent externally",          zhHans: "健康数据不会发送到外部",           zhHant: "健康數據不會傳送到外部") }
        static var locationRounded: String    { L("位置情報は市区町村レベルに丸めて保存されます", en: "Location is rounded to city/town level before storage", zhHans: "位置信息经四舍五入至市区町村级别后保存", zhHant: "位置資訊經四捨五入至市區町村層級後儲存") }
        static var trendsDisclaimer: String   { L("表示される傾向は記録データに基づく参考情報です", en: "Trends shown are reference information based on recorded data", zhHans: "显示的趋势是基于记录数据的参考信息", zhHant: "顯示的趨勢是基於記錄數據的參考資訊") }
        static var privacyPolicy: String      { L("プライバシーポリシー",             en: "Privacy Policy",                       zhHans: "隐私政策",                     zhHant: "隱私政策") }
        static var termsOfService: String     { L("利用規約",                       en: "Terms of Service",                     zhHans: "使用条款",                     zhHant: "使用條款") }
    }

    // ── 共通 UI ──────────────────────────────────────────
    enum Common {
        static var close: String          { L("閉じる",         en: "Close",                zhHans: "关闭",         zhHant: "關閉") }
        static var cancel: String         { L("キャンセル",      en: "Cancel",               zhHans: "取消",         zhHant: "取消") }
        static var save: String           { L("保存",           en: "Save",                 zhHans: "保存",         zhHant: "儲存") }
        static var next: String           { L("次へ",           en: "Next",                 zhHans: "下一步",       zhHant: "下一步") }
        static var skip: String           { L("スキップ",        en: "Skip",                 zhHans: "跳过",         zhHant: "跳過") }
        static var version: String        { L("バージョン",      en: "Version",              zhHans: "版本",         zhHant: "版本") }
        static var addSymptom: String     { L("症状を追加",      en: "Add Symptom",          zhHans: "添加症状",     zhHant: "新增症狀") }
        static var customSymptomLimitPremium: String { L("カスタム症状の追加はプレミアムで無制限に", en: "Add unlimited custom symptoms with Premium", zhHans: "升级高级版，无限添加自定义症状", zhHant: "升級進階版，無限新增自訂症狀") }
        static var pastRecord: String     { L("過去の記録",      en: "Past Records",         zhHans: "过去的记录",   zhHant: "過去的記錄") }
        static var symptomName: String    { L("症状名",          en: "Symptom Name",         zhHans: "症状名称",     zhHant: "症狀名稱") }
        static var emojiOptional: String  { L("絵文字（任意）",  en: "Emoji (optional)",     zhHans: "表情符号（可选）", zhHant: "表情符號（可選）") }
        static var customSymptomHint: String { L("一般的な症状を入力してください。\n病名の入力は推奨しません。", en: "Enter a general symptom name.\nEntering disease names is not recommended.", zhHans: "请输入一般症状名称，\n不建议输入病名。", zhHant: "請輸入一般症狀名稱，\n不建議輸入病名。") }
        static var add: String            { L("追加",           en: "Add",                  zhHans: "添加",         zhHant: "新增") }
        static var symptom: String        { L("症状",           en: "Symptom",              zhHans: "症状",         zhHant: "症狀") }
        static var severity: String       { L("強さ",           en: "Severity",             zhHans: "程度",         zhHant: "程度") }
        static var recordedAt: String     { L("記録日時",        en: "Recorded At",          zhHans: "记录时间",     zhHant: "記錄時間") }
        static var recordSource: String   { L("記録元",          en: "Source",               zhHans: "记录来源",     zhHant: "記錄來源") }
        static var medication: String     { L("薬",             en: "Medication",           zhHans: "药物",         zhHant: "藥物") }
        static var timeTaken: String      { L("かかった時間",    en: "Time taken",           zhHans: "花费时间",     zhHant: "花費時間") }
        static var medicationTime: String { L("服薬時刻",        en: "Medication Time",      zhHans: "服药时间",     zhHant: "服藥時間") }
        static var settleCause: String    { L("解消の要因",      en: "Settle Cause",         zhHans: "缓解原因",     zhHant: "緩解原因") }
        static var sourceDevice: String   { L("記録元",          en: "Source",               zhHans: "记录来源",     zhHant: "記錄來源") }
        static var sourceWatch: String    { L("Apple Watch",    en: "Apple Watch",          zhHans: "Apple Watch",  zhHant: "Apple Watch") }
        static var sourceiPhone: String   { L("iPhone",         en: "iPhone",               zhHans: "iPhone",       zhHant: "iPhone") }
        static var calendar: String       { L("カレンダー",      en: "Calendar",             zhHans: "日历",         zhHant: "日曆") }
        static var detailView: String     { L("詳しく見る",      en: "See Details",          zhHans: "查看详情",     zhHant: "查看詳情") }
        static var last14Days: String     { L("直近14日",        en: "Last 14 days",         zhHans: "近14天",       zhHant: "近14天") }
        static var trendHint: String      { L("記録が増えると傾向が見えてきます", en: "Trends appear as you log more", zhHans: "记录增加后趋势将逐渐显现", zhHant: "記錄增加後趨勢將逐漸顯現") }
        static var note: String           { L("メモ",            en: "Notes",                zhHans: "备注",         zhHant: "備註") }
        static var dateTime: String       { L("日時",            en: "Date/Time",            zhHans: "日期时间",     zhHant: "日期時間") }
        static var today: String          { L("今日",            en: "Today",                zhHans: "今天",         zhHant: "今天") }
        static var boolYes: String        { L("はい",            en: "Yes",                  zhHans: "是",           zhHant: "是") }
        static var boolNo: String         { L("いいえ",          en: "No",                   zhHans: "否",           zhHant: "否") }
        /// 曜日ラベル（日曜起点 index 0〜6 = 日〜土）calendar.component(.weekday) - 1 でインデックスを引く
        static var weekdayLabelsSundayFirst: [String] {
            switch AppLanguage.current {
            case .ja:     return ["日", "月", "火", "水", "木", "金", "土"]
            case .en:     return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            case .zhHans: return ["日", "一", "二", "三", "四", "五", "六"]
            case .zhHant: return ["日", "一", "二", "三", "四", "五", "六"]
            }
        }
    }

    // ── Widget ──────────────────────────────────────────
    enum Widget {
        static func todayCount(_ count: Int) -> String {
            switch AppLanguage.current {
            case .ja:     return "今日 \(count)件"
            case .en:     return "Today: \(count)"
            case .zhHans: return "今日 \(count)条"
            case .zhHant: return "今日 \(count)條"
            }
        }
        static var noRecords: String      { L("記録なし",           en: "No records",           zhHans: "暂无记录",     zhHant: "暫無記錄") }
        static var noRecordsToday: String { L("今日の記録はまだありません", en: "No records today", zhHans: "今日暂无记录", zhHant: "今日暫無記錄") }
        static var tapToRecord: String    { L("タップして記録",      en: "Tap to log",           zhHans: "点击记录",     zhHant: "點擊記錄") }
        static var latest: String         { L("直近",               en: "Latest",               zhHans: "最近",         zhHant: "最近") }
    }

    // ── Watch ────────────────────────────────────────────
    enum Watch {
        static var recordNow: String    { L("今すぐ記録",   en: "Log Now",       zhHans: "立即记录", zhHant: "立即記錄") }
        static var recentRecord: String { L("直近の記録",   en: "Recent Log",    zhHans: "最近记录", zhHant: "最近記錄") }
        static var tookMedicine: String { L("薬を飲んだ",   en: "Took medicine", zhHans: "已服药",   zhHant: "已服藥") }
        static var settledDown: String  { L("落ち着いた",   en: "Settled",       zhHans: "已缓解",   zhHant: "已緩解") }
        static var recorded: String     { L("記録しました", en: "Logged",        zhHans: "已记录",   zhHant: "已記錄") }
    }

    // ── 権限リクエスト（事前説明画面） ────────────────────
    enum Permission {
        // ── 位置情報 ──
        static var locationTitle: String       { L("天気・気圧を記録に連動するために", en: "To link weather & pressure to your records", zhHans: "将天气与气压关联到您的记录", zhHant: "將天氣與氣壓關聯到您的記錄") }
        static var locationAllowedTitle: String { L("許可した場合",    en: "If you allow",       zhHans: "允许后",   zhHant: "允許後") }
        static var locationAllowedItem1: String { L("記録に天気・気温を自動付与",      en: "Weather and temperature auto-attached to records",        zhHans: "自动将天气和气温附加到记录",      zhHant: "自動將天氣和氣溫附加到記錄") }
        static var locationAllowedItem2: String { L("空気質・PM2.5も記録",            en: "Air quality and PM2.5 also recorded",                     zhHans: "同时记录空气质量与PM2.5",         zhHant: "同時記錄空氣品質與PM2.5") }
        static var locationAllowedItem3: String { L("環境と不調の関係を振り返れるようになる", en: "Enables reviewing how environment relates to symptoms", zhHans: "可以回顾环境与不适之间的关系",    zhHant: "可以回顧環境與不適之間的關係") }
        static var locationDeniedTitle: String  { L("許可しない場合",  en: "If you don't allow",  zhHans: "不允许时", zhHant: "不允許時") }
        static var locationDeniedItem1: String  { L("記録はもちろんできます",          en: "You can still log normally",                             zhHans: "仍然可以正常记录",                zhHant: "仍然可以正常記錄") }
        static var locationDeniedItem2: String  { L("気圧は端末センサーから自動で取得されます", en: "Pressure is automatically obtained from the device sensor", zhHans: "气压将自动从设备传感器获取",    zhHant: "氣壓將自動從裝置感應器取得") }
        static var locationDeniedItem3: String  { L("天気・空気質は記録に含まれません", en: "Weather and air quality won't be included in records",    zhHans: "天气和空气质量不会包含在记录中", zhHant: "天氣和空氣品質不會包含在記錄中") }
        static var locationPrivacy: String      { L(
            "位置情報は市区町村レベルに丸めて保存され、外部に送信されることはありません。",
            en: "Location is rounded to city/town level and never sent externally.",
            zhHans: "位置信息经四舍五入至市区町村级别后保存，不会发送到外部。",
            zhHant: "位置資訊經四捨五入至市區町村層級後儲存，不會傳送到外部。"
        ) }
        static var locationAllowButton: String  { L("天気と連動する",   en: "Link with Weather",     zhHans: "与天气联动",   zhHant: "與天氣聯動") }
        static var locationSkipButton: String   { L("あとで設定する",   en: "Set up later",          zhHans: "稍后设置",     zhHant: "稍後設定") }

        // ── Health ──
        static var healthTitle: String         { L("Healthデータと振り返り",       en: "Health Data & Review",                 zhHans: "Health数据与回顾",             zhHant: "Health數據與回顧") }
        static var healthBody: String          { L(
            "睡眠・心拍・歩数と不調記録の関係を振り返れるようになります。データは端末内でのみ使用します。",
            en: "Review the relationship between sleep, heart rate, steps, and symptom records. Data is used on-device only.",
            zhHans: "可以回顾睡眠、心率、步数与症状记录的关系。数据仅在设备内使用。",
            zhHant: "可以回顧睡眠、心率、步數與症狀記錄的關係。數據僅在裝置內使用。"
        ) }
        static var healthAllowedTitle: String  { L("許可した場合",  en: "If you allow",      zhHans: "允许后", zhHant: "允許後") }
        static var healthAllowedItem1: String  { L("前夜の睡眠時間を記録に自動付与",   en: "Previous night's sleep duration auto-attached",         zhHans: "自动附加前一晚的睡眠时间",      zhHant: "自動附加前一晚的睡眠時間") }
        static var healthAllowedItem2: String  { L("安静時心拍・HRVを記録と並べて確認", en: "Resting HR and HRV shown alongside records",           zhHans: "可将安静时心率和HRV与记录并排查看", zhHant: "可將安靜時心率和HRV與記錄並排查看") }
        static var healthAllowedItem3: String  { L("歩数・ワークアウトの有無も振り返れる", en: "Steps and workout status also reviewable",           zhHans: "也可回顾步数和锻炼情况",         zhHant: "也可回顧步數和鍛鍊情況") }
        static var healthDeniedTitle: String   { L("許可しない場合", en: "If you don't allow", zhHans: "不允许时", zhHant: "不允許時") }
        static var healthDeniedItem1: String   { L("記録・履歴・レポートは全て使えます",   en: "Logging, history, and reports are all available",     zhHans: "记录、历史和报告均可使用",       zhHant: "記錄、歷史和報告均可使用") }
        static var healthDeniedItem2: String   { L("気圧・天気との傾向も引き続き確認できます", en: "Pressure and weather trends remain available",     zhHans: "仍可查看气压与天气的趋势",       zhHant: "仍可查看氣壓與天氣的趨勢") }
        static var healthDeniedItem3: String   { L("睡眠・心拍との比較はできません",       en: "Sleep and heart rate comparisons won't be available", zhHans: "无法与睡眠和心率进行比较",       zhHant: "無法與睡眠和心率進行比較") }
        static var healthPrivacy: String       { L(
            "HealthKitデータは端末内でのみ使用し、外部に送信されることはありません。",
            en: "HealthKit data is used on-device only and never sent externally.",
            zhHans: "HealthKit数据仅在设备内使用，不会发送到外部。",
            zhHant: "HealthKit數據僅在裝置內使用，不會傳送到外部。"
        ) }
        static var healthAllowButton: String   { L("Healthデータと連動する",  en: "Link with Health Data", zhHans: "与Health数据联动", zhHant: "與Health數據聯動") }
        static var healthSkipButton: String    { L("あとで設定する",          en: "Set up later",          zhHans: "稍后设置",         zhHant: "稍後設定") }

        // ── 通知 ──
        static var notificationTitle: String        { L("必要な時だけお知らせ",         en: "Notify only when needed",         zhHans: "仅在需要时通知",             zhHant: "僅在需要時通知") }
        static var notificationBody: String         { L(
            "天気が大きく変わる時など、記録が必要になりそうな場面でだけ通知します。",
            en: "Notifies only in situations where logging might be useful, such as significant weather changes.",
            zhHans: "仅在可能需要记录的情况下通知，例如天气大幅变化时。",
            zhHant: "僅在可能需要記錄的情況下通知，例如天氣大幅變化時。"
        ) }
        static var notificationPressureDrop: String  { L("気圧が大きく下がる見込みの時",  en: "When significant pressure drop is forecast",    zhHans: "预测气压大幅下降时",         zhHant: "預測氣壓大幅下降時") }
        static var notificationWeatherChange: String { L("天気が急変する予報の時",         en: "When sudden weather change is forecast",        zhHans: "预测天气急剧变化时",         zhHant: "預測天氣急劇變化時") }
        static var notificationNonMedical: String    { L("診断や予防を目的としない通知です",  en: "These notifications are not for diagnosis or prevention.", zhHans: "这些通知不以诊断或预防为目的。", zhHant: "這些通知不以診斷或預防為目的。") }
        static var notificationFrequencyNote: String { L(
            "週4回以内・1日1回以内に制限されます。\n通知のオン/オフは設定でいつでも変更できます。",
            en: "Limited to 4 times/week and once/day.\nYou can change notification settings anytime.",
            zhHans: "每周最多4次，每天最多1次。\n可随时在设置中更改通知开关。",
            zhHant: "每週最多4次，每天最多1次。\n可隨時在設定中更改通知開關。"
        ) }
        static var notificationAllowButton: String   { L("通知を許可する",    en: "Allow Notifications", zhHans: "允许通知", zhHant: "允許通知") }
        static var notificationSkipButton: String    { L("あとで設定する",    en: "Set up later",        zhHans: "稍后设置", zhHant: "稍後設定") }
    }
}
