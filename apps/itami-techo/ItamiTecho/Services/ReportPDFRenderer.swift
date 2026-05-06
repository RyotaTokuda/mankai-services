import UIKit

/// 通院向けレポートの PDF を端末内で生成する
/// 日本頭痛学会・IHS 頭痛日誌フォーマット準拠
struct ReportPDFRenderer {
    let records: [SymptomRecord]
    let startDate: Date
    let endDate: Date

    // MARK: - Layout constants

    private let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
    private let margin: CGFloat = 40
    private var contentWidth: CGFloat { pageRect.width - margin * 2 }

    private var bodyFont: UIFont { .systemFont(ofSize: 11) }
    private var smallFont: UIFont { .systemFont(ofSize: 9) }
    private var boldFont: UIFont { .boldSystemFont(ofSize: 11) }
    private var sectionFont: UIFont { .boldSystemFont(ofSize: 13) }
    private var titleFont: UIFont { .boldSystemFont(ofSize: 20) }

    // MARK: - Statistics

    private var calendar: Calendar { .current }

    private var symptomDays: Int {
        Set(records.map { calendar.startOfDay(for: $0.createdAt) }).count
    }

    private var periodDays: Int {
        max(1, calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1)
    }

    private var monthlySymptomDays: Double {
        Double(symptomDays) / Double(periodDays) * 30.0
    }

    private var medicationCount: Int { AnalysisHelper.medicationCount(from: records) }

    private var medicationDays: Int {
        Set(records.filter(\.medicationTaken).map { calendar.startOfDay(for: $0.createdAt) }).count
    }

    private var monthlyMedicationDays: Double {
        Double(medicationDays) / Double(periodDays) * 30.0
    }

    private var avgSettleMinutes: Int? { AnalysisHelper.avgSettleMinutes(from: records) }

    private var maxDurationMinutes: Int? {
        records.compactMap { r -> Int? in
            guard let s = r.settledAt else { return nil }
            return Int(s.timeIntervalSince(r.createdAt) / 60)
        }.max()
    }

    private var envRecords: [SymptomRecord] { records.filter { $0.environment != nil } }
    private var healthRecords: [SymptomRecord] { records.filter { $0.healthSummary != nil } }

    // MARK: - Render

    func render() -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("itami-techo-report.pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                var y = renderPage(ctx: ctx)
                _ = y
            }
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Page layout

