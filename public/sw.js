// Minimal service worker so the app can be installed on a phone home screen.
// It does not cache pages or data. A cached page could show the wrong person.

self.addEventListener("install", (event) => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;

  event.respondWith(fetch(event.request));
});

self.addEventListener("push", (event) => {
  let payload = { title: "Dance Barre Design Studio", body: "", url: "/" };
  try {
    const data = event.data ? event.data.json() : null;
    if (data && typeof data.title === "string") payload.title = data.title;
    if (data && typeof data.body === "string") payload.body = data.body;
    if (data && typeof data.url === "string" && data.url.startsWith("/")) {
      payload.url = data.url;
    }
  } catch {
    payload.body = event.data ? event.data.text() : "";
  }
  event.waitUntil(
    self.registration.showNotification(payload.title, {
      body: payload.body,
      icon: "/icons/icon-192.png",
      data: { url: payload.url },
    }),
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const url =
    event.notification.data && event.notification.data.url
      ? event.notification.data.url
      : "/";
  event.waitUntil(self.clients.openWindow(url));
});
