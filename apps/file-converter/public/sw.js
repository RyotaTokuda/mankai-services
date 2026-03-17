// Service Worker - ローカルファイル変換
// アプリシェルをキャッシュし、オフライン時は offline.html を表示する。

const CACHE_NAME = "file-converter-v2";
const OFFLINE_URL = "/offline.html";

// インストール時：オフラインフォールバックページだけは確実に事前キャッシュ
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll([OFFLINE_URL]))
  );
  self.skipWaiting();
});

// アクティベート時：古いキャッシュを削除
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // 別オリジン（CDN・外部API等）はキャッシュしない
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
