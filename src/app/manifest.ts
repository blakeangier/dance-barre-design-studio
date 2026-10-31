import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Dance Barre Design Studio",
    short_name: "Design Studio",
    description: "Manufacturing workspace for Dance Barre Design Studio.",
    start_url: "/",
    scope: "/",
    display: "standalone",
    background_color: "#FFFFFF",
    theme_color: "#9C78B6",
    lang: "en-CA",
    icons: [
      {
        src: "/icons/icon-192.png",
        sizes: "192x192",
        type: "image/png",
        purpose: "any",
      },
      {
        src: "/icons/icon-512.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "any",
      },
      {
        src: "/icons/icon-512.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "maskable",
      },
    ],
  };
}
