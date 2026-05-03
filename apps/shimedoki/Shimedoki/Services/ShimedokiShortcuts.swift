import AppIntents

/// テンプレ名を Siri が認識できるよう AppEnum として定義
enum TemplateNameEnum: String, AppEnum {
    case oneOnOne   = "1on1"
    case sales      = "商談"
    case interview  = "面接"
    case chat       = "雑談"
    case focus      = "集中"
    case exit       = "退出準備"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "テンプレ名")

    static var caseDisplayRepresentations: [TemplateNameEnum: DisplayRepresentation] = [
        .oneOnOne:  "1on1",
        .sales:     "商談",
        .interview: "面接",
        .chat:      "雑談",
        .focus:     "集中",
        .exit:      "退出準備",
    ]
}

/// 「テンプレを開始」Siri Shortcut
struct StartTemplateIntent: AppIntent {
    static var title: LocalizedStringResource = "テンプレを開始"
    static var description = IntentDescription("しめどきのテンプレを開始します")

    @Parameter(title: "テンプレ名")
    var templateName: TemplateNameEnum

    static var parameterSummary: some ParameterSummary {
        Summary("「\(\.$templateName)」を開始")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TemplateStore()
        let searchName = templateName.rawValue
        guard let template = store.templates.first(where: {
            $0.title == searchName
        }) else {
            return .result(dialog: "「\(searchName)」が見つかりませんでした")
        }

        let sessionStore = SessionStore()
        _ = sessionStore.startSession(templateId: template.id, source: .shortcut)
        store.markUsed(template)

        AnalyticsService.log(.templateStarted, parameters: [
            "template": template.title,
            "source": "shortcut"
        ])

        return .result(dialog: "「\(template.title)」（\(template.durationMinutes)分）を開始しました")
    }
}

/// Shortcuts アプリに表示するショートカット一覧
struct ShimedokiShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTemplateIntent(),
            phrases: [
                "\(.applicationName)で\(\.$templateName)を開始",
                "\(.applicationName)の\(\.$templateName)を始めて",
            ],
            shortTitle: "テンプレを開始",
            systemImageName: "hand.raised.fill"
        )
    }
}
