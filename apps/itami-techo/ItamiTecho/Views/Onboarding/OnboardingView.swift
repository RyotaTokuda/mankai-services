import SwiftUI

/// iPhone: オンボーディング画面
/// 4ステップ → 初回記録へ直行
struct OnboardingView: View {
    @Binding var isCompleted: Bool
    @State private var currentPage = 0

    private let pages: [(title: String, body: String, icon: String)] = [
        (S.Onboarding.step1Title, S.Onboarding.step1Body, "applewatch"),
        (S.Onboarding.step2Title, S.Onboarding.step2Body, "cloud.sun"),
        (S.Onboarding.step3Title, S.Onboarding.step3Body, "doc.text"),
        (S.Onboarding.step4Title, S.Onboarding.step4Body, "checkmark.shield"),
    ]

    var body: some View {
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

            // ── ボタン ──
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    isCompleted = true
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
