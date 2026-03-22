import UIKit

/// 通院向けレポートの PDF を端末内で生成する
struct ReportPDFRenderer {
    let records: [SymptomRecord]
    let startDate: Date
    let endDate: Date
    let symptomCounts: [(String, Int)]
    let severityDistribution: [(String, Int)]
    let medicationCount: Int
    let avgSettleMinutes: Int?

    /// PDF を生成してファイル URL を返す
    func render() -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let margin: CGFloat = 40
        let contentWidth = pageRect.width - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("itami-techo-report.pdf")

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                var y: CGFloat = margin

                // タイトル
                y = drawText(S.App.name + " " + S.Report.title, at: CGPoint(x: margin, y: y), width: contentWidth, font: .boldSystemFont(ofSize: 20))
                y += 4

                // 期間
                let periodText = "\(formatDate(startDate)) 〜 \(formatDate(endDate))"
                y = drawText(periodText, at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 12), color: .gray)
                y += 16

                // 概要
                y = drawText("概要", at: CGPoint(x: margin, y: y), width: contentWidth, font: .boldSystemFont(ofSize: 14))
                y += 4
                y = drawText("記録件数: \(records.count)件", at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 12))
                y = drawText("服薬回数: \(medicationCount)回", at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 12))
                if let avg = avgSettleMinutes {
                    y = drawText("落ち着くまでの平均: \(avg)分", at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 12))
                }
                y += 12

                // 症状別
                y = drawText("症状別件数", at: CGPoint(x: margin, y: y), width: contentWidth, font: .boldSystemFont(ofSize: 14))
                y += 4
                for (name, count) in symptomCounts {
                    y = drawText("  \(name): \(count)件", at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 12))
                }
                y += 12

                // 強さ分布
                y = drawText("強さの分布", at: CGPoint(x: margin, y: y), width: contentWidth, font: .boldSystemFont(ofSize: 14))
                y += 4
                for (label, count) in severityDistribution where count > 0 {
                    y = drawText("  \(label): \(count)件", at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 12))
                }
                y += 12

                // 記録一覧（直近20件）
                y = drawText("記録一覧（直近20件）", at: CGPoint(x: margin, y: y), width: contentWidth, font: .boldSystemFont(ofSize: 14))
                y += 4
                for record in records.prefix(20) {
                    let symptom = record.symptomType.map { S.Symptom.name(for: $0) } ?? record.customSymptomName ?? "カスタム"
                    let severity = S.Severity.label(for: record.severity)
                    let date = record.createdAt.formatted(.dateTime.month().day().hour().minute())
                    let med = record.medicationTaken ? " [服薬]" : ""
                    y = drawText("  \(date)  \(symptom) (\(severity))\(med)", at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 10))

                    // ページ超過チェック
                    if y > pageRect.height - margin * 2 {
                        context.beginPage()
                        y = margin
                    }
                }
                y += 16

                // 注意書き
                y = drawText(S.Report.disclaimer, at: CGPoint(x: margin, y: y), width: contentWidth, font: .systemFont(ofSize: 9), color: .gray)
            }
            return url
        } catch {
            print("[ReportPDF] render error: \(error)")
            return nil
        }
    }

    @discardableResult
    private func drawText(_ text: String, at point: CGPoint, width: CGFloat, font: UIFont, color: UIColor = .black) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
        ]
        let rect = CGRect(x: point.x, y: point.y, width: width, height: .greatestFiniteMagnitude)
        let boundingRect = (text as NSString).boundingRect(with: rect.size, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        (text as NSString).draw(in: CGRect(x: point.x, y: point.y, width: width, height: boundingRect.height), withAttributes: attrs)
        return point.y + boundingRect.height + 2
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day())
    }
}
