/**
 * アフィリエイトリンク管理
 *
 * ASP提携完了後、ここにURLを設定する。
 * href が空文字の場合、CTAボタンは非表示になる。
 *
 * 必須: rel="nofollow sponsored" をリンクに付与すること（コンポーネント側で対応済み）
 *
 * 更新日: 2026-03-21
 */

export const AFFILIATE_LINKS = {
  /** 保険の無料相談（保険マンモス / A8提携済み） */
  carInsurance: {
    href: "https://px.a8.net/svt/ejp?a8mat=4AZK8A+DKSX7E+1UTA+25EKCY",
    label: "FPに無料で保険相談する",
  },
  /** カーローン比較（未提携 — 提携取得後にURLを設定） */
  carLoan: {
    href: "",
    label: "銀行ローンの金利を比べる",
  },
  /** カーリース ニコノリ（A8提携済み / 報酬20,000円） */
  carLease: {
    href: "https://px.a8.net/svt/ejp?a8mat=4AZK8A+D1R1UI+52IU+5YRHE",
    label: "月額料金をシミュレーション",
  },
} as const;
