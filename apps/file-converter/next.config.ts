import type { NextConfig } from "next";

const SECURITY_HEADERS = [
  // ─── SharedArrayBuffer に必要（ffmpeg.wasm） ─────────────────────────────
  { key: "Cross-Origin-Opener-Policy",   value: "same-origin" },
  { key: "Cross-Origin-Embedder-Policy", value: "require-corp" },

  // ─── 一般的なセキュリティヘッダー ──────────────────────────────────────
  // HTTPS を強制（Vercel は常に HTTPS）
  { key: "Strict-Transport-Security",    value: "max-age=63072000; includeSubDomains; preload" },
  // MIME スニッフィング防止
  { key: "X-Content-Type-Options",       value: "nosniff" },
  // クリックジャッキング防止
  { key: "X-Frame-Options",              value: "DENY" },
  // リファラー情報を最小化
  { key: "Referrer-Policy",              value: "strict-origin-when-cross-origin" },
  // 不要なブラウザ機能を無効化
  { key: "Permissions-Policy",           value: "camera=(), microphone=(), geolocation=(), interest-cohort=()" },
];

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: SECURITY_HEADERS,
      },
    ];
  },
};

export default nextConfig;
