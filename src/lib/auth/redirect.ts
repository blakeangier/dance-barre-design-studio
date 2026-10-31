// Only allow in-app paths. Stops a crafted link from sending someone off-site
// after they sign in.

export function safeNextPath(value: string | undefined): string {
  if (!value) return "/";
  if (!value.startsWith("/")) return "/";
  if (value.startsWith("//") || value.startsWith("/\\")) return "/";
  if (value.startsWith("/login") || value.startsWith("/auth")) return "/";
  return value;
}
