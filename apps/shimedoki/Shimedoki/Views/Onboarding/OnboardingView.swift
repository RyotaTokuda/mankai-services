import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary)

                Text(S.Onboarding.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(S.Onboarding.body)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 20) {
                OnboardingRow(
                    icon: "applewatch",
                    title: "Apple Watch で通知",
                    description: "触覚で本人だけに伝わる"
                )
                OnboardingRow(
                    icon: "hand.tap.fill",
                    title: "1タップで開始",
                    description: "Watch で3秒以内にスタート"
                )
                OnboardingRow(
                    icon: "clock.badge.checkmark.fill",
                    title: "段階的な合図",
                    description: "残り5分・1分・終了を通知"
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                hasCompletedOnboarding = true
                AnalyticsService.log(.onboardingCompleted)
            } label: {
                Text(S.Onboarding.start)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

private struct OnboardingRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
