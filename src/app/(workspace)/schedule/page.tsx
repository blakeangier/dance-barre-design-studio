import { Suspense } from "react";
import { WeekScreen } from "@/app/(workspace)/schedule/week-screen";
import { LoadingLine } from "@/components/shell/loading-line";

export const metadata = { title: "Schedule" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function SchedulePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <WeekScreen mine={false} searchParams={props.searchParams} />
    </Suspense>
  );
}
