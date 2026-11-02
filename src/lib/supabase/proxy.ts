import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import {
  hasPublicSupabaseEnv,
  requirePublicSupabaseEnv,
} from "@/lib/supabase/env";
import { safeNextPath } from "@/lib/auth/redirect";
import {
  authParamForwardPath,
  isPasswordRecoveryPage,
} from "@/lib/auth/recovery";

function isPublicPath(pathname: string): boolean {
  return (
    pathname.startsWith("/login") ||
    pathname.startsWith("/auth/") ||
    isPasswordRecoveryPage(pathname) ||
    pathname === "/api/low-stock-digest" ||
    pathname === "/api/push-flush" ||
    pathname === "/manifest.webmanifest" ||
    pathname === "/sw.js" ||
    pathname.startsWith("/icons/")
  );
}

function copySession(from: NextResponse, to: NextResponse) {
  from.cookies.getAll().forEach((cookie) => {
    to.cookies.set(cookie);
  });
  for (const header of ["cache-control", "expires", "pragma"]) {
    const value = from.headers.get(header);
    if (value) to.headers.set(header, value);
  }
}

// Refreshes the auth cookie and sends signed-out visitors to the login page.
// Page code still checks the role. This redirect is not the security boundary.
export async function updateSession(request: NextRequest) {
  if (!hasPublicSupabaseEnv()) {
    return NextResponse.next({ request });
  }

  let supabaseResponse = NextResponse.next({ request });
  const { url, key } = requirePublicSupabaseEnv();

  const supabase = createServerClient(url, key, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet, headers) {
        cookiesToSet.forEach(({ name, value }) => {
          request.cookies.set(name, value);
        });
        supabaseResponse = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) => {
          supabaseResponse.cookies.set(name, value, options);
        });
        Object.entries(headers).forEach(([header, value]) => {
          supabaseResponse.headers.set(header, value);
        });
      },
    },
  });

  // Do not run other code between creating the client and getClaims().
  // getClaims() checks the token signature. getSession() does not.
  const { data } = await supabase.auth.getClaims();
  const signedIn = Boolean(data?.claims.sub);
  const { pathname } = request.nextUrl;

  // Supabase's Site URL is the app root. A recovery or magic-link redirect
  // therefore arrives as /?code= or /?token_hash= before any session exists.
  // The gate below would send that request to /login and clear the query
  // string, which is why a dashboard recovery email opened the sign-in page.
  if (request.method === "GET") {
    const forward = authParamForwardPath(pathname, request.nextUrl.searchParams);
    if (forward) {
      const url = request.nextUrl.clone();
      url.pathname = forward;
      const redirectResponse = NextResponse.redirect(url);
      copySession(supabaseResponse, redirectResponse);
      return redirectResponse;
    }
  }

  if (!signedIn && !isPublicPath(pathname)) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    url.search = "";
    if (pathname !== "/") {
      url.searchParams.set("next", pathname);
    }
    const redirectResponse = NextResponse.redirect(url);
    copySession(supabaseResponse, redirectResponse);
    return redirectResponse;
  }

  if (signedIn && pathname.startsWith("/login")) {
    const url = request.nextUrl.clone();
    url.pathname = safeNextPath(
      request.nextUrl.searchParams.get("next") ?? undefined,
    );
    url.search = "";
    const redirectResponse = NextResponse.redirect(url);
    copySession(supabaseResponse, redirectResponse);
    return redirectResponse;
  }

  return supabaseResponse;
}
