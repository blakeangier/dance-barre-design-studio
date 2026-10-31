import { saveMaterial } from "@/app/(workspace)/records/material-actions";
import {
  AreaField,
  CheckField,
  SaveButton,
  SelectField,
  TextField,
} from "@/components/records/fields";

type SupplierOption = { id: number; name: string };

type MaterialFields = {
  id: number;
  material_code: string;
  fabric_name: string | null;
  colour_name: string | null;
  colour_number: string | null;
  fabric_number: string | null;
  content: string | null;
  fabric_type: string | null;
  width_cm: number | string | null;
  gsm: number | string | null;
  bin_location: string | null;
  registry_notes: string | null;
  needs_review: boolean;
  needs_review_reason: string | null;
  supplier_id: number | null;
  supplier_as_written: string | null;
  archived_at: string | null;
};

type CostFields = {
  list_price_per_m: number | string | null;
  net_price_per_m: number | string | null;
  discount_entered: number | string | null;
};

export function MaterialForm({
  material,
  suppliers,
  cost,
}: {
  material: MaterialFields | null;
  suppliers: SupplierOption[];
  cost: CostFields | null;
}) {
  return (
    <form
      action={saveMaterial}
      className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
    >
      <h2 className="font-serif text-2xl text-ink">
        {material ? "Edit material" : "New material"}
      </h2>
      <p className="text-sm text-muted">
        On-hand quantities stay on the stock ledger. This form does not change
        them.
      </p>
      {material ? (
        <>
          <input type="hidden" name="id" value={material.id} />
          <input
            type="hidden"
            name="returnCode"
            value={material.material_code}
          />
          <input
            type="hidden"
            name="archivedAt"
            value={material.archived_at ?? ""}
          />
        </>
      ) : null}
      <TextField
        id="materialCode"
        name="materialCode"
        label="Material ID"
        required
        defaultValue={material?.material_code}
      />
      <TextField
        id="fabricName"
        name="fabricName"
        label="Name"
        defaultValue={material?.fabric_name}
      />
      <TextField
        id="colourName"
        name="colourName"
        label="Colour"
        defaultValue={material?.colour_name}
      />
      <TextField
        id="colourNumber"
        name="colourNumber"
        label="Colour number"
        defaultValue={material?.colour_number}
      />
      <TextField
        id="fabricNumber"
        name="fabricNumber"
        label="Fabric number"
        defaultValue={material?.fabric_number}
      />
      <TextField
        id="fabricType"
        name="fabricType"
        label="Type"
        defaultValue={material?.fabric_type}
      />
      <TextField
        id="content"
        name="content"
        label="Content"
        defaultValue={material?.content}
      />
      <TextField
        id="widthCm"
        name="widthCm"
        label="Width (cm)"
        inputMode="decimal"
        defaultValue={material?.width_cm}
      />
      <TextField
        id="gsm"
        name="gsm"
        label="GSM"
        inputMode="decimal"
        defaultValue={material?.gsm}
      />
      <SelectField
        id="supplierId"
        name="supplierId"
        label="Supplier"
        defaultValue={material?.supplier_id ? String(material.supplier_id) : ""}
      >
        <option value="">No linked supplier</option>
        {suppliers.map((supplier) => (
          <option key={supplier.id} value={supplier.id}>
            {supplier.name}
          </option>
        ))}
      </SelectField>
      <TextField
        id="supplierWritten"
        name="supplierWritten"
        label="Supplier as written"
        defaultValue={material?.supplier_as_written}
      />
      <TextField
        id="binLocation"
        name="binLocation"
        label="Bin"
        defaultValue={material?.bin_location}
      />
      <AreaField
        id="notes"
        name="notes"
        label="Notes"
        defaultValue={material?.registry_notes}
      />
      <CheckField
        name="needsReview"
        label="Needs review"
        defaultChecked={material?.needs_review ?? false}
      />
      <AreaField
        id="reviewNote"
        name="reviewNote"
        label="Review note"
        defaultValue={material?.needs_review_reason}
      />
      <TextField
        id="listPrice"
        name="listPrice"
        label="List price per metre"
        inputMode="decimal"
        defaultValue={cost?.list_price_per_m}
      />
      <TextField
        id="discount"
        name="discount"
        label="Discount as entered"
        inputMode="decimal"
        defaultValue={cost?.discount_entered}
      />
      <TextField
        id="netPrice"
        name="netPrice"
        label="Net price per metre"
        inputMode="decimal"
        defaultValue={cost?.net_price_per_m}
      />
      <CheckField
        name="archive"
        label="Archive (hide from the default list)"
        defaultChecked={Boolean(material?.archived_at)}
      />
      <SaveButton label={material ? "Save material" : "Create material"} />
    </form>
  );
}
