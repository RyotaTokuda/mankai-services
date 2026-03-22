import SwiftUI

/// iPhone: 記録完了シート
/// 完了メッセージ + 見返り + 追加アクション
struct RecordCompleteView: View {
    let record: SymptomRecord

    @Environment(RecordStore.self) private var recordStore
    @Environment(\.dismiss) private var dismiss

    private var todayCount: Int {
        recordStore.todayRecords.count
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text(S.Record.done)
                .font(.title2)
                .fontWeight(.bold)

            // 見返りメッセージ
            Text(S.Feedback.todayCount(todayCount))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("閉じる")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .presentationDetents([.medium])
    }
}
