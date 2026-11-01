import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { designLibraryModule } from "@/modules/design-library/module";

export const metadata = { title: "Design library" };

export default function DesignLibraryPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...designLibraryModule} />
    </Suspense>
  );
}
