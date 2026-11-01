import { finishEmailLink } from "@/lib/auth/email-link";

// Magic-link and other email links land here. A recovery link that includes
// type=recovery is sent on to the set-password page instead of the app.
export async function GET(request: Request) {
  return finishEmailLink(request, false);
}
