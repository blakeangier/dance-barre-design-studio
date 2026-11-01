import "server-only";
import { createClient } from "@supabase/supabase-js";

// Server-only client that bypasses row-level security.
// Used after an owner check to change roles. Never import this from a
// Client Component, and never put the key in a NEXT_PUBLIC_ variable.
export function createAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key =
    process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error(
      "Missing the server-only Supabase secret. Set SUPABASE_SECRET_KEY or SUPABASE_SERVICE_ROLE_KEY in .env.local. Do not prefix it with NEXT_PUBLIC_.",
    );
  }

  return createClient(url, key, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
