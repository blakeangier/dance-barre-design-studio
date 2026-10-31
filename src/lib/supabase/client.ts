import { createBrowserClient } from "@supabase/ssr";
import { requirePublicSupabaseEnv } from "@/lib/supabase/env";

// Browser client. Uses the publishable key only. Call from Client Components.
export function createClient() {
  const { url, key } = requirePublicSupabaseEnv();
  return createBrowserClient(url, key);
}
