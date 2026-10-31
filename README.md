# Dance Barre Design Studio

Manufacturing workspace for Dance Barre Design Studio Inc., the costume shop in Windsor, Ontario. The foundation (sign-in, roles, and locked tables) is in place. This branch adds inventory, costume orders, styles, suppliers, purchases, and Elaine's review list, loaded from the 2026-10-30 tracker export. Later phases add designs, tasks, scheduling, timesheets and payroll, costing, reports, and a link to the parent Dance Barre system.

The shop is small (about eight people on the floor, about two thousand costumes a year). The app is meant to live on a phone home screen as well as a computer.

## What is in this version

- Sign-in with email and password. A magic-link option is on the same page for later, once email sending is connected. Any signed-in person can change their own password from My account in the header. The form asks for the current password again. There is no reset email yet.
- No public sign-up. An owner creates each account.
- Four roles: owner, production manager, payroll, and employee. The menu only shows areas that role may open. The database enforces the same split, so hiding a button is not the lock.
- Purchasing is a switch on a person, not a fifth role. Lindsay (an owner) and Elaine (the production manager) both buy outside costumes and dancewear, so they have the switch.
- Two companies: Dance Barre Design Studio Inc. and Dance Barre Studio. Money can be recorded in CAD or USD. Both companies are **CAD for now**. Blake confirmed that in October 2026. It can be changed later if either company starts keeping its books in USD. The app does not convert currencies.
- Pay rates, supplier prices, and contact details (email and phone) have their own tables. Pay rates stay empty. Material costs and purchase prices are loaded by the inventory import, not by the migration. A database can hide rows from someone, but it cannot hide one column inside a row they are allowed to see. Coworkers can see a name and a role. They cannot see a phone number, an email address, or a pay rate.
- An audit log records inserts, updates, and deletes on the core tables. Nobody using the app can edit or delete history.
- The app can be installed on a phone home screen.

Inventory, Orders, Styles, Suppliers, Purchases, and Review show the tracker. Owners and the production manager can create and edit those records. There is no delete button: archive hides a record, and cancelled is a status on an order. Employees see the lists and can log fabric they used. The other areas still say **Coming in a later phase**.

## How the pieces connect

```text
GitHub (this repo)
    │
    ├── Vercel runs the Next.js app
    │
    └── Supabase holds the database, logins, and file storage later
            Postgres tables + row-level security
            Auth (email)
```

The browser only receives the Supabase project URL and the publishable key. The secret key stays on the server (and in the setup script). It is never given a `NEXT_PUBLIC_` name.

Dev and production must be different Supabase projects and different sets of keys. The dev project already exists:

|             |                                          |
| ----------- | ---------------------------------------- |
| Name        | design-studio-dev                        |
| Project ref | `peikzgupvcgswyxcfibr`                   |
| Region      | Canada (ca-central-1)                    |
| URL         | https://peikzgupvcgswyxcfibr.supabase.co |

The inventory SQL in this branch is for that dev project only, after you review it. Do not run it on a future production project, and do not point the dev app at production.

Vercel project `dance-barre-design-studio` on Blake's team is connected to this repo. Preview deployments use the **dev** Supabase keys. Leave the Production environment empty until a separate production database exists. Move to the Pro team before the shop goes live.

The foundation migration is already applied on the dev project, and the four accounts (Blake, Lindsay, Elaine, and Rebecca) are created there. New preview builds of this pull request talk to that same dev database. They do not create a separate database of their own.

## What you can open, by role

