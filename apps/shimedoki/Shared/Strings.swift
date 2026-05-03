import Foundation

enum S {

    // ── アプリ全般 ────────────────────────────────────────────
    enum App {
        static var name: String    { L("しめどき", en: "Shimedoki", zhHans: "しめどき", zhHant: "しめどき") }
        static var tagline: String { L("会議の終わらせどきを\n静かに伝えます",
                                        en: "Quietly signals\nwhen to wrap up",
                                        zhHans: "静静告知您\n会议的结束时机",
                                        zhHant: "靜靜告知您\n會議的結束時機") }
    }

    // ── タブ ─────────────────────────────────────────────────
    enum Tab {
        static var scenes:   String { L("シーン",   en: "Scenes",   zhHans: "场景", zhHant: "場景") }
        static var history:  String { L("履歴",     en: "History",  zhHans: "历史", zhHant: "歷史") }
        static var settings: String { L("設定",     en: "Settings", zhHans: "设置", zhHant: "設定") }
    }

    // ── シーン（旧：テンプレ）────────────────────────────────
    enum Scene {
        static var navTitle:        String { L("シーン",           en: "Scenes",           zhHans: "场景",       zhHant: "場景") }
        static var newScene:        String { L("新しいシーン",      en: "New Scene",         zhHans: "新建场景",   zhHant: "新建場景") }
        static var editNavTitle:    String { L("編集",             en: "Edit",             zhHans: "编辑",       zhHant: "編輯") }
        static var deleteScene:     String { L("このシーンを削除",  en: "Delete Scene",     zhHans: "删除场景",   zhHant: "刪除場景") }
        static var customPlus:      String { L("カスタム設定（Plus）", en: "Custom Settings (Plus)", zhHans: "自定义设置（Plus）", zhHant: "自訂設定（Plus）") }
        static var save:            String { L("保存",             en: "Save",             zhHans: "保存",       zhHant: "儲存") }
        static var cancel:          String { L("キャンセル",        en: "Cancel",           zhHans: "取消",       zhHant: "取消") }
        static func minutes(_ n: Int) -> String { L("\(n)分", en: "\(n) min", zhHans: "\(n)分钟", zhHant: "\(n)分鐘") }
    }

    // ── シーンカテゴリ ────────────────────────────────────────
    enum SceneCategory {
        static var meeting:  String { L("会議",     en: "Meeting",      zhHans: "会议",  zhHant: "會議") }
        static var oneOnOne: String { L("1on1",     en: "1on1",         zhHans: "1对1",  zhHant: "1對1") }
        static var sales:    String { L("商談",     en: "Sales",        zhHans: "商谈",  zhHant: "商談") }
        static var chat:     String { L("雑談",     en: "Chat",         zhHans: "闲聊",  zhHant: "閒聊") }
        static var focus:    String { L("集中作業", en: "Focus",        zhHans: "专注",  zhHant: "專注") }
    }

    // ── 触覚スタイル ──────────────────────────────────────────
    enum Haptic {
        static var gentle: String { L("やさしく", en: "Gentle", zhHans: "轻柔", zhHant: "輕柔") }
        static var normal: String { L("ふつう",   en: "Normal", zhHans: "普通", zhHant: "普通") }
        static var strong: String { L("しっかり", en: "Strong", zhHans: "强烈", zhHant: "強烈") }
    }

    // ── iPhone セッション ────────────────────────────────────
    enum PhoneSession {
        static var start:        String { L("iPhone で開始",      en: "Start on iPhone",   zhHans: "在 iPhone 上开始", zhHant: "在 iPhone 上開始") }
        static var pause:        String { L("一時停止",            en: "Pause",             zhHans: "暂停",            zhHant: "暫停") }
        static var resume:       String { L("再開",               en: "Resume",            zhHans: "继续",            zhHant: "繼續") }
        static var stop:         String { L("終了",               en: "End",               zhHans: "结束",            zhHant: "結束") }
        static var extend5:      String { L("+5分",               en: "+5 min",            zhHans: "+5分钟",          zhHant: "+5分鐘") }
        static var wellDone:     String { L("おつかれさまでした",  en: "Well done!",         zhHans: "辛苦了！",        zhHant: "辛苦了！") }
        static var extend:       String { L("延長",               en: "Extend",            zhHans: "延长",            zhHant: "延長") }
        static var watchNote:    String { L("Apple Watch 未接続 — iPhone で振動します",
                                             en: "No Apple Watch — vibrating on iPhone",
                                             zhHans: "未连接 Apple Watch — 将在 iPhone 上振动",
                                             zhHant: "未連接 Apple Watch — 將在 iPhone 上振動") }
    }

