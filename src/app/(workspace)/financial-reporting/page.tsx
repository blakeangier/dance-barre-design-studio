import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { financialReportingModule } from "@/modules/finance/module";

export const metadata = { title: "Reports" };

export default function FinancialReportingPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...financialReportingModule} />
    </Suspense>
  );
}