| Area       | Owner | Production manager | Payroll | Employee | Purchasing switch |
| ---------- | ----- | ------------------ | ------- | -------- | ----------------- |
| Home       | yes   | yes                | yes     | yes      |                   |
| Designs    | yes   | yes                |         |          |                   |
| Orders     | yes   | yes                | yes     | yes      |                   |
| Styles     | yes   | yes                | yes     | yes      |                   |
| Tasks      | yes   | yes                |         | yes      |                   |
| Schedule   | yes   | yes                |         | yes      |                   |
| Payroll    | yes   |                    | yes     |          |                   |
| Inventory  | yes   | yes                | yes     | yes      |                   |
| Suppliers  | yes   | yes                | yes     | yes      |                   |
| Purchases  | yes   | yes                |         |          | yes               |
| Review     | yes   | yes                |         |          | yes               |
| Purchasing | yes   | with the switch    |         |          | yes               |
| Costing    | yes   |                    |         |          |                   |
| Reports    | yes   |                    |         |          |                   |
| People     | yes   | yes                | yes     |          |                   |

Elaine is a production manager with the purchasing switch, so she can open Purchasing. A production manager without that switch does not see the Purchasing area. An employee with the switch can open Purchasing too. They still cannot open payroll, costs, or reports.

Seeing a supplier price is separate from being allowed to buy. Every production manager can read supplier prices, so Elaine can see them because of her role even if the switch were turned off. Anyone with the purchasing switch can read unit costs, BOM costs, and supplier prices too. The switch is what lets her record a purchase. That split is deliberate: the next production manager should be able to plan from prices without automatically being allowed to buy.

Supplier phone and email, and client emails or budgets on an order, are narrower. Only an owner or a production manager can read those. A purchasing switch on its own does not open them. Employees can read fabrics, stock, and orders, and they can log fabric they used. They cannot edit a material or record a receipt. The audit log follows that split: purchasing can see price and cost history, and only owners and production managers can see history for supplier contacts and order emails or budgets.

### What the database allows

| Table                                | Who can read                                                                                                                                               | Who can write                                                                 |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Companies (`business_entities`)      | any signed-in person                                                                                                                                       | nobody through the app (change currency in the Supabase SQL editor if needed) |
| People (`profiles`)                  | every signed-in person can see coworker names, roles, and whether an account is on                                                                         | you may change your own name; you cannot change your role                     |
| Contact details (`profile_contacts`) | your own email and phone; owners, production managers, and payroll can see everyone's                                                                      | you may change your own phone; email follows the login                        |
| Pay rates (`employee_compensation`)  | owner, payroll                                                                                                                                             | owner, payroll may add a row; nobody may edit or delete one                   |
| Supplier prices (`supplier_prices`)  | owner, every production manager, and anyone with the purchasing switch                                                                                     | owner and the purchasing switch may add a row; nobody may edit or delete one  |
| Internal costs (`cost_rates`)        | owner                                                                                                                                                      | owner, add only                                                               |
| History (`audit_log`)                | owner sees all; payroll sees pay history; production managers and purchasing see supplier-price history; payroll and production see contact-detail history | nobody can update or delete, including the database owner                     |

Signed-out visitors cannot read any of these tables.

Role changes: an owner uses the People screen. That screen checks they are an owner, then uses the secret key on the server. A normal login cannot update the role column. A database trigger also refuses to let someone change their own role.

## Run it on your computer

You need Node.js 22, Docker (for the local database), and Git.

```bash
npm install
cp .env.example .env.local
```

For a fully local database, start Supabase (first run downloads a few containers):

```bash
npx supabase start
```

The command prints a URL and keys. Put these in `.env.local`:

- `NEXT_PUBLIC_SUPABASE_URL` = API URL
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` = publishable (or anon) key
- `SUPABASE_SECRET_KEY` = secret key (this stays out of the browser)

Then:

```bash
npm run dev
```

Open http://localhost:3000. You will land on the sign-in page. Create the first accounts before you can get in (next section).

Local email does not leave your machine. If you use "Email me a link" against the local stack, open the mailbox viewer from `npx supabase status` (Mailpit, usually http://127.0.0.1:54324).

### Use the hosted dev project instead of local Docker

Do this only after the migrations in this pull request have been applied to `design-studio-dev`.

```bash
npx supabase login
npx supabase link --project-ref peikzgupvcgswyxcfibr
npx supabase db push
```

`db push` updates the hosted dev database. It does not run `supabase/seed.sql`. The two companies are inserted by the migration itself.

Copy the project URL and the publishable key from the Supabase dashboard (Project Settings → API Keys) into `.env.local`. Copy the secret key into `SUPABASE_SECRET_KEY`. Do not commit that file.

In the hosted dashboard, turn off public sign-up as well. The local config already has it off. The hosted project has its own switch:

Authentication → Sign In / Providers → Email → disable new sign-ups.

Set the site URL to the address where the app is opened, and add `https://your-dev-url/auth/callback` to the redirect allow-list. Until a Vercel URL exists, `http://localhost:3000` is enough.

