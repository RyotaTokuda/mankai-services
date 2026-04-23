import SwiftUI

/// iPhone: 通院向けレポート画面
/// NavigationStack は呼び出し元（HistoryView sheet / TrendsView NavigationLink）が持つため、ここでは持たない
struct ReportView: View {
    @Environment(RecordStore.self) private var recordStore
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss

    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingShareSheet = false
    @State private var sharedURL: URL?
    @State private var showingPaywall = false

    private var periodRecords: [SymptomRecord] {
        recordStore.records(from: startDate, to: endDate)
    }

    private var symptomCounts: [(String, Int)] { AnalysisHelper.symptomCounts(from: periodRecords) }
    private var severityDistribution: [(String, Int)] { AnalysisHelper.severityDistribution(from: periodRecords) }
    private var medicationCount: Int { AnalysisHelper.medicationCount(from: periodRecords) }
    private var avgSettleMinutes: Int? { AnalysisHelper.avgSettleMinutes(from: periodRecords) }

    var body: some View {
        List {
            // ── 期間選択 ──
            Section(S.Report.periodSelect) {
                DatePicker(S.Report.startDate, selection: $startDate, displayedComponents: .date)
                DatePicker(S.Report.endDate, selection: $endDate, displayedComponents: .date)
            }

            // ── 概要 ──
            Section(S.Report.summary) {
                LabeledContent(S.Report.recordCount, value: "\(periodRecords.count)件")
                LabeledContent(S.Report.medicationCount, value: "\(medicationCount)回")
                if let avg = avgSettleMinutes {
                    LabeledContent(S.Report.avgSettleTime, value: "\(avg)分")
                }
            }

            // ── 症状別 ──
            if !symptomCounts.isEmpty {
                Section(S.Trends.bySymptom) {
                    ForEach(symptomCounts, id: \.0) { name, count in
                        LabeledContent(name, value: "\(count)件")
                    }
                }
            }

            // ── 強さ分布 ──
            Section(S.Trends.severityDistribution) {
                ForEach(severityDistribution.filter { $0.1 > 0 }, id: \.0) { label, count in
                    LabeledContent(label, value: "\(count)件")
                }
            }

            // ── 出力 ──
            Section {
                if planService.isPremium {
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
                } else {
                    Button { showingPaywall = true } label: {
                        HStack {
                            Image(systemName: "lock.fill").foregroundStyle(.secondary)
                            Text(S.Report.exportPDF).foregroundStyle(.secondary)
                            Spacer()
                            premiumBadge
                        }
                    }
                    .buttonStyle(.plain)

                    Button { showingPaywall = true } label: {
                        HStack {
                            Image(systemName: "lock.fill").foregroundStyle(.secondary)
                            Text(S.Report.exportCSV).foregroundStyle(.secondary)
                            Spacer()
                            premiumBadge
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text(S.Report.exportSection)
            } footer: {
                if !planService.isPremium {
                    Button(S.Report.upgradeToExport) { showingPaywall = true }
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }

            // ── 注意書き ──
            Section {
                Text(S.Report.disclaimer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(S.Report.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(S.Common.close) { dismiss() }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = sharedURL { ShareSheet(items: [url]) }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    private var premiumBadge: some View {
        Text(S.Settings.planBadge)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.accentColor)
            .cornerRadius(6)
    }

    // MARK: - PDF 生成

    private func generateAndSharePDF() {
        let renderer = ReportPDFRenderer(records: periodRecords, startDate: startDate, endDate: endDate)
        if let url = renderer.render() {
            sharedURL = url
            showingShareSheet = true
        }
    }

    // MARK: - CSV 生成

    private func shareCSV() {
        let csv = ReportCSVGenerator.generate(records: periodRecords)
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("itami-techo-report.csv")
        try? csv.write(to: tmpURL, atomically: true, encoding: .utf8)
        sharedURL = tmpURL
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
