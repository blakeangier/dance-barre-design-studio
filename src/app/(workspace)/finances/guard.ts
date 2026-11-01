import "server-only";

import { redirect } from "next/navigation";
import { gateArea } from "@/lib/auth/session";

export async function ownerGate() {
  const gate = await gateArea("finances");
  if (gate.ok) return gate;
  if (gate.reason === "denied") redirect("/");
  return gate;
}
