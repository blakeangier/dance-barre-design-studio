import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { payrollModule } from "@/modules/payroll/module";

export const metadata = { title: "Payroll" };

export default function PayrollPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...payrollModule} />
    </Suspense>
  );
}
