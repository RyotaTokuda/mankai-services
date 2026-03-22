import SwiftUI

/// 位置情報の事前説明画面
/// iOS のシステムダイアログの前にカスタム説明を表示する
struct LocationPermissionView: View {
    @Environment(EnvironmentService.self) private var environmentService
    @Binding var isCompleted: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "location.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)

            Text(S.Permission.locationTitle)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // 許可した場合
            VStack(alignment: .leading, spacing: 6) {
                Text(S.Permission.locationAllowedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                PermissionItem(text: S.Permission.locationAllowedItem1)
                PermissionItem(text: S.Permission.locationAllowedItem2)
                PermissionItem(text: S.Permission.locationAllowedItem3)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // 許可しない場合
            VStack(alignment: .leading, spacing: 6) {
                Text(S.Permission.locationDeniedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                PermissionItem(text: S.Permission.locationDeniedItem1, icon: "checkmark.circle")
                PermissionItem(text: S.Permission.locationDeniedItem2, icon: "checkmark.circle")
                PermissionItem(text: S.Permission.locationDeniedItem3, icon: "xmark.circle")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // プライバシー説明
            Text(S.Permission.locationPrivacy)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // 許可ボタン → システムダイアログを表示
            Button {
                environmentService.locationService.requestWhenInUseAuthorization()
                isCompleted = true
            } label: {
                Text(S.Permission.locationAllowButton)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            Button {
                isCompleted = true
            } label: {
                Text(S.Permission.locationSkipButton)
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
