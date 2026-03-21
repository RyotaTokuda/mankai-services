/**
 * アフィリエイトリンク管理
 *
 * href が空文字の場合、CTAボタンは非表示になる。
 * rel="nofollow sponsored" はコンポーネント側で付与済み。
 *
 * 遷移先確認済み:
 *   ニコノリ → www.niconori.jp
 *   保険マンモス → www.hoken-mammoth.jp
 *
 * 更新日: 2026-03-21
 */

export const AFFILIATE_LINKS = {
  /** 保険マンモス FP無料保険相談（A8 s00000027024001）
   *  → www.hoken-mammoth.jp にリダイレクト確認済み */
  carInsurance: {
    href: "https://px.a8.net/svt/ejp?a8mat=4AZK8B+2YKMU2+5SIO+5YZ75",
    label: "FPに無料で保険相談する",
  },
  /** カーローン比較（未提携） */
  carLoan: {
    href: "",
    label: "銀行ローンの金利を比べる",
  },
  /** ニコノリ カーリース（A8 s00000022169001 / 報酬20,000円）
   *  → www.niconori.jp にリダイレクト確認済み */
  carLease: {
    href: "https://px.a8.net/svt/ejp?a8mat=4AZK8A+AMTRIY+4R22+5YRHE",
    label: "月額料金をシミュレーション",
  },
} as const;