    @discardableResult
    private func renderPage(ctx: UIGraphicsPDFRendererContext) -> CGFloat {
        var y: CGFloat = margin

        // ── タイトル ──
        y = draw(S.Report.pdfTitle(S.App.name), at: .init(x: margin, y: y), font: titleFont)
        y += 2
        let period = "\(fmtDate(startDate)) 〜 \(fmtDate(endDate))　　出力: \(fmtDate(Date()))"
        y = draw(period, at: .init(x: margin, y: y), font: bodyFont, color: .gray)
        y += 4
        y = draw(S.Report.disclaimer, at: .init(x: margin, y: y), width: contentWidth, font: smallFont, color: .gray)
        y += 12

        // ── サマリー ──
        y = drawSection(S.Report.pdfSectionSummary, y: y)
        y = draw(S.Report.symptomDaysSummary(symptomDays: symptomDays, periodDays: periodDays, monthly: monthlySymptomDays),
                 at: .init(x: margin, y: y), font: bodyFont)
        y = draw(S.Report.totalRecordsSummary(records.count), at: .init(x: margin, y: y), font: bodyFont)
        y = draw(S.Report.medicationSummary(count: medicationCount, days: medicationDays),
                 at: .init(x: margin, y: y), font: bodyFont)

        if let avg = avgSettleMinutes {
            let durText = maxDurationMinutes.map {
                S.Report.avgDurationSummary(avg: avg, max: formatDuration($0))
            } ?? S.Report.avgDurationSummaryAvgOnly(avg: avg)
            y = draw(durText, at: .init(x: margin, y: y), font: bodyFont)
        }

        // MOH 警告
        if monthlyMedicationDays >= 10 {
            y += 6
            let warningH: CGFloat = 36
            let warningRect = CGRect(x: margin, y: y, width: contentWidth, height: warningH)
            UIColor.systemOrange.withAlphaComponent(0.12).setFill()
            UIRectFill(warningRect)
            let borderPath = UIBezierPath(rect: warningRect)
            UIColor.systemOrange.withAlphaComponent(0.5).setStroke()
            borderPath.lineWidth = 1
            borderPath.stroke()
            draw(S.Report.mohWarning(Int(monthlyMedicationDays.rounded())),
                 at: .init(x: margin + 6, y: y + 6), width: contentWidth - 12,
                 font: .systemFont(ofSize: 9.5), color: .systemOrange)
            y += warningH + 6
        }
        y += 8

        // ── 症状別内訳 ──
        y = checkPage(y, needed: 60, ctx: ctx)
        y = drawSection(S.Report.pdfSectionSymptom, y: y)
        let total = max(1, records.count)
        for (name, count) in AnalysisHelper.symptomCounts(from: records) {
            let pct = Int(Double(count) / Double(total) * 100)
            y = draw(S.Report.symptomDistributionRow(name: name, count: count, pct: pct),
                     at: .init(x: margin, y: y), font: bodyFont)
            let barW = CGFloat(pct) / 100.0 * (contentWidth * 0.45)
            let barRect = CGRect(x: margin + 155, y: y - 11, width: barW, height: 7)
            UIColor.systemBlue.withAlphaComponent(0.25).setFill()
            UIRectFill(barRect)
        }
        y += 8

        // ── 強さの分布 ──
        y = checkPage(y, needed: 60, ctx: ctx)
        y = drawSection(S.Report.pdfSectionSeverity, y: y)
        for (label, count) in AnalysisHelper.severityDistribution(from: records).reversed() where count > 0 {
            let pct = Int(Double(count) / Double(total) * 100)
            y = draw(S.Report.timeOfDayRow(label: label, count: count, pct: pct),
                     at: .init(x: margin, y: y), font: bodyFont)
        }
        y += 8

        // ── 時間帯別分布 ──
        y = checkPage(y, needed: 60, ctx: ctx)
        y = drawSection(S.Report.pdfSectionTimeOfDay, y: y)
        for (label, count) in AnalysisHelper.timeOfDayCounts(from: records) where count > 0 {
            let pct = Int(Double(count) / Double(total) * 100)
            y = draw(S.Report.timeOfDayRow(label: label, count: count, pct: pct),
                     at: .init(x: margin, y: y), font: bodyFont)
        }
        y += 8

        // ── 曜日別分布 ──
        y = checkPage(y, needed: 30, ctx: ctx)
        y = drawSection(S.Report.pdfSectionDayOfWeek, y: y)
        let dow = AnalysisHelper.dayOfWeekCounts(from: records)
        let dowText = dow.map { "\($0.0): \($0.1)\(S.Trends.countSuffix)" }.joined(separator: "　")
        y = draw(dowText, at: .init(x: margin, y: y), width: contentWidth, font: bodyFont)
        y += 8

        // ── 環境データ ──
        if !envRecords.isEmpty {
            y = checkPage(y, needed: 80, ctx: ctx)
            y = drawSection(S.Report.pdfSectionWithCount(S.Report.pdfSectionEnvironment, count: envRecords.count), y: y)
            let dropCount = AnalysisHelper.pressureDropCount(from: records)
            if dropCount > 0 {
                let dropPct = Int(Double(dropCount) / Double(envRecords.count) * 100)
                y = draw(S.Report.pressureDropStat(count: dropCount, pct: dropPct),
                         at: .init(x: margin, y: y), font: bodyFont)
            }
            let weatherList = AnalysisHelper.weatherCounts(from: records)
            if !weatherList.isEmpty {
                let wText = weatherList.map { "「\($0.0)」\($0.1)\(S.Trends.countSuffix)" }.joined(separator: "　")
                y = draw(S.Report.weatherStat(wText), at: .init(x: margin, y: y), width: contentWidth, font: bodyFont)
            }
            let temps = envRecords.compactMap { $0.environment?.temperature }
            if !temps.isEmpty {
                y = draw(S.Report.avgTemperatureStat(temps.reduce(0, +) / Double(temps.count)),
                         at: .init(x: margin, y: y), font: bodyFont)
            }
            let humids = envRecords.compactMap { $0.environment?.humidity }
            if !humids.isEmpty {
                y = draw(S.Report.avgHumidityStat(humids.reduce(0, +) / Double(humids.count)),
                         at: .init(x: margin, y: y), font: bodyFont)
            }
            y += 8
        }

        // ── Health データ ──
        if !healthRecords.isEmpty {
            y = checkPage(y, needed: 60, ctx: ctx)
            y = drawSection(S.Report.pdfSectionWithCount(S.Report.pdfSectionHealth, count: healthRecords.count), y: y)
            if let sleep = AnalysisHelper.sleepAnalysis(from: records) {
                y = draw(S.Report.shortSleepStat(short: sleep.shortSleepCount, total: sleep.shortSleepCount + sleep.normalSleepCount),
                         at: .init(x: margin, y: y), font: bodyFont)
            }
            let rhrs = healthRecords.compactMap { $0.healthSummary?.restingHeartRate }
            if !rhrs.isEmpty {
                y = draw(S.Report.avgRestingHRStat(rhrs.reduce(0, +) / Double(rhrs.count)),
                         at: .init(x: margin, y: y), font: bodyFont)
            }
            let hrvs = healthRecords.compactMap { $0.healthSummary?.heartRateVariability }
            if !hrvs.isEmpty {
                y = draw(S.Report.avgHRVStat(hrvs.reduce(0, +) / Double(hrvs.count)),
                         at: .init(x: margin, y: y), font: bodyFont)
            }
            y += 8
        }

        // ── 記録一覧 ──
        y = checkPage(y, needed: 60, ctx: ctx)
        y = drawSection(S.Report.pdfRecordListTitle(records.count), y: y)

        // Table header
        y = drawRecordTableHeader(y: y)

        let sorted = records.sorted { $0.createdAt > $1.createdAt }
        for (i, record) in sorted.enumerated() {
            y = checkPage(y, needed: 16, ctx: ctx)
            // Alternating row background
            if i % 2 == 1 {
                UIColor.systemGray6.setFill()
                UIRectFill(CGRect(x: margin - 2, y: y - 1, width: contentWidth + 4, height: 14))
            }
            y = drawRecordRow(record, y: y)
        }
        y += 16

        // ── 注意書き ──
        y = checkPage(y, needed: 30, ctx: ctx)
        UIColor.systemGray5.setFill()
        UIRectFill(CGRect(x: margin - 4, y: y, width: contentWidth + 8, height: 1))
        y += 6
        y = draw(S.Report.disclaimer, at: .init(x: margin, y: y), width: contentWidth, font: smallFont, color: .gray)

        return y
    }

