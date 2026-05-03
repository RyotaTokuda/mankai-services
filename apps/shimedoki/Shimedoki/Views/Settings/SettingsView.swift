import SwiftUI

struct SettingsView: View {
    @Environment(PlanService.self) private var planService
    @Environment(SessionStore.self) private var sessionStore
    @State private var showingPaywall = false
    @State private var showingSubscription = false
    @State private var calendarConnected = CalendarService.authorizationStatus == .fullAccess
    @State private var weeklySummaryEnabled = WeeklySummaryService.isEnabled
    @State private var currentIcon = AppIconService.currentIcon
    @State private var showingIconPaywall = false

    var body: some View {
        NavigationStack {
            List {
                // Plus セクション
                Section {
                    if planService.isPro {
                        HStack {
                            Label(S.Settings.plusPlan, systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Text(S.Settings.plusActive)
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                        Button(S.Settings.manageSubscription) {
                            showingSubscription = true
                        }
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Label(S.Settings.upgradePlus, systemImage: "star.fill")
                                    .foregroundStyle(.orange)
                                Spacer()
                                Text("¥150/月")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.orange)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }

                // アプリアイコン（Plus）
                Section(S.SettingsExtra.sectionAppIcon) {
                    if planService.canUseCustomIcon() {
                        iconPicker
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Label(S.SettingsExtra.iconPickerTitle, systemImage: "square.grid.2x2.fill")
                                Spacer()
                                Text("Plus")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.15))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // 週次サマリー（Plus）
                Section(S.SettingsExtra.sectionWeekly) {
                    if planService.canUseWeeklySummary() {
                        Toggle(S.SettingsExtra.weeklySummaryToggle, isOn: Binding(
                            get: { weeklySummaryEnabled },
                            set: { newValue in
                                weeklySummaryEnabled = newValue
                                WeeklySummaryService.isEnabled = newValue
                                if newValue {
                                    Task {
                                        _ = await NotificationService.requestPermission()
                                        let count   = sessionStore.sessionCount(since: weekAgo)
                                        let minutes = sessionStore.totalMinutes(since: weekAgo)
                                        WeeklySummaryService.scheduleWithStats(sessionCount: count, totalMinutes: minutes)
                                    }
                                } else {
                                    WeeklySummaryService.cancel()
                                }
                            }
                        ))
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Label(S.SettingsExtra.weeklySummaryToggle,
                                      systemImage: "chart.bar.fill")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("Plus")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.15))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // 通知
                Section(S.Settings.sectionNotif) {
                    Label(S.Settings.notificationNote, systemImage: "applewatch")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // カレンダー連携（Plus）
                Section(S.Settings.sectionIntegration) {
                    Button {
                        AnalyticsService.log(.calendarConnectTapped)
                        if planService.canConnectCalendar() {
                            Task {
                                let granted = await CalendarService.requestAccess()
                                if granted { calendarConnected = true }
                            }
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        HStack {
                            Label(S.Settings.calendarLink, systemImage: "calendar")
                            Spacer()
                            if !planService.isPro {
                                Text(S.Settings.plus)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // アプリ情報
                Section(S.Settings.sectionInfo) {
                    HStack {
                        Text(S.Settings.version)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

            }
            .navigationTitle(S.Settings.navTitle)
            .sheet(isPresented: $showingPaywall) { PaywallView() }
            .sheet(isPresented: $showingSubscription) { SubscriptionManagementView() }
        }
    }

    // MARK: - Icon Picker

    private var iconPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AppIcon.allCases) { icon in
                    iconCell(icon)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func iconCell(_ icon: AppIcon) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "app.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.accentColor.opacity(icon == .default ? 1 : 0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(currentIcon == icon ? Color.accentColor : Color(.separator),
                                lineWidth: currentIcon == icon ? 2 : 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                .onTapGesture {
                    AppIconService.setIcon(icon) { _ in
                        currentIcon = AppIconService.currentIcon
                    }
                }

            Text(icon.displayName)
                .font(.caption2)
                .foregroundStyle(currentIcon == icon ? Color.accentColor : .secondary)
        }
    }

    private var weekAgo: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
    }
}
