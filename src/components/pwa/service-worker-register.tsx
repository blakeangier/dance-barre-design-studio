"use client";

import { useEffect } from "react";

// Registers the service worker so phones can add the app to the home screen.
// Skipped in development so it does not fight hot reload.
export function ServiceWorkerRegister() {
  useEffect(() => {
    if (process.env.NODE_ENV !== "production") return;
    if (!("serviceWorker" in navigator)) return;

    navigator.serviceWorker.register("/sw.js").catch(() => {
      // The manifest still lets some phones add a home-screen icon.
    });
  }, []);

  return null;
}