    // MARK: - Record table

    // Column X offsets (from margin)
    private var colDate: CGFloat { 0 }
    private var colSymptom: CGFloat { 82 }
    private var colSeverity: CGFloat { 152 }
    private var colDuration: CGFloat { 168 }
    private var colMed: CGFloat { 218 }
    private var colEnv: CGFloat { 234 }
    private var colMemo: CGFloat { 340 }

    private func drawRecordTableHeader(y: CGFloat) -> CGFloat {
        let headers: [(String, CGFloat)] = [
            (S.Report.tableColDate, colDate), (S.Report.tableColSymptom, colSymptom),
            (S.Report.tableColSeverity, colSeverity), (S.Report.tableColDuration, colDuration),
            (S.Report.tableColMed, colMed), (S.Report.tableColEnvWeather, colEnv),
            (S.Report.tableColMemo, colMemo),
        ]
        UIColor.systemGray4.setFill()
        UIRectFill(CGRect(x: margin - 2, y: y - 1, width: contentWidth + 4, height: 14))
        for (title, x) in headers {
            draw(title, at: .init(x: margin + x, y: y), width: 80, font: .boldSystemFont(ofSize: 9), color: .darkGray)
        }
        return y + 14 + 2
    }

    private func drawRecordRow(_ record: SymptomRecord, y: CGFloat) -> CGFloat {
        let rowFont = UIFont.systemFont(ofSize: 9)
        let dateStr = record.createdAt.formatted(.dateTime.month(.twoDigits).day(.twoDigits).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
        let symptom = record.symptomType.map { S.Symptom.name(for: $0) } ?? record.customSymptomName ?? S.Symptom.custom
        let severity = "\(record.severity)"
        let duration: String = {
            guard let s = record.settledAt else { return S.Record.unsettled }
            return formatDuration(Int(s.timeIntervalSince(record.createdAt) / 60))
        }()
        let med = record.medicationTaken ? "○" : "-"
        let env: String = {
            guard let e = record.environment else { return "" }
            var parts: [String] = []
            if let w = e.weatherCondition { parts.append(w) }
            if let p = e.pressure { parts.append(String(format: "%.0f", p)) }
            return parts.joined(separator: " ")
        }()
        let memo = record.note ?? ""

        let cols: [(String, CGFloat, CGFloat)] = [
            (dateStr, colDate, 80),
            (symptom, colSymptom, 68),
            (severity, colSeverity, 14),
            (duration, colDuration, 48),
            (med, colMed, 14),
            (env, colEnv, 104),
            (memo, colMemo, contentWidth - colMemo - 4),
        ]
        for (text, x, width) in cols {
            draw(text, at: .init(x: margin + x, y: y), width: width, font: rowFont)
        }
        return y + 13
    }

    // MARK: - Helpers

    @discardableResult
    private func draw(_ text: String, at point: CGPoint, width: CGFloat? = nil, font: UIFont, color: UIColor = .black) -> CGFloat {
        let w = width ?? contentWidth
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let boundingSize = CGSize(width: w, height: .greatestFiniteMagnitude)
        let bounds = (text as NSString).boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        let drawRect = CGRect(x: point.x, y: point.y, width: w, height: bounds.height)
        (text as NSString).draw(in: drawRect, withAttributes: attrs)
        return point.y + bounds.height + 2
    }

    private func drawSection(_ title: String, y: CGFloat) -> CGFloat {
        let rect = CGRect(x: margin - 4, y: y, width: contentWidth + 8, height: 22)
        UIColor.systemGray5.setFill()
        UIRectFill(rect)
        let nextY = draw(title, at: .init(x: margin, y: y + 4), font: sectionFont)
        return nextY + 4
    }

    private func checkPage(_ y: CGFloat, needed: CGFloat, ctx: UIGraphicsPDFRendererContext) -> CGFloat {
        if y + needed > pageRect.height - margin {
            ctx.beginPage()
            return margin
        }
        return y
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h\(m)m" : "\(h)h"
        }
        return "\(minutes)分"
    }

    private func fmtDate(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day())
    }
}
