import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { Shell } from "@/components/shell/shell";

// The signed-in shell reads cookies, so it sits behind Suspense. Next.js can
// then send the rest of the page shell without waiting on the login check.
export default function WorkspaceLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <Suspense
      fallback={
        <main className="mx-auto max-w-3xl px-4 py-8">
          <LoadingLine />
        </main>
      }
    >
      <Shell>{children}</Shell>
    </Suspense>
  );
}
