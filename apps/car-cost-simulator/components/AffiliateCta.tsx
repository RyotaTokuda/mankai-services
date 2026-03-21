"use client";

import type { CostBreakdown } from "../lib/types";
import { formatYen } from "../lib/calc";
import { AFFILIATE_LINKS } from "../data/affiliate-links";

interface Props {
  costs: CostBreakdown;
}

interface CtaItem {
  icon: string;
  title: string;
  description: string;
  ctaText: string;
  href: string;
  note: string;
  show: boolean;
}

/**
 * 試算結果に基づくアフィリエイト導線
 *
 * ASP規約遵守:
 * - 広告表記を明示（ステマ規制法対応）
 * - rel="nofollow sponsored" を付与
 * - クリック誘導文言を使わない
 * - 虚偽・誇大表現を使わない
 */
export default function AffiliateCta({ costs }: Props) {
  const insuranceMonthly = Math.round(costs.insuranceAnnual / 12);

  const items: CtaItem[] = [
    {
      icon: "🛡️",
      title: "保険料が適正か相談してみる",
      description: `現在の保険料 月${formatYen(insuranceMonthly)}円。FP（ファイナンシャルプランナー）に無料で相談すると、同じ補償内容でも保険料を抑えられることがあります。`,
      ctaText: AFFILIATE_LINKS.carInsurance.label,
      href: AFFILIATE_LINKS.carInsurance.href,
      note: "何度でも無料。強引な勧誘なし",
      show: !!AFFILIATE_LINKS.carInsurance.href,
    },
    {
      icon: "🏦",
      title: "カーローンの金利を比較",
      description: `ローン返済額 月${formatYen(costs.loanMonthly)}円。銀行のマイカーローンならディーラーローンより金利が低いことが多く、総返済額を抑えられます。`,
      ctaText: AFFILIATE_LINKS.carLoan.label,
      href: AFFILIATE_LINKS.carLoan.href,
      note: "ネット銀行なら年1〜3%台の低金利も",
      show: !!AFFILIATE_LINKS.carLoan.href && costs.loanMonthly > 0,
    },
    {
      icon: "🔑",
      title: "カーリースという選択肢",
      description:
        "月々定額で頭金・車検・税金がコミコミ。維持費の管理がシンプルになります。購入との総額比較もしてみましょう。",
      ctaText: AFFILIATE_LINKS.carLease.label,
      href: AFFILIATE_LINKS.carLease.href,
      note: "月々1万円台から新車に乗れるプランも",
      show: !!AFFILIATE_LINKS.carLease.href,
    },
  ];

  const visibleItems = items.filter((item) => item.show);

  // リンクが1つも設定されていなければセクション自体を非表示
  if (visibleItems.length === 0) return null;

  return (
    <section className="space-y-4">
      <div className="flex items-center gap-2">
        <h2 className="text-lg font-bold">維持費を節約するには</h2>
        <span className="text-[10px] text-slate-400 border border-slate-200 dark:border-slate-600 rounded px-1.5 py-0.5">
          PR
        </span>
      </div>

      <div
        className={`grid gap-4 ${
          visibleItems.length >= 3
            ? "sm:grid-cols-2 lg:grid-cols-3"
            : visibleItems.length === 2
              ? "sm:grid-cols-2"
              : ""
        }`}
      >
        {visibleItems.map((item) => (
          <CtaCard key={item.title} {...item} />
        ))}
      </div>

      <p className="text-[10px] text-slate-400 text-center">
        ※ 本ページにはアフィリエイト広告が含まれています
      </p>
    </section>
  );
}

function CtaCard({
  icon,
  title,
  description,
  ctaText,
  href,
  note,
}: Omit<CtaItem, "show">) {
  return (
    <div className="rounded-2xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/60 shadow-sm p-5 flex flex-col">
      <div className="flex items-start gap-3 mb-3">
        <span className="text-2xl shrink-0" role="img" aria-hidden="true">
          {icon}
        </span>
        <div>
          <h3 className="text-sm font-bold text-slate-800 dark:text-slate-100">
            {title}
          </h3>
        </div>
      </div>

      <p className="text-xs text-slate-500 dark:text-slate-400 leading-relaxed mb-4 flex-1">
        {description}
      </p>

      <a
        href={href}
        rel="nofollow sponsored"
        target="_blank"
        className="block w-full rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 px-4 py-2.5 text-center text-sm font-medium text-white hover:from-emerald-600 hover:to-teal-600 transition-all shadow-md shadow-emerald-200 dark:shadow-emerald-900/30"
      >
        {ctaText}
      </a>

      <p className="text-[11px] text-slate-400 mt-2 text-center">{note}</p>
    </div>
  );
}