## Create the first accounts

Passwords are not in this repository. The script makes a temporary password, prints it once, and confirms the email so they can sign in before email sending exists.

```bash
npm run create-users
```

It reads `scripts/initial-users.json`:

| Name            | Email                                 | Role               | Purchasing |
| --------------- | ------------------------------------- | ------------------ | ---------- |
| Blake Angier    | blakeangier@gmail.com                 | owner              | no         |
| Lindsay Angier  | dancebarredirectors@dancebarre.ca     | owner              | yes        |
| Elaine Chatwood | designstudio.dancebarre@gmail.com     | production manager | yes        |
| Rebecca Hannam  | dancebarrestudiomanager@dancebarre.ca | payroll            | no         |

Write the printed passwords down somewhere private, share each one with that person, and ask them to keep it safe. Running the script again updates roles and does not reset passwords. Add `--reset-password` only when you mean to replace a password:

```bash
node scripts/create-users.mjs --reset-password
```

Employees are not created yet. When you are ready, add them to `scripts/initial-users.json` with `"role": "employee"` and run the script again. Do not put passwords in that file.

### If you would rather click in the dashboard

1. Authentication → Users → Add user. Turn on "Auto Confirm" so they can sign in without an email.
2. Then, in the SQL editor, set the role. Example for Blake:

```sql
update auth.users
set raw_app_meta_data =
  raw_app_meta_data
  || '{"role":"owner","can_purchase":false,"full_name":"Blake Angier"}'::jsonb
where email = 'blakeangier@gmail.com';
```

Use `"role":"owner"` and `"can_purchase":true` for Lindsay. For Elaine use `"role":"production_manager"` and `"can_purchase":true`. For Rebecca use `"payroll_admin"` and `"can_purchase":false`. A trigger copies that onto the profile. Do not put the role in user metadata. People can edit user metadata themselves; they cannot edit app metadata.

## Phone home screen

The app includes a web manifest and a small service worker. On an iPhone: open the app in Safari, Share, Add to Home Screen. On Android: Chrome will offer Install, or use the browser menu. The service worker does not cache pages, so one person's screen cannot be saved and shown to someone else.

Icons are in `public/icons`. Regenerate them with `npm run icons` if you want to change the mark.

## Checks

```bash
npm run lint
npm run typecheck
npm run test:unit
npm run test:db
npm run build
```

`test:unit` checks the menu rules in code. `test:db` needs `npx supabase start` first. It proves, in Postgres, that an employee cannot read pay rows, payroll can, a person cannot change their own role, and the audit log cannot be edited or deleted.

`scripts/local-auth-stub.sql` is only for running that same test file on a plain Postgres when Docker is not available. Do not run it on the hosted project.

GitHub Actions runs the same checks on pull requests. The database job starts a local Supabase stack on the runner.

## Folder map

```text
src/app/                  pages (App Router)
src/components/shell/     menu, sign-in chrome
src/lib/auth/             who may open what
src/lib/supabase/         browser, server, and secret-key clients
src/modules/              one folder per future area
supabase/migrations/      database changes, in order
supabase/tests/           role tests
scripts/create-users.mjs  first accounts
```

`src/lib/supabase/admin.ts` is the only place the secret key is used by the app, and only after an owner check. The file is marked server-only so the browser build cannot include it.

## Inventory import (dev database only)

