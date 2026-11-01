import type { Metadata, Viewport } from "next";
import { Fraunces, Outfit } from "next/font/google";
import { RecoveryHash } from "@/components/auth/recovery-hash";
import { ServiceWorkerRegister } from "@/components/pwa/service-worker-register";
import "./globals.css";

const outfit = Outfit({
  subsets: ["latin"],
  variable: "--font-outfit",
});

const fraunces = Fraunces({
  subsets: ["latin"],
  variable: "--font-fraunces",
});

export const metadata: Metadata = {
  title: {
    default: "Dance Barre Design Studio",
    template: "%s · Dance Barre Design Studio",
  },
  description: "Manufacturing workspace for Dance Barre Design Studio.",
  applicationName: "Dance Barre Design Studio",
  robots: { index: false, follow: false },
  appleWebApp: {
    capable: true,
    title: "Design Studio",
    statusBarStyle: "default",
  },
  icons: {
    icon: [
      { url: "/icons/icon-192.png", sizes: "192x192", type: "image/png" },
      { url: "/icons/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
    apple: [{ url: "/icons/apple-touch-icon.png", sizes: "180x180" }],
  },
};

export const viewport: Viewport = {
  themeColor: "#9C78B6",
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
  interactiveWidget: "resizes-content",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="en"
      className={`${outfit.variable} ${fraunces.variable} h-full`}
    >
      <body className="min-h-full antialiased">
        <ServiceWorkerRegister />
        <RecoveryHash />
        {children}
      </body>
    </html>
  );
}
