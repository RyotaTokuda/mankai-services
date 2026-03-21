export interface BrowserCompat {
  /** imageSupported: Canvas API etc. */
  imageSupported: boolean;
  /** videoSupported: SharedArrayBuffer + WebAssembly */
  videoSupported: boolean;
}

export function checkBrowserCompat(): BrowserCompat {
  if (typeof window === "undefined") {
    return { imageSupported: true, videoSupported: true };
  }

  const imageSupported =
    typeof File !== "undefined" &&
    typeof Blob !== "undefined" &&
    typeof URL !== "undefined" &&
    typeof URL.createObjectURL === "function" &&
    typeof createImageBitmap === "function" &&
    !!document.createElement("canvas").getContext("2d");

  const videoSupported = (() => {
    try {
      return (
        typeof WebAssembly !== "undefined" &&
        typeof SharedArrayBuffer !== "undefined"
      );
    } catch {
      return false;
    }
  })();

  return { imageSupported, videoSupported };
}

export const SUPPORTED_BROWSERS = [
  { name: "Chrome / Edge", minVersion: "90以上" },
  { name: "Firefox",        minVersion: "90以上" },
  { name: "Safari",         minVersion: "15.2以上" },
  { name: "iOS Safari",     minVersion: "15.2以上（iOS 15.2）" },
  { name: "Android Chrome", minVersion: "90以上" },
] as const;

export type DeviceTier = "high" | "medium" | "low" | "unsupported";

export interface DeviceCapability {
  tier: DeviceTier;
  maxFileSizeMB: number;
  maxDurationSec: number;
}

export function detectDeviceCapability(): DeviceCapability {
  if (typeof window === "undefined" || typeof navigator === "undefined") {
    return { tier: "medium", maxFileSizeMB: 100, maxDurationSec: 300 };
  }

  const hasSharedArrayBuffer = (() => {
    try { return typeof SharedArrayBuffer !== "undefined"; } catch { return false; }
  })();

  if (!hasSharedArrayBuffer) {
    return { tier: "unsupported", maxFileSizeMB: 0, maxDurationSec: 0 };
  }

  const cores = navigator.hardwareConcurrency ?? 2;
  const memory = (navigator as { deviceMemory?: number }).deviceMemory ?? 4;

  if (cores >= 8 && memory >= 8) {
    return { tier: "high", maxFileSizeMB: 500, maxDurationSec: 600 };
  }
  if (cores >= 4 && memory >= 4) {
    return { tier: "medium", maxFileSizeMB: 200, maxDurationSec: 300 };
  }
  return { tier: "low", maxFileSizeMB: 50, maxDurationSec: 120 };
}

export function deviceTierMessage(cap: DeviceCapability): string {
  switch (cap.tier) {
    case "high":
      return `高性能端末 — ${cap.maxFileSizeMB}MB・${cap.maxDurationSec / 60}分まで快適に変換できます`;
    case "medium":
      return `標準端末 — ${cap.maxFileSizeMB}MB・${cap.maxDurationSec / 60}分以内を推奨`;
    case "low":
      return `軽量モード — ${cap.maxFileSizeMB}MB・${cap.maxDurationSec / 60}分以内を推奨（大きいファイルは時間がかかります）`;
    case "unsupported":
      return "お使いの環境では動画変換を利用できません";
  }
}
