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
                Text(S.App.description)
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
                Link(S.Legal.privacyPolicy, destination: URL(string: "https://mankai-software.com/privacy")!)
                Link(S.Legal.termsOfService, destination: URL(string: "https://mankai-software.com/terms")!)
            }
        }
        .navigationTitle(S.Settings.about)
        .navigationBarTitleDisplayMode(.inline)
    }
}
