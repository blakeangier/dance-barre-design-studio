"use client";

import { useEffect } from "react";
import { recoveryHashAction } from "@/lib/auth/recovery";

// The dashboard "Send password recovery" email verifies on Supabase, then
// redirects to the site URL with the session in the hash. The server never
// sees that hash, and the sign-in gate would otherwise leave the person on
// /login. This reads the hash once and stores the recovery session in cookies.
export function RecoveryHash() {
  useEffect(() => {
    const action = recoveryHashAction(window.location.hash);
    if (action.kind === "ignore") return;

    const clean = `${window.location.pathname}${window.location.search}`;
    window.history.replaceState(window.history.state, "", clean);

    if (action.kind === "error") {
      window.location.replace(`/reset-password?notice=${action.notice}`);
      return;
    }

    const accessToken = action.accessToken;
    const refreshToken = action.refreshToken;

    void (async () => {
      try {
        const [{ createBrowserClient }, { requirePublicSupabaseEnv }] =
          await Promise.all([
            import("@supabase/ssr"),
            import("@/lib/supabase/env"),
          ]);
        const { url, key } = requirePublicSupabaseEnv();
        // detectSessionInUrl stays off. The SSR client rejects this hash as
        // "not a PKCE flow", which would discard the recovery session.
        const supabase = createBrowserClient(url, key, {
          auth: { detectSessionInUrl: false },
        });
        const { error } = await supabase.auth.setSession({
          access_token: accessToken,
          refresh_token: refreshToken,
        });
        window.location.replace(
          error ? "/reset-password?notice=invalid" : "/reset-password",
        );
      } catch {
        window.location.replace("/login?notice=setup");
      }
    })();
  }, []);

  return null;
}
