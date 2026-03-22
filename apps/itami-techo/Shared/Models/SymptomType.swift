import Foundation

/// デフォルト症状（初回リリースで提供する6種）
enum SymptomType: String, Codable, CaseIterable {
    case headache    // 頭痛
    case fatigue     // だるさ
    case dizziness   // めまい
    case nausea      // 吐き気
    case stiffness   // 肩こり
    case drowsiness  // 眠気
}
