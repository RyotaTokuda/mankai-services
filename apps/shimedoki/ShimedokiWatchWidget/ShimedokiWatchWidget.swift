import WidgetKit
import SwiftUI

// MARK: - Watch Complication Entry

struct WatchWidgetEntry: TimelineEntry {
    let date: Date
    let templateTitle: String
    let colorHex: String
    let isRunning: Bool
    let remainingSeconds: Int

    var timeString: String {
        guard isRunning else { return "--:--" }
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Provider

struct WatchWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchWidgetEntry {
        WatchWidgetEntry(date: .now, templateTitle: "MTG", colorHex: "#1A6FD4",
                         isRunning: false, remainingSeconds: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchWidgetEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchWidgetEntry>) -> Void) {
        let entry = readEntry()
        // Running: refresh every 30s. Idle: refresh every 5min.
        let nextRefresh = Calendar.current.date(byAdding: .second,
                                                 value: entry.isRunning ? 30 : 300,
                                                 to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func readEntry() -> WatchWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.mankai.shimedoki")
        let title     = defaults?.string(forKey: "widget.lastTemplateTitle") ?? "しめどき"
        let hex       = defaults?.string(forKey: "widget.lastTemplateColor") ?? "#1A6FD4"
        let running   = defaults?.bool(forKey: "widget.sessionRunning") ?? false
        let remaining = defaults?.integer(forKey: "widget.remainingSeconds") ?? 0
        return WatchWidgetEntry(date: .now, templateTitle: title, colorHex: hex,
                                isRunning: running, remainingSeconds: remaining)
    }
}

// MARK: - Views

struct WatchComplicationView: View {
    var entry: WatchWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryCorner:
            cornerView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }

    private var circularView: some View {
        ZStack {
            Circle().fill(Color(hex: entry.colorHex).opacity(0.2))
            VStack(spacing: 1) {
                Image(systemName: "timer")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: entry.colorHex))
                if entry.isRunning {
                    Text(entry.timeString)
                        .font(.system(.caption2, design: .rounded).monospacedDigit())
                }
            }
        }
    }

    private var cornerView: some View {
        Image(systemName: "timer")
            .foregroundStyle(Color(hex: entry.colorHex))
            .widgetLabel {
                Text(entry.isRunning ? entry.timeString : entry.templateTitle)
                    .foregroundStyle(Color(hex: entry.colorHex))
            }
    }

    private var rectangularView: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(Color(hex: entry.colorHex))
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.templateTitle)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
                if entry.isRunning {
                    Text(entry.timeString)
                        .font(.system(.caption, design: .rounded, weight: .thin).monospacedDigit())
                        .foregroundStyle(Color(hex: entry.colorHex))
                }
            }
        }
    }

    private var inlineView: some View {
        Label(
            entry.isRunning ? entry.timeString : entry.templateTitle,
            systemImage: "timer"
        )
    }
}

// MARK: - Widget

@main
struct ShimedokiWatchWidget: Widget {
    let kind = "ShimedokiWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchWidgetProvider()) { entry in
            WatchComplicationView(entry: entry)
        }
        .configurationDisplayName("しめどき")
        .description("残り時間を文字盤に表示")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
