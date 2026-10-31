// Who may open which area of the app.
// The same rules are enforced again in Postgres (see supabase/migrations).
// This file is plain data so it can be tested without a database.

export const ROLES = [
  "owner",
  "production_manager",
  "payroll_admin",
  "employee",
] as const;

export type AppRole = (typeof ROLES)[number];

export type AreaId =
  | "home"
  | "design-library"
  | "production-orders"
  | "tasks"
  | "scheduling"
  | "payroll"
  | "inventory"
  | "purchasing"
  | "costing"
  | "financial-reporting"
  | "people";

export type AccessProfile = {
  role: AppRole;
  canPurchase: boolean;
};

export type NavItem = {
  id: AreaId;
  href: string;
  label: string;
  description: string;
};

export const ROLE_LABELS: Record<AppRole, string> = {
  owner: "Owner",
  production_manager: "Production manager",
  payroll_admin: "Payroll",
  employee: "Employee",
};

export const AREAS: readonly NavItem[] = [
  {
    id: "home",
    href: "/",
    label: "Home",
    description: "Your starting point for the day.",
  },
  {
    id: "design-library",
    href: "/design-library",
    label: "Designs",
    description: "Costume designs and reference images.",
  },
  {
    id: "production-orders",
    href: "/production-orders",
    label: "Orders",
    description: "Production orders moving through the shop.",
  },
  {
    id: "tasks",
    href: "/tasks",
    label: "Tasks",
    description: "Work assigned on the floor.",
  },
  {
    id: "scheduling",
    href: "/scheduling",
    label: "Schedule",
    description: "Who is in, and when.",
  },
  {
    id: "payroll",
    href: "/payroll",
    label: "Payroll",
    description: "Timesheets, Ontario pay rules, and ADP export.",
  },
  {
    id: "inventory",
    href: "/inventory",
    label: "Inventory",
    description: "Fabrics and materials on hand.",
  },
  {
    id: "purchasing",
    href: "/purchasing",
    label: "Purchasing",
    description: "Suppliers and externally sourced costumes.",
  },
  {
    id: "costing",
    href: "/costing",
    label: "Costing",
    description: "What a costume costs to make.",
  },
  {
    id: "financial-reporting",
    href: "/financial-reporting",
    label: "Reports",
    description: "Results for both companies, in CAD and USD.",
  },
  {
    id: "people",
    href: "/people",
    label: "People",
    description: "Who can sign in, and as what.",
  },
];

export function isAppRole(value: string): value is AppRole {
  return (ROLES as readonly string[]).includes(value);
}

export function canAccessArea(profile: AccessProfile, area: AreaId): boolean {
  const { role, canPurchase } = profile;

  switch (area) {
    case "home":
      return true;
    case "design-library":
    case "production-orders":
    case "inventory":
      return role === "owner" || role === "production_manager";
    case "tasks":
    case "scheduling":
      return (
        role === "owner" || role === "production_manager" || role === "employee"
      );
    case "payroll":
      return role === "owner" || role === "payroll_admin";
    case "purchasing":
      // Owners see purchasing even without the extra flag.
      // The flag lets a non-owner buyer in later.
      return role === "owner" || canPurchase;
    case "costing":
    case "financial-reporting":
      return role === "owner";
    case "people":
      return (
        role === "owner" ||
        role === "production_manager" ||
        role === "payroll_admin"
      );
    default: {
      const neverArea: never = area;
      return neverArea;
    }
  }
}

export function areasFor(profile: AccessProfile): NavItem[] {
  return AREAS.filter((area) => canAccessArea(profile, area.id));
}

export function areaById(area: AreaId): NavItem {
  const match = AREAS.find((item) => item.id === area);
  if (!match) {
    throw new Error(`Unknown area: ${area}`);
  }
  return match;
}
