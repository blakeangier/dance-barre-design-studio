// Future door for the Dance Barre OS parent app.
// When it is built, it will be a server route that checks its own key.
// That key must never be prefixed with NEXT_PUBLIC_.
export const osIntegrationModule = {
  id: "os-integration",
  title: "Dance Barre OS",
  summary:
    "A later phase will expose a small server-side API so the parent studio system can ask this app for manufacturing status. There is no public endpoint in this phase.",
};
