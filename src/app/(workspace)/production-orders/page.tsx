import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { productionOrdersModule } from "@/modules/production/module";

export const metadata = { title: "Production orders" };

export default function ProductionOrdersPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...productionOrdersModule} />
    </Suspense>
  );
}
