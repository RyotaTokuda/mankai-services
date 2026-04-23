import SwiftUI
import HealthKit

/// Health連携設定画面
struct HealthSettingsView: View {
    @Environment(HealthService.self) private var healthService

    var body: some View {
        List {
            Section {
                if HealthService.isAvailable {
                    if healthService.isAuthorized {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text(S.Settings.healthAuthorized)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.orange)
                                Text(S.Settings.healthNotAuthorized)
                                    .font(.subheadline)
                            }
                            Button(S.Settings.healthOpenSettings) {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                } else {
                    Text("このデバイスはHealthKitに対応していません")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("接続状態")
            }

            Section {
                Text(S.Settings.healthDataList)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Text("取得するデータ")
            } footer: {
                Text("HealthKitデータは端末内でのみ使用し、外部に送信されることはありません。")
                    .font(.caption)
            }

            Section {
                Text(S.Legal.disclaimer4)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(S.Settings.healthIntegration)
        .navigationBarTitleDisplayMode(.inline)
    }
}
