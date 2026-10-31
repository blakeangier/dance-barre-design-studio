// Who may open which area of the app.
// The same rules are enforced again in Postgres (see supabase/migrations).
// This file is plain data so it can be tested without a database.

export const ROLES = [
  "owner",
  "production_manager",
  "payroll_admin",
  "employee",
  "program_director",
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
  | "styles"
  | "suppliers"
  | "purchases"
  | "review"
  | "purchasing"
  | "costing"
  | "financial-reporting"
  | "finances"
  | "people";

export type AccessProfile = {
  role: AppRole;
  canPurchase: boolean;
  canUpdateOrderStatus?: boolean;
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
  program_director: "Program director",
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
    id: "styles",
    href: "/styles",
    label: "Styles",
    description: "Style records and development stages.",
  },
  {
    id: "suppliers",
    href: "/suppliers",
    label: "Suppliers",
    description: "Where fabric and trim are bought.",
  },
  {
    id: "purchases",
    href: "/purchases",
    label: "Purchases",
    description: "Purchase order lines.",
  },
  {
    id: "review",
    href: "/review",
    label: "Review",
    description: "Questions that still need an answer.",
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
    id: "finances",
    href: "/finances",
    label: "Finances",
    description: "Startup costs, running costs, payroll, and the card.",
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
      return role === "owner" || role === "production_manager";
    case "production-orders":
    case "styles":
      return true;
    case "inventory":
    case "suppliers":
      return role !== "program_director";
    case "tasks":
    case "scheduling":
      return (
        role === "owner" || role === "production_manager" || role === "employee"
      );
    case "payroll":
      return role === "owner" || role === "payroll_admin";
    case "purchases":
    case "review":
      return role === "owner" || role === "production_manager" || canPurchase;
    case "purchasing":
      // The switch (or being an owner) opens this area and allows recording a buy.
      // Reading supplier prices is wider: every production manager can read them
      // in the database, so Elaine can see prices because of her role. She also
      // has the switch, so she can buy.
      return role === "owner" || canPurchase;
    case "costing":
    case "financial-reporting":
    case "finances":
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

export function canEditInventory(profile: AccessProfile): boolean {
  return profile.role === "owner" || profile.role === "production_manager";
}

export function canSuperviseTasks(profile: AccessProfile): boolean {
  return canUpdateOrderStatus(profile);
}

export function canOpenTaskBoard(profile: AccessProfile): boolean {
  return profile.role === "owner" || profile.role === "production_manager";
}

export function canUpdateOrderStatus(profile: AccessProfile): boolean {
  if (profile.role === "program_director") return false;
  return (
    profile.role === "owner" ||
    profile.role === "production_manager" ||
    Boolean(profile.canUpdateOrderStatus)
  );
}

export function canSeeCosts(profile: AccessProfile): boolean {
  return canEditInventory(profile) || profile.canPurchase;
}

export function canSeePrivateRecords(profile: AccessProfile): boolean {
  return canEditInventory(profile);
}

export function canRecordPurchase(profile: AccessProfile): boolean {
  return profile.role === "owner" || profile.canPurchase;
}

export function canSeeStaffPrivate(profile: AccessProfile): boolean {
  return profile.role === "owner" || profile.role === "payroll_admin";
}

export function canEditSchedule(profile: AccessProfile): boolean {
  return profile.role === "owner" || profile.role === "production_manager";
}

export function canProcessPayroll(profile: AccessProfile): boolean {
  return profile.role === "owner" || profile.role === "payroll_admin";
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