    // ── 履歴 ─────────────────────────────────────────────────
    enum History {
        static var navTitle:      String { L("履歴",           en: "History",       zhHans: "历史",     zhHant: "歷史") }
        static var emptyDesc:     String { L("Apple Watch でシーンを開始すると\nここに記録されます",
                                              en: "Start a scene on Apple Watch\nto see your history here",
                                              zhHans: "在 Apple Watch 上开始场景后\n将在此处显示记录",
                                              zhHant: "在 Apple Watch 上開始場景後\n將在此處顯示記錄") }
        static var showAll:       String { L("すべての履歴を表示", en: "Show All History",   zhHans: "显示所有历史", zhHant: "顯示所有歷史") }
        static var completed:     String { L("完了",             en: "Completed",     zhHans: "已完成",   zhHant: "已完成") }
        static var interrupted:   String { L("中断",             en: "Interrupted",   zhHans: "已中断",   zhHant: "已中斷") }
        static var inProgress:    String { L("実行中",           en: "In Progress",   zhHans: "进行中",   zhHant: "進行中") }
        static var deletedScene:  String { L("削除済みシーン",   en: "Deleted Scene", zhHans: "已删除场景", zhHant: "已刪除場景") }
    }

    // ── 設定 ─────────────────────────────────────────────────
    enum Settings {
        static var navTitle:          String { L("設定",                         en: "Settings",                zhHans: "设置",         zhHant: "設定") }
        static var plusPlan:          String { L("Plus プラン",                  en: "Plus Plan",               zhHans: "Plus 计划",    zhHant: "Plus 計劃") }
        static var plusActive:        String { L("有効",                         en: "Active",                  zhHans: "已激活",       zhHant: "已啟用") }
        static var manageSubscription:String { L("サブスクリプション管理",        en: "Manage Subscription",    zhHans: "管理订阅",     zhHant: "管理訂閱") }
        static var upgradePlus:       String { L("Plus にアップグレード",         en: "Upgrade to Plus",        zhHans: "升级到 Plus",  zhHant: "升級到 Plus") }
        static var notificationNote:  String { L("通知は Apple Watch 側で動作します", en: "Notifications work on Apple Watch", zhHans: "通知在 Apple Watch 上运行", zhHant: "通知在 Apple Watch 上運作") }
        static var sectionNotif:      String { L("通知",     en: "Notifications", zhHans: "通知", zhHant: "通知") }
        static var sectionIntegration:String { L("連携",     en: "Integration",   zhHans: "集成", zhHant: "整合") }
        static var sectionInfo:       String { L("情報",     en: "Info",          zhHans: "信息", zhHant: "資訊") }
        static var calendarLink:      String { L("カレンダー連携", en: "Calendar Integration", zhHans: "日历集成", zhHant: "行事曆整合") }
        static var version:           String { L("バージョン", en: "Version",     zhHans: "版本", zhHant: "版本") }
        static var plus:              String { "Plus" }
    }

