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
                NotifPermItem(text: S.Permission.notificationPressureDrop)
                NotifPermItem(text: S.Permission.notificationWeatherChange)
                NotifPermItem(text: S.Permission.notificationNonMedical)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            Text(S.Permission.notificationFrequencyNote)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                isCompleted = true
                Task { _ = await notificationService.requestAuthorization() }
            } label: {
                Text(S.Permission.notificationAllowButton)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            Button {
                isCompleted = true
            } label: {
                Text(S.Permission.notificationSkipButton)
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
