import SwiftUI

/// iPhone: カスタム症状追加シート
struct AddCustomSymptomView: View {
    @Environment(CustomSymptomStore.self) private var customSymptomStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("症状名", text: $name)
                    TextField("絵文字（任意）", text: $emoji)
                        .onChange(of: emoji) { _, newValue in
                            // 1文字だけに制限
                            if newValue.count > 1 {
                                emoji = String(newValue.prefix(1))
                            }
                        }
                }

                Section {
                    Text("一般的な症状を入力してください。\n病名の入力は推奨しません。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("症状を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let symptom = CustomSymptom(
                            name: name.trimmingCharacters(in: .whitespaces),
                            emoji: emoji.isEmpty ? nil : emoji
                        )
                        customSymptomStore.add(symptom)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
