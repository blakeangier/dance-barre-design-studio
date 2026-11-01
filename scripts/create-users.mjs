// Creates the first accounts with the Supabase secret key.
// Run from the project folder after .env.local exists:
//   node scripts/create-users.mjs
//
// Passwords are generated here and printed once. They are not stored in git.
// There is no public sign-up. Employees are added later by editing
// scripts/initial-users.json and running this again.

import { createClient } from "@supabase/supabase-js";
import { randomBytes } from "node:crypto";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const roles = new Set([
  "owner",
  "production_manager",
  "payroll_admin",
  "employee",
  "program_director",
]);

loadEnvFile(join(root, ".env.local"));
loadEnvFile(join(root, ".env"));

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

const people = JSON.parse(
  readFileSync(join(root, "scripts", "initial-users.json"), "utf8"),
);

const supabase = createClient(url, secret, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const existing = await listAllUsers(supabase);
const resetPassword = process.argv.includes("--reset-password");

console.log("Email\tAction\tTemporary password");

for (const person of people) {
  if (!person.email || !roles.has(person.role)) {
    console.error(`Skipping an invalid row: ${JSON.stringify(person)}`);
    process.exitCode = 1;
    continue;
  }

  const email = String(person.email).trim().toLowerCase();
  const appMetadata = {
    role: person.role,
    can_purchase: Boolean(person.canPurchase),
    can_update_order_status: Boolean(person.canUpdateOrderStatus),
    full_name: person.fullName ?? "",
  };
  const found = existing.find((user) => user.email?.toLowerCase() === email);

  if (!found) {
    const password = temporaryPassword();
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
      process.exitCode = 1;
      continue;
    }

    await upsertProfile(supabase, data.user.id, email, person);
    console.log(`${email}\tcreated\t${password}`);
    continue;
  }

  const password = resetPassword ? temporaryPassword() : null;
  const { error } = await supabase.auth.admin.updateUserById(found.id, {
    app_metadata: { ...found.app_metadata, ...appMetadata },
    ...(password ? { password } : {}),
  });

  if (error) {
    console.error(`Could not update ${email}: ${error.message}`);
    process.exitCode = 1;
    continue;
  }

  await upsertProfile(supabase, found.id, email, person);
  console.log(
    `${email}\tupdated access\t${password ?? "(password unchanged)"}`,
  );
}

console.log(
  "\nWrite the temporary passwords down somewhere private. Do not commit them.",
);

function temporaryPassword() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
  const bytes = randomBytes(18);
  // Prefix satisfies the local password rule: upper, lower, and a digit.
  let password = "Db1";
  for (const byte of bytes) {
    password += alphabet[byte % alphabet.length];
  }
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

async function upsertProfile(client, id, email, person) {
  const { error } = await client.from("profiles").upsert(
    {
      id,
      full_name: person.fullName ?? "",
      role: person.role,
      can_purchase: Boolean(person.canPurchase),
      can_update_order_status: Boolean(person.canUpdateOrderStatus),
    },
    { onConflict: "id" },
  );

  if (error) {
    console.error(
      `Account ${email} exists in Auth, but the profile row was not saved: ${error.message}`,
    );
    process.exitCode = 1;
    return;
  }

  // Email and phone are not on profiles. Coworkers can see a name, not this row.
  const { error: contactError } = await client.from("profile_contacts").upsert(
    {
      profile_id: id,
      email,
    },
    { onConflict: "profile_id" },
  );

  if (contactError) {
    console.error(
      `Account ${email} exists, but the contact row was not saved: ${contactError.message}`,
    );
    process.exitCode = 1;
  }
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
