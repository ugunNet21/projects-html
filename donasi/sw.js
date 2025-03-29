// sw.js
self.addEventListener('install', e => {
    e.waitUntil(
      caches.open('donasi-cache').then(cache => {
        return cache.addAll(['/', '/index.html', '/style.css']);
      })
    );
  });
  self.addEventListener('fetch', e => {
    e.respondWith(
      caches.match(e.request).then(response => response || fetch(e.request))
    );
  });
  