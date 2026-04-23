import Foundation

/// デフォルト症状（9種）
enum SymptomType: String, Codable, CaseIterable {
    case headache       // 頭痛
    case fatigue        // だるさ
    case dizziness      // めまい
    case nausea         // 吐き気
    case stiffness      // 肩こり
    case drowsiness     // 眠気
    case stomachache    // 腹痛
    case palpitations   // 動悸
    case heavyHead      // 頭重感
}
