import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { schedulingModule } from "@/modules/scheduling/module";

export const metadata = { title: "Schedule" };

export default function SchedulingPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...schedulingModule} />
    </Suspense>
  );
}
