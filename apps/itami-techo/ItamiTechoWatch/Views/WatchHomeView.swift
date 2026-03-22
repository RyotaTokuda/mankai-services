import SwiftUI

/// Watch: ホーム画面
/// 「今すぐ記録」を最上位に強く配置 + 直近記録の再記録ショートカット + 履歴
struct WatchHomeView: View {
    @Environment(RecordStore.self) private var recordStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // ── 今すぐ記録ボタン（最も目立つ位置） ──
                    NavigationLink {
                        WatchSymptomSelectView()
                    } label: {
                        Label(S.Watch.recordNow, systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    // ── 直近記録の再記録ショートカット ──
                    if let latest = recordStore.latestRecord {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(S.Watch.recentRecord)
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            NavigationLink {
                                WatchSeveritySelectView(
                                    symptomType: latest.symptomType,
                                    customSymptomId: latest.customSymptomId,
                                    customSymptomName: latest.customSymptomName
                                )
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(latest.displayName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        HStack(spacing: 4) {
                                            Text(S.Severity.label(for: latest.severity))
                                            Text("・")
                                            Text(latest.createdAt.formatted(.dateTime.hour().minute()))
                                        }
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.bordered)

                            // 直近記録への追加アクション
                            if !latest.medicationTaken {
                                WatchQuickActionButton(
                                    recordId: latest.id,
                                    action: .medication
                                )
                            }
                            if latest.settledAt == nil {
                                WatchQuickActionButton(
                                    recordId: latest.id,
                                    action: .settled
                                )
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    // ── 履歴リンク ──
                    NavigationLink {
                        WatchHistoryView()
                    } label: {
                        Label(S.History.title, systemImage: "list.bullet")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle(S.App.name)
        }
    }

}
