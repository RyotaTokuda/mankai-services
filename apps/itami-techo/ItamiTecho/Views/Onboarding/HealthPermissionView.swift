import SwiftUI

/// HealthKit の事前説明画面
/// iOS のシステムダイアログの前にカスタム説明を表示する
struct HealthPermissionView: View {
    @Environment(HealthService.self) private var healthService
    @Binding var isCompleted: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)

            Text(S.Permission.healthTitle)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // 許可した場合
            VStack(alignment: .leading, spacing: 6) {
                Text(S.Permission.healthAllowedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                PermissionItem(text: S.Permission.healthAllowedItem1)
                PermissionItem(text: S.Permission.healthAllowedItem2)
                PermissionItem(text: S.Permission.healthAllowedItem3)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // 許可しない場合
            VStack(alignment: .leading, spacing: 6) {
                Text(S.Permission.healthDeniedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                PermissionItem(text: S.Permission.healthDeniedItem1, icon: "checkmark.circle")
                PermissionItem(text: S.Permission.healthDeniedItem2, icon: "checkmark.circle")
                PermissionItem(text: S.Permission.healthDeniedItem3, icon: "xmark.circle")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // プライバシー説明
            Text(S.Permission.healthPrivacy)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // 許可ボタン → システムダイアログを表示
            Button {
                Task {
                    await healthService.requestAuthorization()
                    isCompleted = true
                }
            } label: {
                Text(S.Permission.healthAllowButton)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            Button {
                isCompleted = true
            } label: {
                Text(S.Permission.healthSkipButton)
                    .font(.subheadline)
            }
            .padding(.bottom, 16)
        }
    }
}

private struct PermissionItem: View {
    let text: String
    var icon: String = "circle.fill"

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 14)
            Text(text)
                .font(.caption)
        }
    }
}
