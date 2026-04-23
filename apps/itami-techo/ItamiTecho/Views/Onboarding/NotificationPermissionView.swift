import SwiftUI

/// 通知の事前説明画面
/// iOS のシステムダイアログの前にカスタム説明を表示する
struct NotificationPermissionView: View {
    @Environment(NotificationService.self) private var notificationService
    @Binding var isCompleted: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)

            Text(S.Permission.notificationTitle)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(S.Permission.notificationBody)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 6) {
                NotifPermItem(text: "気圧が大きく下がる見込みの時")
                NotifPermItem(text: "天気が急変する予報の時")
                NotifPermItem(text: "診断や予防を目的としない通知です")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            Text("週4回以内・1日1回以内に制限されます。\n通知のオン/オフは設定でいつでも変更できます。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                isCompleted = true
                Task { _ = await notificationService.requestAuthorization() }
            } label: {
                Text("通知を許可する")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            Button {
                isCompleted = true
            } label: {
                Text("あとで設定する")
                    .font(.subheadline)
            }
            .padding(.bottom, 16)
        }
    }
}

private struct NotifPermItem: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "bell.circle")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 14)
            Text(text)
                .font(.caption)
        }
    }
}
