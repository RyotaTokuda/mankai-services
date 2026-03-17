"use client";

import { useEffect, useState } from "react";
import { checkBrowserCompat, SUPPORTED_BROWSERS, BrowserCompat } from "@/lib/browserCompat";

export default function BrowserWarning() {
  const [compat, setCompat] = useState<BrowserCompat | null>(null);

  useEffect(() => {
    setCompat(checkBrowserCompat());
  }, []);

  if (!compat) return null;

  // 画像変換も動かない場合：完全非対応
  if (!compat.imageSupported) {
    return (
      <div className="rounded-2xl bg-red-50 border border-red-200 px-5 py-4 space-y-3">
        <p className="text-sm font-bold text-red-800">
          ⚠️ このブラウザには対応していません
        </p>
        <p className="text-sm text-red-700 leading-relaxed">
          お使いのブラウザでは変換機能が動作しません。
          以下のブラウザの最新版に切り替えてください。
        </p>
        <BrowserList />
      </div>
    );
  }

  // 動画変換だけ動かない場合：部分対応
  if (!compat.videoSupported) {
    return (
      <div className="rounded-2xl bg-amber-50 border border-amber-200 px-5 py-4 space-y-3">
        <p className="text-sm font-bold text-amber-800">
          ⚠️ 動画変換はこのブラウザではご利用いただけません
        </p>
        <p className="text-sm text-amber-700 leading-relaxed">
          動画変換には <strong>SharedArrayBuffer</strong> が必要です。
          画像変換は問題なくご利用いただけます。
        </p>
        <p className="text-sm text-amber-700">
          動画変換をご利用の場合は以下のブラウザをお使いください。
        </p>
        <BrowserList />
      </div>
    );
  }

  return null;
}

function BrowserList() {
  return (
    <ul className="text-xs text-gray-600 space-y-1">
      {SUPPORTED_BROWSERS.map((b) => (
        <li key={b.name} className="flex gap-2">
          <span className="text-emerald-600">✓</span>
          <span><strong>{b.name}</strong>　{b.minVersion}</span>
        </li>
      ))}
    </ul>
  );
}
