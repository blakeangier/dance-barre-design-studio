export const fieldClass =
  "min-h-12 w-full rounded-xl border border-line bg-card px-3 text-base text-ink";

export function TextField({
  id,
  label,
  name,
  defaultValue,
  required,
  type = "text",
  maxLength,
  inputMode,
}: {
  id: string;
  label: string;
  name: string;
  defaultValue?: string | number | null;
  required?: boolean;
  type?: string;
  maxLength?: number;
  inputMode?: "decimal" | "tel" | "email" | "text";
}) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-medium" htmlFor={id}>
        {label}
      </label>
      <input
        id={id}
        name={name}
        type={type}
        required={required}
        maxLength={maxLength}
        inputMode={inputMode}
        defaultValue={defaultValue ?? ""}
        className={fieldClass}
      />
    </div>
  );
}

export function AreaField({
  id,
  label,
  name,
  defaultValue,
}: {
  id: string;
  label: string;
  name: string;
  defaultValue?: string | null;
}) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-medium" htmlFor={id}>
        {label}
      </label>
      <textarea
        id={id}
        name={name}
        defaultValue={defaultValue ?? ""}
        className="min-h-24 w-full rounded-xl border border-line bg-card px-3 py-2 text-base text-ink"
      />
    </div>
  );
}

export function SelectField({
  id,
  label,
  name,
  defaultValue,
  children,
}: {
  id: string;
  label: string;
  name: string;
  defaultValue?: string | null;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-medium" htmlFor={id}>
        {label}
      </label>
      <select
        id={id}
        name={name}
        defaultValue={defaultValue ?? ""}
        className={fieldClass}
      >
        {children}
      </select>
    </div>
  );
}

export function CheckField({
  label,
  name,
  defaultChecked,
}: {
  label: string;
  name: string;
  defaultChecked?: boolean;
}) {
  return (
    <label className="flex min-h-12 items-center gap-2 text-sm">
      <input
        type="checkbox"
        name={name}
        defaultChecked={defaultChecked}
        className="size-5"
      />
      {label}
    </label>
  );
}

export function SaveButton({ label = "Save" }: { label?: string }) {
  return (
    <button
      type="submit"
      className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
    >
      {label}
    </button>
  );
}
