import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { purchasingModule } from "@/modules/purchasing/module";

export const metadata = { title: "Purchasing" };

export default function PurchasingPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...purchasingModule} />
    </Suspense>
  );
}
