import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { inventoryModule } from "@/modules/inventory/module";

export const metadata = { title: "Inventory" };

export default function InventoryPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...inventoryModule} />
    </Suspense>
  );
}