    // ── ペイウォール ──────────────────────────────────────────
    enum Paywall {
        static var headerTitle:           String { L("会議をスマートに終わらせる",
                                                      en: "End Meetings Smarter",
                                                      zhHans: "智能结束会议",
                                                      zhHant: "智能結束會議") }
        static var headerBody:            String { L("時間を気にせず集中できる。\n終わりどきは、しめどきが教えます。",
                                                      en: "Focus without watching the clock.\nShimedoki tells you when to wrap up.",
                                                      zhHans: "专注工作，无需看时间。\nShimedoki 告诉您何时结束。",
                                                      zhHant: "專注工作，無需看時間。\nShimedoki 告訴您何時結束。") }
        static var benefitUnlimitedScenes:String { L("シーンを好きなだけ作れる",
                                                      en: "Create unlimited scenes",
                                                      zhHans: "无限创建场景",
                                                      zhHant: "無限建立場景") }
        static var benefitCustomAlert:    String { L("通知タイミングを自由にカスタマイズ",
                                                      en: "Fully customize alert timing",
                                                      zhHans: "自由自定义通知时间",
                                                      zhHant: "自由自訂通知時間") }
        static var benefitHistory:        String { L("過去の履歴をすべて振り返れる",
                                                      en: "View your full session history",
                                                      zhHans: "查看所有历史记录",
                                                      zhHant: "查看所有歷史記錄") }
        static var benefitCalendar:       String { L("カレンダーと連携して自動で開始",
                                                      en: "Auto-start from Calendar",
                                                      zhHans: "与日历集成自动开始",
                                                      zhHant: "與行事曆整合自動開始") }
        static var labelYearly:           String { L("年額", en: "Yearly",  zhHans: "年付", zhHant: "年付") }
        static var labelMonthly:          String { L("月額", en: "Monthly", zhHans: "月付", zhHant: "月付") }
        static var badgeRecommended:      String { L("おトク", en: "Best Value", zhHans: "超值", zhHant: "超值") }
        static var startPlus:             String { L("Plus をはじめる", en: "Start Plus", zhHans: "开始 Plus", zhHant: "開始 Plus") }
        static var plusStarted:           String { L("Plus を開始しました", en: "Plus Started", zhHans: "Plus 已开始", zhHant: "Plus 已開始") }
        static var restorePurchase:       String { L("購入を復元",   en: "Restore Purchase", zhHans: "恢复购买", zhHant: "恢復購買") }
        static var cancelAnytime:         String { L("いつでもキャンセルできます", en: "Cancel anytime", zhHans: "随时取消", zhHant: "隨時取消") }
        static var close:                 String { L("閉じる", en: "Close", zhHans: "关闭", zhHant: "關閉") }
        static var legalText:             String { L(
            "サブスクリプションは購入の確認後に課金されます。現在の期間終了の24時間前までにキャンセルしない限り自動的に更新されます。更新料金は Apple ID アカウントに課金されます。サブスクリプションの管理・解約は「設定」→「Apple ID」→「サブスクリプション」から行えます。",
            en: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage or cancel your subscription in Settings → Apple ID → Subscriptions.",
            zhHans: "购买确认后将从您的 Apple ID 账户扣款。订阅将自动续期，除非在当前期间结束前至少24小时取消。可在「设置」→「Apple ID」→「订阅」中管理或取消订阅。",
            zhHant: "購買確認後將從您的 Apple ID 帳戶扣款。訂閱將自動續期，除非在當前期間結束前至少24小時取消。可在「設定」→「Apple ID」→「訂閱」中管理或取消訂閱。"
        ) }
        // 新ベネフィット
        static var benefitLiveActivity:   String { L("ロック画面に残り時間を常時表示",
                                                       en: "Live countdown on Lock Screen",
                                                       zhHans: "锁屏实时显示剩余时间",
                                                       zhHant: "鎖定畫面即時顯示剩餘時間") }
        static var benefitWatchFace:      String { L("Apple Watch 文字盤に残り時間を表示",
                                                       en: "Show time on Apple Watch face",
                                                       zhHans: "在 Apple Watch 表盘显示剩余时间",
                                                       zhHant: "在 Apple Watch 錶面顯示剩餘時間") }
        static var benefitWidget:         String { L("ホーム画面ウィジェットでワンタップ開始",
                                                       en: "One-tap start from home widget",
                                                       zhHans: "主屏小组件一键开始",
                                                       zhHant: "主畫面小工具一鍵開始") }
        static var benefitWeeklySummary:  String { L("週次サマリーで振り返りが習慣になる",
                                                       en: "Weekly summary to build reflection habits",
                                                       zhHans: "每周总结帮助建立回顾习惯",
                                                       zhHant: "每週總結幫助建立回顧習慣") }
        static var benefitCustomIcon:     String { L("カスタムアプリアイコンを選べる",
                                                       en: "Choose a custom app icon",
                                                       zhHans: "自定义应用图标",
                                                       zhHant: "自訂應用程式圖示") }
        static var benefitNote:           String { L("セッション後にメモを残せる",
                                                       en: "Add notes after each session",
                                                       zhHans: "会话结束后添加笔记",
                                                       zhHant: "會話結束後新增筆記") }
        // 価格訴求
        static var perDayPrice:           String { L("1日5円から",
                                                       en: "From ¥5/day",
                                                       zhHans: "每天仅需5日元起",
                                                       zhHant: "每天僅需5日圓起") }
        static var yearlyMonthlyEquiv:    String { L("年額プランは月あたり100円",
                                                       en: "Yearly plan = ¥100/month",
                                                       zhHans: "年付方案每月仅需100日元",
                                                       zhHant: "年付方案每月僅需100日圓") }
        static var notePlaceholder:       String { L("このセッションのメモ…",
                                                       en: "Notes for this session…",
                                                       zhHans: "此次会话的备注…",
                                                       zhHant: "此次會話的備註…") }
        static var noteSave:              String { L("メモを保存", en: "Save Note", zhHans: "保存备注", zhHant: "儲存備註") }
        static var plusRequired:          String { L("Plus が必要です", en: "Plus Required", zhHans: "需要 Plus", zhHant: "需要 Plus") }
    }

