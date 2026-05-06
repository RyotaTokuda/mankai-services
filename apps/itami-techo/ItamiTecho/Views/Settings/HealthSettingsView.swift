import SwiftUI
import HealthKit

/// Health連携設定画面
struct HealthSettingsView: View {
    @Environment(HealthService.self) private var healthService
    @State private var isRequesting = false

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
                            Button(S.Settings.healthAllow) {
                                Task {
                                    isRequesting = true
                                    await healthService.requestAuthorization()
                                    isRequesting = false
                                }
                            }
                            .font(.subheadline)
                            .disabled(isRequesting)
                            Button(S.Settings.healthOpenSettings) {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text(S.Settings.healthDeviceNotSupported)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(S.Settings.healthConnectionStatus)
            }

            Section {
                Text(S.Settings.healthDataList)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Text(S.Settings.healthDataSection)
            } footer: {
                Text(S.Settings.healthPrivacyNote)
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
