"use client";

import { useState } from "react";
import {
  pushPublicKey,
  savePushSubscription,
} from "@/app/(workspace)/account/notifications/actions";

function keyBytes(value: string): Uint8Array<ArrayBuffer> {
  const padded = value + "=".repeat((4 - (value.length % 4)) % 4);
  const decoded = atob(padded.replace(/-/g, "+").replace(/_/g, "/"));
  const bytes = new Uint8Array(decoded.length);
  for (let index = 0; index < decoded.length; index += 1) {
    bytes[index] = decoded.charCodeAt(index);
  }
  return bytes;
}

function installedToHomeScreen(): boolean {
  const standalone = window.matchMedia("(display-mode: standalone)").matches;
  const ios = Boolean(
    (navigator as Navigator & { standalone?: boolean }).standalone,
  );
  return standalone || ios;
}

function isIphone(): boolean {
  return /iPhone|iPad|iPod/i.test(navigator.userAgent);
}

export function EnableNotifications() {
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function enable() {
    setBusy(true);
    setMessage(null);
    try {
      if (!("Notification" in window) || !("serviceWorker" in navigator)) {
        setMessage("This browser cannot show notifications.");
        return;
      }
      if (isIphone() && !installedToHomeScreen()) {
        setMessage(
          "On iPhone, add the app to the Home Screen first. Then open it from that icon and tap this button again.",
        );
        return;
      }
      const permission = await Notification.requestPermission();
      if (permission !== "granted") {
        setMessage("Notifications stay off until you allow them.");
        return;
      }
      const publicKey = await pushPublicKey();
      if (!publicKey) {
        setMessage(
          "Notifications are not set up on the server yet. An owner still has to add the keys.",
        );
        return;
      }
      const registration = await navigator.serviceWorker.register("/sw.js");
      const ready = await navigator.serviceWorker.ready;
      const subscription = await (
        registration.pushManager || ready.pushManager
      ).subscribe({
        userVisibleOnly: true,
        applicationServerKey: keyBytes(publicKey),
      });
      const json = subscription.toJSON();
      const saved = await savePushSubscription({
        endpoint: subscription.endpoint,
        p256dh: json.keys?.p256dh ?? "",
        auth: json.keys?.auth ?? "",
        userAgent: navigator.userAgent,
      });
      setMessage(
        saved.ok ? "This device can receive notifications." : saved.message,
      );
    } catch {
      setMessage("This device did not turn notifications on.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex flex-col gap-2">
      <button
        id="enable-notifications"
        type="button"
        disabled={busy}
        onClick={() => void enable()}
        className="min-h-12 rounded-full bg-ink px-4 font-medium text-white disabled:opacity-60"
      >
        {busy ? "Asking this device…" : "Enable notifications"}
      </button>
      {message ? <p className="text-sm text-ink">{message}</p> : null}
    </div>
  );
}