    // ── サブスク管理 ──────────────────────────────────────────
    enum Subscription {
        static var navTitle:         String { L("サブスクリプション",    en: "Subscription",       zhHans: "订阅",     zhHant: "訂閱") }
        static var currentPlan:      String { L("現在のプラン",          en: "Current Plan",        zhHans: "当前计划", zhHant: "目前方案") }
        static var planPlus:         String { "Plus" }
        static var planFree:         String { L("無料",                 en: "Free",                zhHans: "免费",     zhHant: "免費") }
        static var restorePurchase:  String { L("購入を復元",            en: "Restore Purchase",    zhHans: "恢复购买", zhHant: "恢復購買") }
        static var openSettings:     String { L("サブスクリプション設定を開く", en: "Open Subscription Settings", zhHans: "打开订阅设置", zhHant: "開啟訂閱設定") }
        static var note:             String { L("サブスクリプションは App Store アカウントに紐づいています。解約はいつでも可能です。",
                                                 en: "Subscriptions are tied to your App Store account. You can cancel anytime.",
                                                 zhHans: "订阅与您的 App Store 账户绑定，随时可以取消。",
                                                 zhHant: "訂閱與您的 App Store 帳戶綁定，隨時可以取消。") }
        static var close:            String { L("閉じる", en: "Close", zhHans: "关闭", zhHant: "關閉") }
    }

    // ── オンボーディング ──────────────────────────────────────
    enum Onboarding {
        static var title:  String { L("しめどき", en: "Shimedoki", zhHans: "しめどき", zhHant: "しめどき") }
        static var body:   String { L("会議の終わらせどきを\n静かに伝えます",
                                       en: "Quietly signals\nwhen to wrap up",
                                       zhHans: "静静告知您\n会议的结束时机",
                                       zhHant: "靜靜告知您\n會議的結束時機") }
        static var start:  String { L("はじめる", en: "Get Started", zhHans: "开始使用", zhHant: "開始使用") }
    }

    // ── Watch ─────────────────────────────────────────────────
    enum Watch {
        static var appTitle:  String { L("しめどき", en: "Shimedoki", zhHans: "しめどき", zhHant: "しめどき") }
        static var extend5:   String { L("+5分",    en: "+5 min",     zhHans: "+5分钟",   zhHant: "+5分鐘") }
        static var extend:    String { L("延長",    en: "Extend",     zhHans: "延长",     zhHant: "延長") }
        static var end:       String { L("終了",    en: "End",        zhHans: "结束",     zhHant: "結束") }
        static var wellDone:  String { L("おつかれさまでした", en: "Well done!", zhHans: "辛苦了！", zhHant: "辛苦了！") }
        static func extendMin(_ n: Int) -> String { L("+\(n)分", en: "+\(n) min", zhHans: "+\(n)分钟", zhHant: "+\(n)分鐘") }
    }

    // ── 設定（追加）──────────────────────────────────────────
    enum SettingsExtra {
        static var sectionAppIcon:      String { L("アプリアイコン",       en: "App Icon",           zhHans: "应用图标",     zhHant: "應用程式圖示") }
        static var sectionWeekly:       String { L("週次サマリー",         en: "Weekly Summary",     zhHans: "每周总结",     zhHant: "每週總結") }
        static var weeklySummaryToggle: String { L("日曜 20時に週の振り返りを通知", en: "Notify weekly summary on Sunday 8pm",
                                                    zhHans: "周日 20:00 发送每周总结通知", zhHant: "週日 20:00 發送每週總結通知") }
        static var iconPickerTitle:     String { L("アイコンを選択", en: "Choose Icon", zhHans: "选择图标", zhHant: "選擇圖示") }
    }

    // ── 通知 ─────────────────────────────────────────────────
    enum Notification {
        static var appName: String { L("しめどき", en: "Shimedoki", zhHans: "しめどき", zhHant: "しめどき") }
        static func minutesLeft(_ min: Int, scene: String) -> String {
            L("\(scene) — 残り\(min)分", en: "\(scene) — \(min) min left", zhHans: "\(scene) — 剩余\(min)分钟", zhHant: "\(scene) — 剩餘\(min)分鐘")
        }
        static func soonEnd(scene: String) -> String {
            L("\(scene) — まもなく終了", en: "\(scene) — ending soon", zhHans: "\(scene) — 即将结束", zhHant: "\(scene) — 即將結束")
        }
        static func timeToEnd(scene: String) -> String {
            L("\(scene) — 締めどきです", en: "\(scene) — time to wrap up", zhHans: "\(scene) — 该结束了", zhHant: "\(scene) — 該結束了")
        }
        static var weeklySummaryPlaceholder: String {
            L("今週の振り返りを確認しましょう",
              en: "Check this week's session summary",
              zhHans: "查看本周会话总结",
              zhHant: "查看本週會話總結")
        }
        static func weeklySummary(sessions: Int, minutes: Int) -> String {
            L("今週は\(sessions)回のセッションで合計\(minutes)分集中しました！",
              en: "You completed \(sessions) sessions for \(minutes) min this week!",
              zhHans: "本周完成了\(sessions)次会话，共专注\(minutes)分钟！",
              zhHant: "本週完成了\(sessions)次會話，共專注\(minutes)分鐘！")
        }
    }
}
