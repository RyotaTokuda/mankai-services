import SwiftUI

/// iPhone: ペイウォール画面
/// 価値訴求 → 年額メイン → 月額サブ → トライアル → 復元
struct PaywallView: View {
    @Environment(PlanService.self) private var planService
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ── ヘッダー ──
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.accentColor)

                        Text(S.Paywall.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(S.Paywall.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // ── 機能一覧 ──
                    VStack(alignment: .leading, spacing: 10) {
                        FeatureRow(icon: "calendar", text: "無制限の履歴保存")
                        FeatureRow(icon: "doc.text", text: "通院向けPDF / CSVレポート")
                        FeatureRow(icon: "cloud.sun", text: "天気・気圧・空気質の高度分析")
                        FeatureRow(icon: "heart.text.square", text: "Health連携の高度分析")
                        FeatureRow(icon: "chart.bar", text: "曜日別・時間帯別・強さ分布")
                        FeatureRow(icon: "bell", text: "予兆通知の個別最適化")
                        FeatureRow(icon: "tag", text: "カスタム症状・薬タグ無制限")
                    }
                    .padding(.horizontal, 24)

                    // ── 価格 ──
                    VStack(spacing: 12) {
                        // 年額（メイン）
                        if let yearly = planService.yearlyProduct {
                            Button {
                                purchase(yearly)
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(S.Paywall.yearlyLabel) \(yearly.displayPrice)")
                                        .font(.headline)
                                    Text(S.Paywall.yearlySaving)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 56)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isPurchasing)
                        }

                        // 月額
                        if let monthly = planService.monthlyProduct {
                            Button {
                                purchase(monthly)
                            } label: {
                                Text("\(S.Paywall.monthlyLabel) \(monthly.displayPrice)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.bordered)
                            .disabled(isPurchasing)
                        }

                        // トライアル
                        Text(S.Paywall.trialLabel)
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.horizontal, 24)

                    // ── 無料でもOKメッセージ ──
                    Text(S.Paywall.freeNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // ── 復元 ──
                    Button {
                        Task {
                            isPurchasing = true
                            await planService.restore()
                            isPurchasing = false
                            if planService.isPremium { dismiss() }
                        }
                    } label: {
                        Text(S.Paywall.restoreLabel)
                            .font(.caption)
                    }
                    .disabled(isPurchasing)

                    // ── エラー表示 ──
                    if let error = planService.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    // ── 利用規約・プライバシー ──
                    HStack(spacing: 16) {
                        Link("利用規約", destination: URL(string: "https://mankai-software.com/terms")!)
                        Link("プライバシーポリシー", destination: URL(string: "https://mankai-software.com/privacy")!)
                    }
                    .font(.caption2)
                    .padding(.bottom, 16)

                    // Apple 要求の定型文
                    Text("サブスクリプションは確認時にApple IDアカウントに課金されます。現在の期間終了の少なくとも24時間前にキャンセルしない限り自動更新されます。")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func purchase(_ product: StoreKit.Product) {
        Task {
            isPurchasing = true
            let success = await planService.purchase(product)
            isPurchasing = false
            if success { dismiss() }
        }
    }
}

import StoreKit

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}
