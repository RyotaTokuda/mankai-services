import type { NextConfig } from "next";

// ─── 全ページ共通のセキュリティヘッダー ──────────────────────────────────
const BASE_SECURITY_HEADERS = [
  { key: "Strict-Transport-Security",    value: "max-age=63072000; includeSubDomains; preload" },
  { key: "X-Content-Type-Options",       value: "nosniff" },
  { key: "X-Frame-Options",              value: "DENY" },
  { key: "Referrer-Policy",              value: "strict-origin-when-cross-origin" },
  { key: "Permissions-Policy",           value: "camera=(), microphone=(), geolocation=(), interest-cohort=()" },
];

// ─── SharedArrayBuffer に必要（ffmpeg.wasm）─────────────────────────────
// COOP: same-origin は OAuth リダイレクトと干渉するため、
// ffmpeg.wasm を使うワークスペースのみに適用する。
const COOP_COEP_HEADERS = [
  { key: "Cross-Origin-Opener-Policy",   value: "same-origin" },
  { key: "Cross-Origin-Embedder-Policy", value: "require-corp" },
];

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: BASE_SECURITY_HEADERS,
      },
      {
        source: "/workspace",
        headers: COOP_COEP_HEADERS,
      },
      {
        source: "/workspace/(.*)",
        headers: COOP_COEP_HEADERS,
      },
    ];
  },
};

export default nextConfig;
