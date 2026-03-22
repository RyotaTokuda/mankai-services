import SwiftUI

extension SymptomRecord {
    /// 症状の表示名
    var displayName: String {
        symptomType.map { S.Symptom.name(for: $0) }
            ?? customSymptomName
            ?? S.Symptom.custom
    }

    /// 強さに対応する色
    var severityColor: Color {
        Self.color(for: severity)
    }

    /// 強さレベルから色を取得
    static func color(for severity: Int) -> Color {
        switch severity {
        case 1: .green
        case 2: .yellow
        case 3: .orange
        case 4: .red
        case 5: .purple
        default: .orange
        }
    }
}
