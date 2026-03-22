import SwiftUI

/// iPhone: このアプリについて
struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text(S.App.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(S.App.tagline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Section {
                Text("しんどい瞬間を、Apple Watch や iPhone からすぐ記録。あとから自分の傾向を振り返り、通院時にも使える形にまとめられるアプリです。")
                    .font(.subheadline)
            }

            Section {
                Text(S.Legal.disclaimer1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(S.Legal.disclaimer3)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Link("プライバシーポリシー", destination: URL(string: "https://mankai-software.com/privacy")!)
                Link("利用規約", destination: URL(string: "https://mankai-software.com/terms")!)
            }
        }
        .navigationTitle(S.Settings.about)
        .navigationBarTitleDisplayMode(.inline)
    }
}
