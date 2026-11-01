// How an order is named in pickers and short lists:
// "001 · Sing Sing Sing · Elite Company".
// A missing song or program is left out, so "015 · Wang Dang" stays readable.

export type OrderChoice = {
  id: number | string;
  orderNumber: string;
  song?: string | null;
  program?: string | null;
};

export function orderChoiceLabel(order: {
  orderNumber: string;
  song?: string | null;
  program?: string | null;
}): string {
  return [order.orderNumber, order.song, order.program]
    .map((part) => part?.trim() ?? "")
    .filter((part) => part.length > 0)
    .join(" · ");
}

export function compareOrderNumbers(left: string, right: string): number {
  return left.localeCompare(right, undefined, {
    numeric: true,
    sensitivity: "base",
  });
}

export function embeddedProgramName(
  value: { name: string } | { name: string }[] | null | undefined,
): string | null {
  if (!value) return null;
  const row = Array.isArray(value) ? value[0] : value;
  const name = row?.name?.trim();
  return name ? name : null;
}

export function toOrderChoice(row: {
  id: number;
  order_number: string;
  production_song?: string | null;
  programs?: { name: string } | { name: string }[] | null;
}): OrderChoice {
  return {
    id: row.id,
    orderNumber: row.order_number,
    song: row.production_song,
    program: embeddedProgramName(row.programs),
  };
}

export const ORDER_CHOICE_COLUMNS =
  "id, order_number, production_song, programs(name)";

// Named programs first, then orders with no program. Inside a group, order
// number. Grouping is skipped when nobody has a program.
export function groupOrdersForSelect<T extends OrderChoice>(
  orders: readonly T[],
): { label: string | null; orders: T[] }[] {
  const named = new Map<string, T[]>();
  const none: T[] = [];
  for (const order of orders) {
    const program = order.program?.trim();
    if (!program) {
      none.push(order);
      continue;
    }
    const list = named.get(program) ?? [];
    list.push(order);
    named.set(program, list);
  }
  const byNumber = (list: T[]) =>
    [...list].sort((left, right) =>
      compareOrderNumbers(left.orderNumber, right.orderNumber),
    );
  const groups: { label: string | null; orders: T[] }[] = [...named.entries()]
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([label, list]) => ({ label, orders: byNumber(list) }));
  if (none.length > 0) {
    groups.push({
      label: groups.length > 0 ? "No program" : null,
      orders: byNumber(none),
    });
  }
  return groups;
}
