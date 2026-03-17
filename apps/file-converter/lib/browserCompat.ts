export interface BrowserCompat {
  /** 画像変換に必要な基本APIが揃っているか */
  imageSupported: boolean;
  /** 動画変換に必要な SharedArrayBuffer + WebAssembly が使えるか */
  videoSupported: boolean;
}

export function checkBrowserCompat(): BrowserCompat {
  // SSR時は楽観的に true を返す（クライアントで再チェックされる）
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

/** 推奨ブラウザと最低バージョン */
export const SUPPORTED_BROWSERS = [
  { name: "Chrome / Edge", minVersion: "90以上" },
  { name: "Firefox",        minVersion: "90以上" },
  { name: "Safari",         minVersion: "15.2以上" },
  { name: "iOS Safari",     minVersion: "15.2以上（iOS 15.2）" },
  { name: "Android Chrome", minVersion: "90以上" },
] as const;
