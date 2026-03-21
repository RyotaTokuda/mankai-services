// Service Worker - ローカルファイル変換
// アプリシェルをキャッシュし、オフライン時は offline.html を表示する。
// CDN 依存ツール（ffmpeg.wasm, pdfjs-dist）も初回読み込み時にキャッシュする。

const CACHE_NAME = "file-converter-v3";
const CDN_CACHE_NAME = "file-converter-cdn-v1";
const OFFLINE_URL = "/offline.html";

// CDN からキャッシュすべきパターン
const CDN_CACHE_PATTERNS = [
  /unpkg\.com\/@ffmpeg\/core/,       // ffmpeg.wasm core + wasm
  /unpkg\.com\/pdfjs-dist/,          // pdfjs-dist worker
];

// インストール時：オフラインフォールバックページだけは確実に事前キャッシュ
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll([OFFLINE_URL]))
  );
  self.skipWaiting();
});

// アクティベート時：古いキャッシュを削除（現行バージョン以外）
self.addEventListener("activate", (event) => {
  const keepCaches = new Set([CACHE_NAME, CDN_CACHE_NAME]);
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((k) => !keepCaches.has(k)).map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // CDN リクエスト：キャッシュ優先 → なければネットワーク → キャッシュに保存
  if (url.origin !== self.location.origin && isCdnCacheable(url.href)) {
    event.respondWith(
      caches.open(CDN_CACHE_NAME).then(async (cache) => {
        const cached = await cache.match(request);
        if (cached) return cached;

        const response = await fetch(request);
        if (response.ok) {
          cache.put(request, response.clone());
        }
        return response;
      })
    );
    return;
  }

  // 別オリジン（CDN キャッシュ対象外）はスルー
  if (url.origin !== self.location.origin) return;

  if (request.mode === "navigate") {
    // ページナビゲーション：ネットワーク優先
    // → 失敗時はキャッシュを返し、キャッシュもなければ offline.html
    event.respondWith(
      fetch(request)
        .then((response) => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          return response;
        })
        .catch(async () => {
          const cached = await caches.match(request);
          return cached ?? (await caches.match(OFFLINE_URL));
        })
    );
  } else {
    // 静的アセット（JS・CSS・画像）：キャッシュ優先、なければネットワークに取りに行きキャッシュ
    event.respondWith(
      caches.match(request).then((cached) => {
        if (cached) return cached;
        return fetch(request).then((response) => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          }
          return response;
        });
      })
    );
  }
});

function isCdnCacheable(href) {
  return CDN_CACHE_PATTERNS.some((pattern) => pattern.test(href));
}
