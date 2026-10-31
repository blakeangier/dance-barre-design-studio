import { Suspense } from "react";
import { ProtectedModule } from "@/components/shell/protected-module";
import { LoadingLine } from "@/components/shell/loading-line";
import { tasksModule } from "@/modules/tasks/module";

export const metadata = { title: "Tasks" };

export default function TasksPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProtectedModule {...tasksModule} />
    </Suspense>
  );
}