The tracker export from 2026-10-30 is in `data/plm-export-2026-10-30`. The SQL that loads it is generated and already in `scripts/import`. Do not run it against production.

After the inventory migration is applied, run these files in the Supabase SQL editor, in this order. Each file stands alone. Running them again updates the same rows.

1. `scripts/import/01_suppliers.sql`
2. `scripts/import/02_materials_part01.sql`
3. `scripts/import/02_materials_part02.sql`
4. `scripts/import/02_materials_part03.sql`
5. `scripts/import/03_orders.sql`
6. `scripts/import/04_styles_part01.sql` through `04_styles_part06.sql`
7. `scripts/import/05_transactions.sql`
8. `scripts/import/06_purchases.sql`
9. `scripts/import/07_sizes.sql`
10. `scripts/import/08_bom.sql`
11. `scripts/import/09_fittings.sql`
12. `scripts/import/10_reviews.sql`

Expected rows: 5 suppliers, 91 materials, 40 orders, 108 styles, 1,188 style stages, 129 stock transactions, 3 purchase orders, 44 purchase lines, 25 size quantities, 16 BOM lines (8 of them unlinked), 8 fittings, 8 fitting checks, 12 production gates, and 87 review items. The low-stock threshold is 2 m. Counts are also in `scripts/import/EXPECTED_COUNTS.txt`.

Dashboard, Tasks, Tasks Done, Fabric Tags, and the empty form tabs are not loaded. To regenerate the SQL from the CSVs: `node scripts/plm/build-plm-import.mjs`.

## Checklist for Blake

1. Read this pull request and the migration file `supabase/migrations/*_foundation.sql`.
2. Install Docker and Node 22 if you want a database on your own machine. `npx supabase start`, then fill `.env.local` from `npx supabase status`.
3. Done. The foundation migration is applied on dev project `peikzgupvcgswyxcfibr`. Later migrations still go on with `npx supabase db push` after you review them.
4. In the hosted dev project, turn off new sign-ups and set the site URL and `/auth/callback` redirect.
5. Put the dev URL and publishable key in `.env.local`. Put the secret key in `SUPABASE_SECRET_KEY`. Never commit them. Never add the secret to a variable whose name starts with `NEXT_PUBLIC_`.
6. Done. The four accounts exist on the dev project. If someone needs a new temporary password, run `node scripts/create-users.mjs --reset-password` and share it in person, not in git.
7. Done. Vercel project `dance-barre-design-studio` (team blake) is connected. Do not deploy a production database yet.
8. Preview deployments use the dev Supabase keys. Keep Production empty until a separate production Supabase project exists.
9. Both companies are CAD for now. If that changes later, update `home_currency` on the company row. The app does not convert currencies.
10. Before go-live: create a second Supabase project for production, use the Vercel Pro team, and connect email (Resend) so magic links and password resets can be sent. The `RESEND_API_KEY` name is reserved and unused for now.

## Assumptions

- Sign-in is email plus password so the shop can get in before email delivery exists. Magic links are on the page and stay quiet until SMTP is connected.
- Both companies are CAD for now. Blake confirmed that in October 2026. Either company can be switched to USD later by changing `home_currency`.
- Employees can see coworker names and roles, for tasks and the schedule. They cannot see coworker email, phone, or pay.
- Every production manager can read supplier prices. Recording a purchase still needs the purchasing switch. Elaine has that switch.
- Pay, supplier prices, and costs are append-only: a correction is a new row, not an edit.
- Ontario payroll rules and ADP's file layout are not in this version. Nothing here invents a rate, a deduction, or a supplier.
- There is no sample business data. Test rows that mention SAMPLE exist only inside a database test, and they are rolled back.

## Open questions

- What does the ADP export need to look like, and which Ontario rules apply (vacation pay, public holidays, overtime)? Those will be specified before that phase, not guessed.
- When should the production Supabase project be created, and what domain will the app use?
- Who else, besides Lindsay and Elaine, should have the purchasing switch?
