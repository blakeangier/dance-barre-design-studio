"use client";

import { useId, useMemo, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { logFabricUse } from "@/app/(workspace)/inventory/use-actions";
import { fieldClass } from "@/components/records/fields";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { compressPhotoFile } from "@/lib/inventory/compress-photo";
import { metres } from "@/lib/inventory/format";
import {
  PHOTO_MAX_BYTES,
  PHOTO_MAX_EDGE,
  PHOTO_THUMB_EDGE,
  thumbnailPath,
} from "@/lib/inventory/photos";
import {
  suggestMaterials,
  type InventoryMaterial,
} from "@/lib/inventory/search";
import {
  orderFabricPosition,
  parseUsageAmount,
  planFabricUse,
  remainingReserved,
  type FabricLineOption,
  type FabricOrderOption,
  type FabricStyleOption,
  type ReservationSlice,
  type UsagePurpose,
  type UsageUnit,
} from "@/lib/inventory/usage";
import { createClient } from "@/lib/supabase/client";

export function LogUseForm({
  materials,
  orders,
  styles,
  lines,
  reservations,
  initialMaterialId,
  today,
  userId,
}: {
  materials: InventoryMaterial[];
  orders: FabricOrderOption[];
  styles: FabricStyleOption[];
  lines: FabricLineOption[];
  reservations: ReservationSlice[];
  initialMaterialId: number | null;
  today: string;
  userId: string;
}) {
  const router = useRouter();
  const listId = useId();
  const initial =
    materials.find((item) => item.id === initialMaterialId) ?? null;
  const [query, setQuery] = useState(initial?.materialCode ?? "");
  const [selectedId, setSelectedId] = useState<number | null>(
    initial?.id ?? null,
  );
  const [open, setOpen] = useState(false);
  const [unit, setUnit] = useState<UsageUnit>("m");
  const [amount, setAmount] = useState("");
  const [waste, setWaste] = useState("");
  const [purpose, setPurpose] = useState<UsagePurpose>("production");
  const [orderId, setOrderId] = useState("");
  const [styleId, setStyleId] = useState("");
  const [lineId, setLineId] = useState("");
  const [note, setNote] = useState("");
  const [occurredOn, setOccurredOn] = useState(today);
  const [file, setFile] = useState<File | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const selected = materials.find((item) => item.id === selectedId) ?? null;
  const suggestions = useMemo(
    () =>
      selected
        ? []
        : suggestMaterials(materials, {
            query,
            type: "",
            lowOnly: false,
            reviewOnly: false,
          }),
    [materials, query, selected],
  );
  const useM = parseUsageAmount(amount, unit);
  const wasteM = waste.trim() ? parseUsageAmount(waste, unit) : 0;
  const orderNumber = Number(orderId);
  const position =
    selected && purpose === "production" && orderNumber > 0
      ? orderFabricPosition(reservations, selected.id, orderNumber)
      : null;
  const plan =
    selected && useM !== null && wasteM !== null
      ? planFabricUse({
          onHandM: selected.onHandM,
          reservedM: selected.reservedM,
          purpose,
          position,
          useM,
          wasteM: wasteM ?? 0,
        })
      : null;
  const orderStyles = styles.filter((style) => style.orderId === orderNumber);
  const orderLines = lines.filter(
    (line) =>
      line.orderId === orderNumber &&
      (line.materialId === null || line.materialId === selected?.id),
  );

  function chooseUnit(next: UsageUnit) {
    if (next === unit) return;
    setAmount((current) => convertField(current, unit, next));
    setWaste((current) => convertField(current, unit, next));
    setUnit(next);
  }

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!selected) {
      setMessage("Choose the fabric.");
      return;
    }
    if (useM === null) {
      setMessage("Enter the metres used. Use a number greater than zero.");
      return;
    }
    if (waste.trim() && wasteM === null) {
      setMessage("Enter the waste in metres, or leave it blank.");
      return;
    }
    if (purpose === "sample" && !styleId) {
      setMessage("Choose the style.");
      return;
    }
    if (purpose === "production" && !orderId) {
      setMessage("Choose the production order.");
      return;
    }
    setBusy(true);
    setMessage(null);
    try {
      let photoPath = "";
      if (file) {
        const full = await compressPhotoFile(
          file,
          PHOTO_MAX_EDGE,
          PHOTO_MAX_BYTES,
        );
        const thumb = await compressPhotoFile(
          file,
          PHOTO_THUMB_EDGE,
          120 * 1024,
        );
        const id = crypto.randomUUID();
        const ext = full.type === "image/webp" ? "webp" : "jpg";
        photoPath = `usage/${userId}/${id}.${ext}`;
        const bucket = createClient().storage.from("material-photos");
        const uploaded = await bucket.upload(photoPath, full, {
          contentType: full.type,
          upsert: false,
        });
        if (uploaded.error) throw new Error("upload");
        const thumbUploaded = await bucket.upload(
          thumbnailPath(photoPath),
          thumb,
          {
            contentType: thumb.type,
            upsert: false,
          },
        );
        if (thumbUploaded.error) throw new Error("upload");
      }
      const body = new FormData();
      body.set("materialId", String(selected.id));
      body.set("amount", amount);
      body.set("unit", unit);
      body.set("waste", waste);
      body.set("purpose", purpose);
      body.set("orderId", purpose === "production" ? orderId : "");
      body.set("styleId", styleId);
      body.set("bomLineId", purpose === "production" ? lineId : "");
      body.set("note", note);
      body.set("occurredOn", occurredOn);
      if (photoPath) body.set("photoPath", photoPath);
      const result = await logFabricUse(body);
      if (!result.ok) {
        setMessage(result.message);
        return;
      }
      router.push(`/inventory/use?logged=${result.groupId}`);
    } catch {
      setMessage(
        "That photo did not upload. Try another picture, or log the use without one.",
      );
    } finally {
      setBusy(false);
    }
  }

  return (
    <form
      onSubmit={onSubmit}
      className="mx-auto flex w-full max-w-lg flex-col gap-4"
    >
      <div>
        <h1 className="font-serif text-3xl text-ink">Log material use</h1>
        <p className="mt-2 text-sm text-muted">
          Subtract the metres you used on a sample or a production order.
        </p>
      </div>

      <div className="flex flex-col gap-2">
        <label className="text-sm font-medium" htmlFor="fabric-search">
          Fabric
        </label>
        {selected ? (
          <div className="flex items-start gap-3 rounded-2xl border border-line bg-card p-3">
            <PhotoThumb
              thumbUrl={selected.photoThumbUrl ?? null}
              fullUrl={selected.photoFullUrl ?? null}
              label={selected.materialCode}
            />
            <div className="min-w-0">
              <p className="font-medium text-ink">{selected.materialCode}</p>
              <p className="text-sm text-muted">
                {[selected.fabricName, selected.colourName]
                  .filter(Boolean)
                  .join(" · ") || "No name"}
              </p>
              <p className="text-sm text-ink">
                Available {metres(selected.availableM)}
              </p>
              <button
                type="button"
                className="mt-1 min-h-11 text-sm text-ink"
                onClick={() => {
                  setSelectedId(null);
                  setQuery("");
                  setOpen(true);
                }}
              >
                Change fabric
              </button>
            </div>
          </div>
        ) : (
          <>
            <input
              id="fabric-search"
              role="combobox"
              aria-expanded={open && suggestions.length > 0}
              aria-controls={listId}
              aria-autocomplete="list"
              value={query}
              onChange={(event) => {
                setQuery(event.target.value);
                setSelectedId(null);
                setOpen(true);
              }}
              onFocus={() => setOpen(true)}
              autoCapitalize="off"
              autoCorrect="off"
              autoComplete="off"
              placeholder="Search by number or name"
              className={fieldClass}
            />
            {open && query.trim() ? (
              suggestions.length > 0 ? (
                <ul
                  id={listId}
                  role="listbox"
                  className="max-h-[min(20rem,40dvh)] overflow-y-auto rounded-xl border border-line"
                >
                  {suggestions.map((item) => (
                    <li
                      key={item.id}
                      className="flex items-center gap-3 px-3 py-2"
                    >
                      <PhotoThumb
                        thumbUrl={item.photoThumbUrl ?? null}
                        fullUrl={item.photoFullUrl ?? null}
                        label={item.materialCode}
                      />
                      <button
                        type="button"
                        className="min-h-16 min-w-0 flex-1 py-1 text-left"
                        onClick={() => {
                          setSelectedId(item.id);
                          setQuery(item.materialCode);
                          setOpen(false);
                          setLineId("");
                        }}
                      >
                        <span className="block font-medium text-ink">
                          {item.materialCode}
                        </span>
                        <span className="block text-sm text-muted">
                          {[item.fabricName, item.colourName]
                            .filter(Boolean)
                            .join(" · ") || "No name"}
                        </span>
                        <span className="block text-sm text-ink">
                          Available {metres(item.availableM)}
                        </span>
                      </button>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-sm text-muted">No matching fabrics.</p>
              )
            ) : null}
          </>
        )}
      </div>

      <div className="flex flex-col gap-2">
        <label className="text-sm font-medium" htmlFor="amount">
          Amount used
        </label>
        <div className="grid grid-cols-2 gap-2">
          <UnitButton
            current={unit}
            value="m"
            onPick={chooseUnit}
            label="Metres"
          />
          <UnitButton
            current={unit}
            value="cm"
            onPick={chooseUnit}
            label="Centimetres"
          />
        </div>
        <input
          id="amount"
          inputMode="decimal"
          step={unit === "m" ? "0.1" : "1"}
          min={unit === "m" ? "0.1" : "1"}
          required
          value={amount}
          onChange={(event) => setAmount(event.target.value)}
          className={fieldClass}
        />
        {useM !== null ? (
          <p className="text-sm text-muted">Logged as {metres(useM)}</p>
        ) : null}
      </div>

      <fieldset className="flex flex-col gap-2">
        <legend className="text-sm font-medium">Used for</legend>
        <label className="flex min-h-12 items-center gap-3 rounded-xl border border-line px-3">
          <input
            type="radio"
            name="purpose"
            className="size-5"
            checked={purpose === "sample"}
            onChange={() => {
              setPurpose("sample");
              setOrderId("");
              setLineId("");
              setStyleId("");
            }}
          />
          Sample / development
        </label>
        <label className="flex min-h-12 items-center gap-3 rounded-xl border border-line px-3">
          <input
            type="radio"
            name="purpose"
            className="size-5"
            checked={purpose === "production"}
            onChange={() => {
              setPurpose("production");
              setStyleId("");
            }}
          />
          Production order
        </label>
      </fieldset>

      {purpose === "sample" ? (
        <SelectField
          id="styleId"
          label="Style"
          value={styleId}
          onChange={setStyleId}
          options={styles.map((style) => ({
            id: style.id,
            label: style.label,
          }))}
          empty="No styles yet."
        />
      ) : (
        <>
          <SelectField
            id="orderId"
            label="Production order"
            value={orderId}
            onChange={(value) => {
              setOrderId(value);
              setStyleId("");
              setLineId("");
            }}
            options={orders.map((order) => ({
              id: order.id,
              label: order.label,
            }))}
            empty="No orders yet."
          />
          {position && position.reservedM > 0 ? (
            <p className="text-sm text-ink">
              Reserved for this order: {metres(position.reservedM)}, used so
              far: {metres(position.usedM)}. Still reserved:{" "}
              {metres(remainingReserved(position))}
              {position.wasteM > 0
                ? `. Waste so far: ${metres(position.wasteM)}`
                : ""}
              .
            </p>
          ) : orderId ? (
            <p className="text-sm text-muted">
              No fabric is reserved for this order.
              {position && position.usedM > 0
                ? ` Used so far: ${metres(position.usedM)}.`
                : ""}
            </p>
          ) : null}
          {orderId ? (
            <SelectField
              id="styleId"
              label="Style on this order (optional)"
              value={styleId}
              onChange={setStyleId}
              options={orderStyles.map((style) => ({
                id: style.id,
                label: style.label,
              }))}
              empty="No styles on this order."
              optional
            />
          ) : null}
          {orderId ? (
            <SelectField
              id="lineId"
              label="Fabric line (optional)"
              value={lineId}
              onChange={setLineId}
              options={orderLines.map((line) => ({
                id: line.id,
                label: line.label,
              }))}
              empty="No fabric line for this material."
              optional
            />
          ) : null}
        </>
      )}

      <div className="flex flex-col gap-2">
        <label className="text-sm font-medium" htmlFor="waste">
          Waste or offcut (optional)
        </label>
        <input
          id="waste"
          inputMode="decimal"
          step={unit === "m" ? "0.1" : "1"}
          min="0"
          value={waste}
          onChange={(event) => setWaste(event.target.value)}
          className={fieldClass}
        />
      </div>

      <div className="flex flex-col gap-2">
        <label className="text-sm font-medium" htmlFor="note">
          Note (optional)
        </label>
        <textarea
          id="note"
          maxLength={500}
          value={note}
          onChange={(event) => setNote(event.target.value)}
          className="min-h-24 rounded-xl border border-line bg-card px-3 py-2 text-base text-ink"
        />
      </div>

      <div className="flex flex-col gap-2">
        <p className="text-sm font-medium">Photo (optional)</p>
        <label className="inline-flex min-h-12 cursor-pointer items-center justify-center rounded-full border border-ink px-4 text-sm font-medium text-ink">
          Take photo
          <input
            type="file"
            accept="image/*"
            capture="environment"
            className="sr-only"
            onChange={(event) => setFile(event.target.files?.[0] ?? null)}
          />
        </label>
        <label className="inline-flex min-h-12 cursor-pointer items-center justify-center rounded-full border border-ink px-4 text-sm font-medium text-ink">
          Choose from gallery
          <input
            type="file"
            accept="image/*"
            className="sr-only"
            onChange={(event) => setFile(event.target.files?.[0] ?? null)}
          />
        </label>
        {file ? <p className="text-sm text-muted">{file.name}</p> : null}
      </div>

      <div className="flex flex-col gap-2">
        <label className="text-sm font-medium" htmlFor="occurredOn">
          Date
        </label>
        <input
          id="occurredOn"
          type="date"
          required
          value={occurredOn}
          onChange={(event) => setOccurredOn(event.target.value)}
          className={fieldClass}
        />
      </div>

      {plan?.warnsNegativeOnHand ? (
        <p
          role="status"
          className="rounded-xl border border-orange px-4 py-3 text-sm text-ink"
        >
          This is more than the metres on hand. You can still log it.
        </p>
      ) : null}
      {plan?.warnsExceedsReservation ? (
        <p
          role="status"
          className="rounded-xl border border-orange px-4 py-3 text-sm text-ink"
        >
          This is more than the metres still reserved for this order. The extra
          comes off available stock. You can still log it.
        </p>
      ) : null}
      {message ? (
        <p
          role="alert"
          className="rounded-xl border border-red px-4 py-3 text-sm text-ink"
        >
          {message}
        </p>
      ) : null}

      <button
        type="submit"
        disabled={busy}
        className="min-h-14 rounded-full bg-ink px-4 text-lg font-medium text-white disabled:opacity-60"
      >
        {busy ? "Saving…" : "Log use"}
      </button>
    </form>
  );
}

function convertField(current: string, from: UsageUnit, to: UsageUnit): string {
  if (!current.trim() || from === to) return current;
  const value = Number(current);
  if (!Number.isFinite(value) || value <= 0) return current;
  if (from === "m" && to === "cm") return String(Math.round(value * 100));
  return String(Math.round(value) / 100);
}

function UnitButton({
  current,
  value,
  label,
  onPick,
}: {
  current: UsageUnit;
  value: UsageUnit;
  label: string;
  onPick: (unit: UsageUnit) => void;
}) {
  const selected = current === value;
  return (
    <button
      type="button"
      aria-pressed={selected}
      onClick={() => onPick(value)}
      className={`min-h-12 rounded-full px-3 text-sm font-medium ${
        selected ? "bg-ink text-white" : "border border-ink text-ink"
      }`}
    >
      {label}
    </button>
  );
}

function SelectField({
  id,
  label,
  value,
  onChange,
  options,
  empty,
  optional = false,
}: {
  id: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  options: { id: number; label: string }[];
  empty: string;
  optional?: boolean;
}) {
  return (
    <div className="flex flex-col gap-2">
      <label className="text-sm font-medium" htmlFor={id}>
        {label}
      </label>
      {options.length === 0 ? (
        <p className="text-sm text-muted">{empty}</p>
      ) : (
        <select
          id={id}
          required={!optional}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          className={fieldClass}
        >
          <option value="">{optional ? "None" : "Choose"}</option>
          {options.map((option) => (
            <option key={option.id} value={option.id}>
              {option.label}
            </option>
          ))}
        </select>
      )}
    </div>
  );
}
