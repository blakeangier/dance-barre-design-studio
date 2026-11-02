import type { AccessProfile } from "@/lib/auth/permissions";

export const PUSH_EVENTS = [
  "shift_changes",
  "task_assigned",
  "alteration_due",
  "announcements",
] as const;

export type PushEvent = (typeof PUSH_EVENTS)[number];

export type PushDelivery = "send" | "master-off" | "event-off" | "user-off";

export function canManagePushSettings(profile: AccessProfile): boolean {
  return profile.role === "owner";
}

export function canSendAnnouncement(profile: AccessProfile): boolean {
  return profile.role === "owner" || profile.role === "production_manager";
}

// The master switch wins. Event and personal switches are not consulted
// until an owner has turned notifications on.
export function pushDelivery(input: {
  masterOn: boolean;
  eventOn: boolean;
  userOn: boolean;
}): PushDelivery {
  if (!input.masterOn) return "master-off";
  if (!input.eventOn) return "event-off";
  if (!input.userOn) return "user-off";
  return "send";
}

export function isPushEvent(value: string): value is PushEvent {
  return (PUSH_EVENTS as readonly string[]).includes(value);
}
