import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { costingModule } from "@/modules/costing/module";

export const metadata = { title: "Costing" };

export default function CostingPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...costingModule} />
    </Suspense>
  );
}
