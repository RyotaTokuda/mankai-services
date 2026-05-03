import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Home Screen Widget

struct ShimedokiWidgetEntry: TimelineEntry {
    let date: Date
    let templateTitle: String
    let colorHex: String
}

struct ShimedokiWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShimedokiWidgetEntry {
        ShimedokiWidgetEntry(date: .now, templateTitle: "チームMTG", colorHex: "#1A6FD4")
    }

    func getSnapshot(in context: Context, completion: @escaping (ShimedokiWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShimedokiWidgetEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.mankai.shimedoki")
        let title = defaults?.string(forKey: "widget.lastTemplateTitle") ?? "しめどき"
        let hex   = defaults?.string(forKey: "widget.lastTemplateColor") ?? "#1A6FD4"
        let entry = ShimedokiWidgetEntry(date: .now, templateTitle: title, colorHex: hex)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct ShimedokiWidgetView: View {
    var entry: ShimedokiWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(hex: entry.colorHex).opacity(0.12)
            VStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.title2)
                    .foregroundStyle(Color(hex: entry.colorHex))
                Text(entry.templateTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text("タップして開始")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
        }
    }
}

@main
struct ShimedokiWidgetBundle: WidgetBundle {
    var body: some Widget {
        ShimedokiHomeWidget()
        ShimedokiLiveActivityWidget()
    }
}

struct ShimedokiHomeWidget: Widget {
    let kind = "ShimedokiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShimedokiWidgetProvider()) { entry in
            ShimedokiWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("しめどき")
        .description("タップしてすぐにシーンを開始")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Live Activity Widget

struct ShimedokiLiveActivityWidget: Widget {
    let kind = "ShimedokiLiveActivity"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShimedokiActivityAttributes.self) { context in
            // Lock Screen / Notification Banner
            ShimedokiLockScreenView(
                state: context.state,
                attributes: context.attributes
            )
            .activityBackgroundTint(Color(hex: context.attributes.colorHex).opacity(0.15))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: context.attributes.colorHex))
                            .frame(width: 8, height: 8)
                        Text(context.attributes.templateTitle)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.timeString)
                        .font(.system(.title2, design: .rounded, weight: .thin))
                        .monospacedDigit()
                        .foregroundStyle(context.state.isPaused ? .secondary : .primary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: progressValue(context))
                        .tint(Color(hex: context.attributes.colorHex))
                        .padding(.horizontal, 8)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(Color(hex: context.attributes.colorHex))
            } compactTrailing: {
                Text(context.state.timeString)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(Color(hex: context.attributes.colorHex))
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(Color(hex: context.attributes.colorHex))
            }
        }
    }

    private func progressValue(_ context: ActivityViewContext<ShimedokiActivityAttributes>) -> Double {
        let total = Double(context.attributes.totalSeconds)
        guard total > 0 else { return 0 }
        let elapsed = total - Double(context.state.remainingSeconds)
        return min(max(elapsed / total, 0), 1)
    }
}

// MARK: - Lock Screen View

struct ShimedokiLockScreenView: View {
    let state: ShimedokiActivityAttributes.ContentState
    let attributes: ShimedokiActivityAttributes

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: attributes.colorHex))
                        .frame(width: 8, height: 8)
                    Text(attributes.templateTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                Text(state.isPaused ? "一時停止中" : "セッション中")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(state.timeString)
                .font(.system(.title, design: .rounded, weight: .thin))
                .monospacedDigit()
                .foregroundStyle(state.isPaused ? .secondary : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Color Extension (duplicated for widget target)

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
