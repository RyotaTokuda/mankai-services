import SwiftUI

/// iPhone: オンボーディング画面
/// スライド4枚 → 位置情報権限 → HealthKit権限 → アプリへ
struct OnboardingView: View {
    @Binding var isCompleted: Bool

    private enum Step {
        case slides, location, health, notification
    }

    @State private var step: Step = .slides
    @State private var currentPage = 0
    @State private var locationCompleted = false
    @State private var healthCompleted = false
    @State private var notificationCompleted = false

    private let pages: [(title: String, body: String, icons: [String])] = [
        (S.Onboarding.step1Title, S.Onboarding.step1Body, ["iphone", "applewatch"]),
        (S.Onboarding.step2Title, S.Onboarding.step2Body, ["cloud.sun"]),
        (S.Onboarding.step3Title, S.Onboarding.step3Body, ["doc.text"]),
        (S.Onboarding.step4Title, S.Onboarding.step4Body, ["checkmark.shield"]),
    ]

    var body: some View {
        switch step {
        case .slides:
            slidesView
        case .location:
            LocationPermissionView(isCompleted: $locationCompleted)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .onChange(of: locationCompleted) { _, completed in
                    if completed { withAnimation(.easeInOut(duration: 0.3)) { step = .health } }
                }
                .overlay(alignment: .topLeading) { backButton(to: .slides) }
        case .health:
            HealthPermissionView(isCompleted: $healthCompleted)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .onChange(of: healthCompleted) { _, completed in
                    if completed { withAnimation(.easeInOut(duration: 0.3)) { step = .notification } }
                }
                .overlay(alignment: .topLeading) { backButton(to: .location) }
        case .notification:
            NotificationPermissionView(isCompleted: $notificationCompleted)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .onChange(of: notificationCompleted) { _, completed in
                    if completed { withAnimation(.easeInOut(duration: 0.3)) { isCompleted = true } }
                }
                .overlay(alignment: .topLeading) { backButton(to: .health) }
        }
    }

    private func backButton(to target: Step) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) { step = target }
        } label: {
            Image(systemName: "chevron.left")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .padding()
        }
        .padding(.top, 8)
    }

    private var slidesView: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Spacer()

                        HStack(spacing: 16) {
                            ForEach(pages[index].icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: 54))
                                    .foregroundStyle(Color.accentColor)
                            }
                        }

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
                    withAnimation(.easeInOut(duration: 0.3)) { step = .location }
                }
            } label: {
                Text(currentPage == pages.count - 1 ? S.Onboarding.startButton : S.Common.next)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            if currentPage < pages.count - 1 {
                Button(S.Common.skip) {
                    isCompleted = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(minWidth: 80, minHeight: 44)
                .padding(.bottom, 8)
            }
        }
    }
}
