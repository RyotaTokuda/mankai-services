"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const TABS = [
  {
    href: "/",
    label: "ホーム",
    icon: (active: boolean) => (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path
          d="M3 9.5L12 3l9 6.5V21a1 1 0 01-1 1H5a1 1 0 01-1-1V9.5z"
          stroke={active ? "#2563EB" : "#94A3B8"}
          strokeWidth="2"
          fill={active ? "#EFF6FF" : "none"}
          strokeLinejoin="round"
        />
        <path
          d="M9 22V12h6v10"
          stroke={active ? "#2563EB" : "#94A3B8"}
          strokeWidth="2"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  {
    href: "/history",
    label: "履歴",
    icon: (active: boolean) => (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <circle
          cx="12"
          cy="12"
          r="9"
          stroke={active ? "#2563EB" : "#94A3B8"}
          strokeWidth="2"
        />
        <path
          d="M12 7v5l3 3"
          stroke={active ? "#2563EB" : "#94A3B8"}
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  {
    href: "/settings",
    label: "設定",
    icon: (active: boolean) => (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <circle
          cx="12"
          cy="12"
          r="3"
          stroke={active ? "#2563EB" : "#94A3B8"}
          strokeWidth="2"
        />
        <path
          d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"
          stroke={active ? "#2563EB" : "#94A3B8"}
          strokeWidth="2"
        />
      </svg>
    ),
  },
];

// BottomNavを表示しないパス（タスクフロー画面）
const HIDDEN_PATHS = ["/upload", "/result"];

export default function BottomNav() {
  const pathname = usePathname();

  if (HIDDEN_PATHS.some((p) => pathname.startsWith(p))) return null;

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-slate-200 bg-white">
      <div className="mx-auto flex max-w-md">
        {TABS.map((tab) => {
          const active = pathname === tab.href;
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className="flex flex-1 flex-col items-center gap-1 py-2 active:bg-slate-50"
            >
              {tab.icon(active)}
              <span
                className={`text-xs font-medium ${
                  active ? "text-blue-600" : "text-slate-400"
                }`}
              >
                {tab.label}
              </span>
            </Link>
          );
        })}
      </div>
      {/* iPhoneのホームインジケーター分の余白 */}
      <div className="h-safe-area-bottom" />
    </nav>
  );
}
