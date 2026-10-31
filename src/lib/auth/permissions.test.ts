import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  AREAS,
  ROLES,
  areasFor,
  canAccessArea,
  canRecordPurchase,
  canUpdateOrderStatus,
  canSeeCosts,
  canSeePrivateRecords,
  canSeeStaffPrivate,
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
  program_director: { role: "program_director", canPurchase: false },
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
      "styles",
      "suppliers",
      "purchases",
      "review",
      "people",
    ]);
  });

  it("lets every signed-in person open inventory and orders", () => {
    assert.deepEqual(allowed(profiles.employee), [
      "home",
      "production-orders",
      "tasks",
      "scheduling",
      "inventory",
      "styles",
      "suppliers",
    ]);
  });

  it("opens purchasing for the flag without making that person an owner", () => {
    assert.equal(canAccessArea(profiles.buyer, "purchasing"), true);
    assert.equal(canAccessArea(profiles.buyer, "costing"), false);
    assert.equal(canAccessArea(profiles.buyer, "payroll"), false);
    assert.equal(canAccessArea(profiles.employee, "purchasing"), false);
    assert.equal(canAccessArea(profiles.owner, "purchasing"), true);
    assert.equal(canSeeCosts(profiles.buyer), true);
    assert.equal(canSeeCosts(profiles.employee), false);
    assert.equal(canSeePrivateRecords(profiles.buyer), false);
    assert.equal(canSeePrivateRecords(profiles.production_manager), true);
    assert.equal(canRecordPurchase(profiles.buyer), true);
    assert.equal(canRecordPurchase(profiles.owner), true);
    assert.equal(canRecordPurchase(profiles.production_manager), false);
    assert.equal(canSeeStaffPrivate(profiles.owner), true);
    assert.equal(canSeeStaffPrivate(profiles.payroll_admin), true);
    assert.equal(canSeeStaffPrivate(profiles.production_manager), false);
    assert.equal(canSeeStaffPrivate(profiles.employee), false);
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

  it("lets a program director see orders and styles only", () => {
    const director: AccessProfile = {
      role: "program_director",
      canPurchase: false,
      canUpdateOrderStatus: true,
    };
    assert.deepEqual(allowed(director), [
      "home",
      "production-orders",
      "styles",
    ]);
    assert.equal(canSeeCosts(director), false);
    assert.equal(canSeePrivateRecords(director), false);
    assert.equal(canUpdateOrderStatus(director), false);
    assert.equal(canUpdateOrderStatus(profiles.employee), false);
    assert.equal(
      canUpdateOrderStatus({
        role: "employee",
        canPurchase: false,
        canUpdateOrderStatus: true,
      }),
      true,
    );
    assert.equal(canUpdateOrderStatus(profiles.production_manager), true);
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
