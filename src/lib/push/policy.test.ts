import assert from "node:assert/strict";
import { describe, it } from "node:test";
import type { AccessProfile } from "@/lib/auth/permissions";
import {
  canManagePushSettings,
  canSendAnnouncement,
  pushDelivery,
} from "./policy.ts";

const owner: AccessProfile = { role: "owner", canPurchase: false };
const production: AccessProfile = {
  role: "production_manager",
  canPurchase: false,
};
const employee: AccessProfile = { role: "employee", canPurchase: false };
const payroll: AccessProfile = { role: "payroll_admin", canPurchase: false };
const director: AccessProfile = {
  role: "program_director",
  canPurchase: false,
};

describe("push permissions", () => {
  it("lets only an owner turn notifications on", () => {
    assert.equal(canManagePushSettings(owner), true);
    assert.equal(canManagePushSettings(production), false);
    assert.equal(canManagePushSettings(employee), false);
    assert.equal(canManagePushSettings(payroll), false);
    assert.equal(canManagePushSettings(director), false);
  });

  it("lets an owner or the production manager send an announcement", () => {
    assert.equal(canSendAnnouncement(owner), true);
    assert.equal(canSendAnnouncement(production), true);
    assert.equal(canSendAnnouncement(employee), false);
    assert.equal(canSendAnnouncement(payroll), false);
    assert.equal(canSendAnnouncement(director), false);
  });
});

describe("push master switch", () => {
  it("sends nothing while the master switch is off", () => {
    assert.equal(
      pushDelivery({ masterOn: false, eventOn: true, userOn: true }),
      "master-off",
    );
    assert.equal(
      pushDelivery({ masterOn: false, eventOn: false, userOn: false }),
      "master-off",
    );
  });

  it("still respects the event and the person after the master switch is on", () => {
    assert.equal(
      pushDelivery({ masterOn: true, eventOn: false, userOn: true }),
      "event-off",
    );
    assert.equal(
      pushDelivery({ masterOn: true, eventOn: true, userOn: false }),
      "user-off",
    );
    assert.equal(
      pushDelivery({ masterOn: true, eventOn: true, userOn: true }),
      "send",
    );
  });
});
