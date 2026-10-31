import type { AreaId } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { ComingSoon } from "@/components/shell/coming-soon";
import { NoAccess } from "@/components/shell/no-access";

// Renders the placeholder only after the role check. The page does not pass
// this content in as children, so a blocked role never receives it.
export async function ProtectedModule({
  area,
  title,
  summary,
}: {
  area: AreaId;
  title: string;
  summary: string;
}) {
  const gate = await gateArea(area);

  if (!gate.ok) return <NoAccess reason={gate.reason} />;

  return <ComingSoon title={title} summary={summary} />;
}
