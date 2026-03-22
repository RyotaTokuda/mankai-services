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

    private var symptomCounts: [(String, Int)] {
        AnalysisHelper.symptomCounts(from: periodRecords)
    }

    private var severityDistribution: [(String, Int)] {
        AnalysisHelper.severityDistribution(from: periodRecords)
    }

    private var medicationCount: Int {
        AnalysisHelper.medicationCount(from: periodRecords)
    }

    private var avgSettleMinutes: Int? {
        AnalysisHelper.avgSettleMinutes(from: periodRecords)
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
