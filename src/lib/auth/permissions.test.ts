import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  AREAS,
  ROLES,
  areasFor,
  canAccessArea,
  type AccessProfile,
  type AppRole,
  type AreaId,
} from "./permissions.ts";
import { safeNextPath } from "./redirect.ts";

const profiles: Record<AppRole | "buyer", AccessProfile> = {
  owner: { role: "owner", canPurchase: false },
  production_manager: { role: "production_manager", canPurchase: false },
  payroll_admin: { role: "payroll_admin", canPurchase: false },
  employee: { role: "employee", canPurchase: false },
  buyer: { role: "employee", canPurchase: true },
};

function allowed(profile: AccessProfile): AreaId[] {
  return areasFor(profile).map((area) => area.id);
}

describe("role areas", () => {
  it("gives every signed-in role a home", () => {
    for (const role of ROLES) {
      assert.equal(canAccessArea({ role, canPurchase: false }, "home"), true);
    }
  });

  it("keeps pay, costs, and company reports with the owner", () => {
    assert.deepEqual(
      allowed(profiles.owner),
      AREAS.map((area) => area.id),
    );
    for (const area of ["payroll", "costing", "financial-reporting"] as const) {
      assert.equal(canAccessArea(profiles.production_manager, area), false);
      assert.equal(canAccessArea(profiles.employee, area), false);
    }
    assert.equal(canAccessArea(profiles.payroll_admin, "costing"), false);
    assert.equal(
      canAccessArea(profiles.payroll_admin, "financial-reporting"),
      false,
    );
    assert.equal(canAccessArea(profiles.payroll_admin, "payroll"), true);
  });

  it("lets production run the floor without payroll, costing, or purchasing", () => {
    assert.deepEqual(allowed(profiles.production_manager), [
      "home",
      "design-library",
      "production-orders",
      "tasks",
      "scheduling",
      "inventory",
      "people",
    ]);
  });

  it("gives employees their own phone areas only", () => {
    assert.deepEqual(allowed(profiles.employee), [
      "home",
      "tasks",
      "scheduling",
    ]);
  });

  it("opens purchasing for the flag without making that person an owner", () => {
    assert.equal(canAccessArea(profiles.buyer, "purchasing"), true);
    assert.equal(canAccessArea(profiles.buyer, "costing"), false);
    assert.equal(canAccessArea(profiles.buyer, "payroll"), false);
    assert.equal(canAccessArea(profiles.employee, "purchasing"), false);
    assert.equal(canAccessArea(profiles.owner, "purchasing"), true);
  });

  it("lets a production manager with the purchasing switch open Purchasing", () => {
    const elaine = {
      role: "production_manager" as const,
      canPurchase: true,
    };
    assert.equal(canAccessArea(elaine, "purchasing"), true);
    assert.equal(canAccessArea(elaine, "costing"), false);
    assert.equal(
      canAccessArea(profiles.production_manager, "purchasing"),
      false,
    );
  });
});

describe("safeNextPath", () => {
  it("keeps local paths and drops off-site targets", () => {
    assert.equal(safeNextPath("/payroll"), "/payroll");
    assert.equal(safeNextPath("https://example.com"), "/");
    assert.equal(safeNextPath("//example.com"), "/");
    assert.equal(safeNextPath("/login"), "/");
    assert.equal(safeNextPath(undefined), "/");
  });
});
