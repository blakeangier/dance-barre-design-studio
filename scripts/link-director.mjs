// Create or update a program director and link her to one program.
// Run from the project folder after .env.local exists and the production
// status migrations are applied on that database:
//
//   node scripts/link-director.mjs \
//     --email malika@example.com \
//     --name "Malika Mowinski-Waters" \
//     --program "Elite Company"
//
// Programs: Elite Company, CREW, Petite Elite, Recreational.
// Recreational has no director yet.
// A new director starts with every program checked. This script replaces
// those links with the one program you name. A director with no link sees
// no orders. An order with no program is hidden from every director.
// Running this again with a different --program moves her to that program.
//
// The role has to live in app_metadata. SQL alone cannot create the login.
// After this script, the link is:
//
//   insert into public.director_programs (profile_id, program_id)
//   select profile.id, program.id
//   from public.profiles profile
//   join public.programs program on program.name = 'Elite Company'
//   where profile.id = '<auth user uuid>'
//   on conflict do nothing;

import { createClient } from "@supabase/supabase-js";
import { randomBytes } from "node:crypto";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
loadEnvFile(join(root, ".env.local"));
loadEnvFile(join(root, ".env"));

const args = readArgs(process.argv.slice(2));
const email = args.email?.trim().toLowerCase();
const fullName = args.name?.trim();
const programName = args.program?.trim();

if (!email || !fullName || !programName) {
  console.error(
    'Usage: node scripts/link-director.mjs --email <email> --name "<full name>" --program "<Elite Company|CREW|Petite Elite>"',
  );
  process.exit(1);
}

const url = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL;
const secret =
  process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !secret) {
  console.error(
    "Missing NEXT_PUBLIC_SUPABASE_URL and the server-only secret (SUPABASE_SECRET_KEY or SUPABASE_SERVICE_ROLE_KEY).",
  );
  process.exit(1);
}

if (secret.startsWith("sb_publishable_")) {
  console.error("That key is the publishable key. Use the secret key instead.");
  process.exit(1);
}

const supabase = createClient(url, secret, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const { data: programRow, error: programError } = await supabase
  .from("programs")
  .select("id, name")
  .eq("name", programName)
  .maybeSingle();

if (programError || !programRow) {
  console.error(
    programError
      ? `Could not read programs: ${programError.message}`
      : `No program named "${programName}". Apply the production status migrations first.`,
  );
  process.exit(1);
}

const existing = await listAllUsers(supabase);
const found = existing.find((user) => user.email?.toLowerCase() === email);
const resetPassword = process.argv.includes("--reset-password");
let userId = found?.id ?? null;
let password = null;

const appMetadata = {
  ...(found?.app_metadata ?? {}),
  role: "program_director",
  can_purchase: false,
  can_update_order_status: false,
  full_name: fullName,
};

if (!found) {
  password = temporaryPassword();
  const { data, error } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    app_metadata: appMetadata,
  });
  if (error || !data.user) {
    console.error(
      `Could not create ${email}: ${error?.message ?? "unknown error"}`,
    );
    process.exit(1);
  }
  userId = data.user.id;
} else {
  if (resetPassword) password = temporaryPassword();
  const { error } = await supabase.auth.admin.updateUserById(found.id, {
    app_metadata: appMetadata,
    ...(password ? { password } : {}),
  });
  if (error) {
    console.error(`Could not update ${email}: ${error.message}`);
    process.exit(1);
  }
}

const { error: profileError } = await supabase.from("profiles").upsert(
  {
    id: userId,
    full_name: fullName,
    role: "program_director",
    can_purchase: false,
    can_update_order_status: false,
    is_active: true,
  },
  { onConflict: "id" },
);

if (profileError) {
  console.error(
    `The login exists, but the profile was not saved: ${profileError.message}`,
  );
  process.exit(1);
}

const { error: contactError } = await supabase
  .from("profile_contacts")
  .upsert({ profile_id: userId, email }, { onConflict: "profile_id" });

if (contactError) {
  console.error(
    `The login exists, but the contact row was not saved: ${contactError.message}`,
  );
  process.exit(1);
}

const { error: clearError } = await supabase
  .from("director_programs")
  .delete()
  .eq("profile_id", userId);

if (clearError) {
  console.error(`Could not replace program links: ${clearError.message}`);
  process.exit(1);
}

const { error: linkError } = await supabase.from("director_programs").insert({
  profile_id: userId,
  program_id: programRow.id,
});

if (linkError) {
  console.error(`Could not link ${programName}: ${linkError.message}`);
  process.exit(1);
}

console.log(`${email}\t${found ? "updated" : "created"}\t${programName}`);
console.log(
  password ? `Temporary password: ${password}` : "Password unchanged.",
);
console.log("Write the password down somewhere private. Do not commit it.");

function readArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) continue;
    const key = token.slice(2);
    const value = argv[i + 1];
    if (!value || value.startsWith("--")) continue;
    out[key] = value;
    i += 1;
  }
  return out;
}

function temporaryPassword() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
  const bytes = randomBytes(18);
  let password = "Db1";
  for (const byte of bytes) password += alphabet[byte % alphabet.length];
  return password;
}

async function listAllUsers(client) {
  const users = [];
  let page = 1;
  while (page < 20) {
    const { data, error } = await client.auth.admin.listUsers({
      page,
      perPage: 200,
    });
    if (error) {
      console.error(`Could not list users: ${error.message}`);
      process.exit(1);
    }
    users.push(...data.users);
    if (data.users.length < 200) break;
    page += 1;
  }
  return users;
}

function loadEnvFile(path) {
  let text;
  try {
    text = readFileSync(path, "utf8");
  } catch {
    return;
  }
  for (const line of text.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (!(key in process.env)) process.env[key] = value;
  }
}
