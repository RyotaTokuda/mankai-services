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
                    TextField(S.Common.symptomName, text: $name)
                    TextField(S.Common.emojiOptional, text: $emoji)
                        .onChange(of: emoji) { _, newValue in
                            // 1文字だけに制限
                            if newValue.count > 1 {
                                emoji = String(newValue.prefix(1))
                            }
                        }
                }

                Section {
                    Text(S.Common.customSymptomHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(S.Common.addSymptom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(S.Common.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(S.Common.add) {
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
