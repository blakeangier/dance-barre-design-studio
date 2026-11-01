import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { requirePublicSupabaseEnv } from "@/lib/supabase/env";

// Server client for the signed-in person. It sends their cookies, so Postgres
// row-level security applies. Do not use this with the secret key.
export async function createClient() {
  const { url, key } = requirePublicSupabaseEnv();
  const cookieStore = await cookies();

  return createServerClient(url, key, {
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet) {
        try {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        } catch {
          // Server Components cannot write cookies. src/proxy.ts refreshes
          // the session on each request, so this can be ignored here.
        }
      },
    },
  });
}
