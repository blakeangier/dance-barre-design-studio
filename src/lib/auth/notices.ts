const NOTICES: Record<string, string> = {
  invalid:
    "That email or password did not match. An owner creates each account.",
  missing: "Enter both your email and your password.",
  link: "If that email has an account, a sign-in link is on its way. Until email sending is connected, use the password an owner gave you.",
  setup:
    "This copy of the app is not connected to Supabase yet. Add the values from .env.example to .env.local.",
  inactive: "This account is turned off. Ask an owner for help.",
  saved: "Saved.",
  name: "Enter a name, up to 120 characters.",
  phone: "Phone numbers can be up to 40 characters.",
  "save-failed":
    "That could not be saved. Try again, or check that the database migrations are applied.",
  denied: "You don't have access to that.",
  self: "You cannot change your own access. The other owner can.",
  secret:
    "The server-only Supabase secret is missing, so roles cannot be changed from this screen yet.",
  failed: "The change did not save. Check the server secret and try again.",
  "missing-person": "That person could not be found.",
};

export function noticeText(code: string | undefined): string | null {
  if (!code) return null;
  return NOTICES[code] ?? null;
}

export function firstQueryValue(
  value: string | string[] | undefined,
): string | undefined {
  if (Array.isArray(value)) return value[0];
  return value;
}
