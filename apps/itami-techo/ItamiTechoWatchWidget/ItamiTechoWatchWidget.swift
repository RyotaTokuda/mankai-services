import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct WatchWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchWidgetEntry {
        WatchWidgetEntry(date: Date(), todayCount: 0, latestSymptom: nil, latestSeverity: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchWidgetEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchWidgetEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> WatchWidgetEntry {
        let store = RecordStore()
        let today = store.todayRecords
        let latest = today.first
        // Smart Stack: 今日の記録があれば高スコア → 上位表示
        let score: Float = today.count > 0 ? 60 : 15
        return WatchWidgetEntry(
            date: Date(),
            todayCount: today.count,
            latestSymptom: latest?.symptomType.map { S.Symptom.name(for: $0) } ?? latest?.customSymptomName,
            latestSeverity: latest?.severity,
            relevance: TimelineEntryRelevance(score: score, duration: 1800)
        )
    }
}

// MARK: - Entry

struct WatchWidgetEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let latestSymptom: String?
    let latestSeverity: Int?
    var relevance: TimelineEntryRelevance?
}

// MARK: - Complication Views

struct WatchCircularWidget: View {
    let entry: WatchWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 13))
                if entry.todayCount > 0 {
                    Text("\(entry.todayCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "itamitecho://record"))
    }
}

struct WatchRectangularWidget: View {
    let entry: WatchWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.accentColor)
                Text(S.App.name)
                    .fontWeight(.semibold)
            }
            .font(.caption2)

            if entry.todayCount > 0 {
                Text(S.Widget.todayCount(entry.todayCount))
                    .font(.caption2)
                if let symptom = entry.latestSymptom, let severity = entry.latestSeverity {
                    Text("\(symptom) · \(S.Severity.label(for: severity))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(S.Widget.tapToRecord)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "itamitecho://record"))
    }
}

struct WatchCornerWidget: View {
    let entry: WatchWidgetEntry

    var body: some View {
        Image(systemName: "plus.circle.fill")
            .widgetLabel(
                entry.todayCount > 0
                    ? S.Widget.todayCount(entry.todayCount)
                    : S.Widget.noRecords
            )
            .containerBackground(.fill.tertiary, for: .widget)
            .widgetURL(URL(string: "itamitecho://record"))
    }
}

struct WatchWidgetEntryView: View {
    @SwiftUI.Environment(\.widgetFamily) var family
    let entry: WatchWidgetEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            WatchCircularWidget(entry: entry)
        case .accessoryRectangular:
            WatchRectangularWidget(entry: entry)
        case .accessoryCorner:
            WatchCornerWidget(entry: entry)
        default:
            WatchCircularWidget(entry: entry)
        }
    }
}

// MARK: - Widget Definition

struct ItamiTechoWatchWidget: Widget {
    let kind = "ItamiTechoWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchWidgetTimelineProvider()) { entry in
            WatchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(S.App.name)
        .description(S.App.tagline)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}

@main
struct ItamiTechoWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        ItamiTechoWatchWidget()
    }
}
