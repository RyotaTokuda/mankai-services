import type { Metadata } from "next";
import { Geist } from "next/font/google";
import "./globals.css";

const geist = Geist({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "車の維持費シミュレーター | くらべるラボ",
  description:
    "車の購入前に総額を試算。ローン・保険・駐車場・燃料・車検などを入力して月額・年額・5年総額を即座に比較。",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ja">
      <body
        className={`${geist.className} bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-950 dark:to-slate-900 text-slate-800 dark:text-slate-200 antialiased min-h-screen`}
      >
        <header className="sticky top-0 z-10 backdrop-blur-md bg-white/80 dark:bg-slate-900/80 border-b border-slate-200 dark:border-slate-700">
          <div className="mx-auto max-w-7xl flex items-center justify-between px-4 py-3">
            <div className="flex items-center gap-2">
              <span className="text-2xl" role="img" aria-hidden="true">
                🚗
              </span>
              <h1 className="text-lg font-bold bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent">
                車の維持費シミュレーター
              </h1>
            </div>
            <span className="text-xs text-slate-400">くらべるラボ</span>
          </div>
        </header>
        <main>{children}</main>
        <footer className="mt-16 border-t border-slate-200 dark:border-slate-700 py-6 text-center text-xs text-slate-400 space-y-1">
          <p>&copy; 2025 くらべるラボ（Mankai Software）</p>
          <p>当サイトはアフィリエイト広告を利用しています</p>
        </footer>
      </body>
    </html>
  );
}
