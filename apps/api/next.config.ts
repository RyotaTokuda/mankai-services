import type { NextConfig } from "next";

const API_SECURITY_HEADERS = [
  // HTTPS を強制
  { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
  // MIME スニッフィング防止
  { key: "X-Content-Type-Options",    value: "nosniff" },
  // クリックジャッキング防止（API なのでページはないが念のため）
  { key: "X-Frame-Options",           value: "DENY" },
  // リファラー情報を最小化
  { key: "Referrer-Policy",           value: "no-referrer" },
  // 検索エンジンにインデックスさせない
  { key: "X-Robots-Tag",              value: "noindex, nofollow" },
];

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: API_SECURITY_HEADERS,
      },
    ];
  },
};

export default nextConfig;
