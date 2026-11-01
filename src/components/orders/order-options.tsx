import {
  groupOrdersForSelect,
  orderChoiceLabel,
  type OrderChoice,
} from "@/lib/orders/label";

export function OrderSelectOptions({
  orders,
  blank,
}: {
  orders: readonly OrderChoice[];
  blank?: string;
}) {
  const groups = groupOrdersForSelect(orders);
  return (
    <>
      {blank ? <option value="">{blank}</option> : null}
      {groups.map((group) =>
        group.label ? (
          <optgroup key={group.label} label={group.label}>
            {group.orders.map((order) => (
              <option key={order.id} value={order.id}>
                {orderChoiceLabel(order)}
              </option>
            ))}
          </optgroup>
        ) : (
          group.orders.map((order) => (
            <option key={order.id} value={order.id}>
              {orderChoiceLabel(order)}
            </option>
          ))
        ),
      )}
    </>
  );
}
