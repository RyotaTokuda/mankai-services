import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ItamiTechoTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ItamiTechoEntry {
        ItamiTechoEntry(date: Date(), todayCount: 0, latestSymptom: nil, latestSeverity: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ItamiTechoEntry) -> Void) {
        completion(createEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ItamiTechoEntry>) -> Void) {
        let entry = createEntry()
        // 30分ごとに更新
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func createEntry() -> ItamiTechoEntry {
        let store = RecordStore()
        let today = store.todayRecords
        let latest = today.first

        return ItamiTechoEntry(
            date: Date(),
            todayCount: today.count,
            latestSymptom: latest?.symptomType.map { S.Symptom.name(for: $0) } ?? latest?.customSymptomName,
            latestSeverity: latest?.severity
        )
    }
}

// MARK: - Entry

struct ItamiTechoEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let latestSymptom: String?
    let latestSeverity: Int?
}

// MARK: - Widget Views

struct ItamiTechoWidgetSmall: View {
    let entry: ItamiTechoEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                Text(S.App.name)
                    .font(.caption2)
                    .fontWeight(.bold)
            }

            Spacer()

            if entry.todayCount > 0 {
                Text("今日 \(entry.todayCount)件")
                    .font(.headline)
                if let symptom = entry.latestSymptom {
                    Text(symptom)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("記録なし")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("タップして記録")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ItamiTechoWidgetMedium: View {
    let entry: ItamiTechoEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                    Text(S.App.name)
                        .font(.caption)
                        .fontWeight(.bold)
                }

                if entry.todayCount > 0 {
                    Text("今日 \(entry.todayCount)件")
                        .font(.title2)
                        .fontWeight(.bold)
                } else {
                    Text("今日の記録はまだありません")
                        .font(.subheadline)
                }

                Spacer()

                Text("タップして記録")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }

            Spacer()

            if let symptom = entry.latestSymptom, let severity = entry.latestSeverity {
                VStack(spacing: 4) {
                    Text("直近")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(symptom)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(S.Severity.label(for: severity))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Size Routing

struct ItamiTechoWidgetEntryView: View {
    @SwiftUI.Environment(\.widgetFamily) var family
    let entry: ItamiTechoEntry

    var body: some View {
        switch family {
        case .systemSmall:
            ItamiTechoWidgetSmall(entry: entry)
        case .systemMedium:
            ItamiTechoWidgetMedium(entry: entry)
        case .accessoryCircular:
            ItamiTechoAccessoryCircular(entry: entry)
        case .accessoryRectangular:
            ItamiTechoAccessoryRectangular(entry: entry)
        default:
            ItamiTechoWidgetSmall(entry: entry)
        }
    }
}

// MARK: - Widget Definition

struct ItamiTechoWidget: Widget {
    let kind = "ItamiTechoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ItamiTechoTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                ItamiTechoWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName(S.App.name)
        .description(S.App.tagline)
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Lock Screen Widgets

struct ItamiTechoAccessoryCircular: View {
    let entry: ItamiTechoEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                if entry.todayCount > 0 {
                    Text("\(entry.todayCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ItamiTechoAccessoryRectangular: View {
    let entry: ItamiTechoEntry

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text(S.App.name)
                    .fontWeight(.bold)
            }
            .font(.caption)

            if entry.todayCount > 0 {
                Text("今日 \(entry.todayCount)件")
                    .font(.caption2)
            } else {
                Text("タップして記録")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Bundle

@main
struct ItamiTechoWidgetBundle: WidgetBundle {
    var body: some Widget {
        ItamiTechoWidget()
    }
}
