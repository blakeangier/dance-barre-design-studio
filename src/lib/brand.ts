import type { AppRole, AreaId } from "@/lib/auth/permissions";

// Accent only. Text stays on white or near-black so contrast stays AA.
// Pink, lime, teal, and orange are light enough for near-black text.
// Purple and red are not used behind small text.

export const AREA_ACCENT: Record<AreaId, string> = {
  home: "border-l-purple",
  "design-library": "border-l-pink",
  "production-orders": "border-l-orange",
  tasks: "border-l-teal",
  "staff-schedule": "border-l-lime",
  scheduling: "border-l-lime",
  payroll: "border-l-red",
  inventory: "border-l-lime",
  styles: "border-l-teal",
  suppliers: "border-l-orange",
  purchases: "border-l-pink",
  review: "border-l-red",
  purchasing: "border-l-orange",
  costing: "border-l-purple",
  "financial-reporting": "border-l-teal",
  finances: "border-l-purple",
  people: "border-l-pink",
};

export const ROLE_BADGE: Record<AppRole, string> = {
  owner: "bg-pink text-ink",
  production_manager: "bg-teal text-ink",
  payroll_admin: "bg-orange text-ink",
  employee: "bg-lime text-ink",
  program_director: "border border-ink bg-card text-ink",
};
