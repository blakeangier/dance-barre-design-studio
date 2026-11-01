import { finishEmailLink } from "@/lib/auth/email-link";

// Password-reset links land here.
// PKCE: resetPasswordForEmail redirects to this path with ?code=.
// token_hash: the recovery email template links here with ?token_hash&type=recovery.
// Either one is exchanged for a session, then the browser opens /reset-password.
export async function GET(request: Request) {
  return finishEmailLink(request, true);
}
