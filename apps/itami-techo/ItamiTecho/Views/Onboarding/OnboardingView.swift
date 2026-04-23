import SwiftUI

/// iPhone: オンボーディング画面
/// スライド4枚 → 位置情報権限 → HealthKit権限 → アプリへ
struct OnboardingView: View {
    @Binding var isCompleted: Bool

    private enum Step {
        case slides, location, health
    }

    @State private var step: Step = .slides
    @State private var currentPage = 0
    @State private var locationCompleted = false
    @State private var healthCompleted = false

    private let pages: [(title: String, body: String, icon: String)] = [
        (S.Onboarding.step1Title, S.Onboarding.step1Body, "applewatch"),
        (S.Onboarding.step2Title, S.Onboarding.step2Body, "cloud.sun"),
        (S.Onboarding.step3Title, S.Onboarding.step3Body, "doc.text"),
        (S.Onboarding.step4Title, S.Onboarding.step4Body, "checkmark.shield"),
    ]

    var body: some View {
        switch step {
        case .slides:
            slidesView
        case .location:
            LocationPermissionView(isCompleted: $locationCompleted)
                .onChange(of: locationCompleted) { _, completed in
                    if completed { step = .health }
                }
        case .health:
            HealthPermissionView(isCompleted: $healthCompleted)
                .onChange(of: healthCompleted) { _, completed in
                    if completed { isCompleted = true }
                }
        }
    }

    private var slidesView: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: pages[index].icon)
                            .font(.system(size: 60))
                            .foregroundStyle(Color.accentColor)

                        Text(pages[index].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(pages[index].body)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    step = .location
                }
            } label: {
                Text(currentPage == pages.count - 1 ? S.Onboarding.startButton : "次へ")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            if currentPage < pages.count - 1 {
                Button("スキップ") {
                    isCompleted = true
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            }
        }
    }
}
