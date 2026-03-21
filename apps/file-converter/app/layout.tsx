import type { Metadata, Viewport } from "next";
import { Geist } from "next/font/google";
import PwaRegister from "@/components/PwaRegister";
import { AuthProvider } from "@mankai/auth/context";
import "./globals.css";

const geist = Geist({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "ローカルファイル変換 — ブラウザ内で画像・PDF処理 | Mankai Software",
  description:
    "画像変換・圧縮・リサイズ、PDF結合・分割をブラウザ内だけで処理。ファイルはサーバーに送信されません。",
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "ファイル変換",
  },
};

export const viewport: Viewport = {
  themeColor: "#059669",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <head>
        <link rel="apple-touch-icon" href="/icon.svg" />
      </head>
      <body className={`${geist.className} bg-gray-50 text-gray-900 antialiased`}>
        <AuthProvider>
          {children}
        </AuthProvider>
        <PwaRegister />
      </body>
    </html>
  );
}
