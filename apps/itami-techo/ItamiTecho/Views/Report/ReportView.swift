import SwiftUI

/// iPhone: 通院向けレポート画面
struct ReportView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService

    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?

    private var periodRecords: [SymptomRecord] {
        recordStore.records(from: startDate, to: endDate)
    }

    /// 症状別件数
    private var symptomCounts: [(String, Int)] {
        var counts: [String: Int] = [:]
        for r in periodRecords {
            let name = r.symptomType.map { S.Symptom.name(for: $0) } ?? r.customSymptomName ?? S.Symptom.custom
            counts[name, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }

    /// 強さ分布
    private var severityDistribution: [(String, Int)] {
        var dist = [Int: Int]()
        for r in periodRecords { dist[r.severity, default: 0] += 1 }
        return (1...5).map { (S.Severity.label(for: $0), dist[$0] ?? 0) }
    }

    /// 服薬回数
    private var medicationCount: Int {
        periodRecords.filter(\.medicationTaken).count
    }

    /// 落ち着くまでの平均時間
    private var avgSettleMinutes: Int? {
        let durations = periodRecords.compactMap { r -> TimeInterval? in
            guard let settled = r.settledAt else { return nil }
            return settled.timeIntervalSince(r.createdAt)
        }
        guard !durations.isEmpty else { return nil }
        return Int(durations.reduce(0, +) / Double(durations.count) / 60)
    }

    var body: some View {
        NavigationStack {
            List {
                // 期間選択
                Section(S.Report.periodSelect) {
                    DatePicker("開始", selection: $startDate, displayedComponents: .date)
                    DatePicker("終了", selection: $endDate, displayedComponents: .date)
                }

                // 概要
                Section(S.Report.summary) {
                    LabeledContent("記録件数", value: "\(periodRecords.count)件")
                    LabeledContent("服薬回数", value: "\(medicationCount)回")
                    if let avg = avgSettleMinutes {
                        LabeledContent("落ち着くまでの平均", value: "\(avg)分")
                    }
                }

                // 症状別
                Section(S.Trends.bySymptom) {
                    ForEach(symptomCounts, id: \.0) { name, count in
                        LabeledContent(name, value: "\(count)件")
                    }
                }

                // 強さ分布
                Section(S.Trends.severityDistribution) {
                    ForEach(severityDistribution, id: \.0) { label, count in
                        LabeledContent(label, value: "\(count)件")
                    }
                }

                // 出力
                Section {
                    Button {
                        generateAndSharePDF()
                    } label: {
                        Label(S.Report.exportPDF, systemImage: "doc.fill")
                    }

                    Button {
                        shareCSV()
                    } label: {
                        Label(S.Report.exportCSV, systemImage: "tablecells")
                    }
                }

                // 注意書き
                Section {
                    Text(S.Report.disclaimer)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(S.Report.title)
            .sheet(isPresented: $showingShareSheet) {
                if let url = pdfURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // MARK: - PDF 生成

    private func generateAndSharePDF() {
        let renderer = ReportPDFRenderer(
            records: periodRecords,
            startDate: startDate,
            endDate: endDate,
            symptomCounts: symptomCounts,
            severityDistribution: severityDistribution,
            medicationCount: medicationCount,
            avgSettleMinutes: avgSettleMinutes
        )
        if let url = renderer.render() {
            pdfURL = url
            showingShareSheet = true
        }
    }

    // MARK: - CSV 生成

    private func shareCSV() {
        let csv = ReportCSVGenerator.generate(records: periodRecords)
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("itami-techo-report.csv")
        try? csv.write(to: tmpURL, atomically: true, encoding: .utf8)
        pdfURL = tmpURL
        showingShareSheet = true
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
