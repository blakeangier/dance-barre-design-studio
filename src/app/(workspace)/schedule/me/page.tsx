import { Suspense } from "react";
import { WeekScreen } from "@/app/(workspace)/schedule/week-screen";
import { LoadingLine } from "@/components/shell/loading-line";

export const metadata = { title: "My week" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function MyWeekPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <WeekScreen mine={true} searchParams={props.searchParams} />
    </Suspense>
  );
}
