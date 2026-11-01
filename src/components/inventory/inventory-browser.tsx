"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useId, useRef, useState, type KeyboardEvent } from "react";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { StockBadge } from "@/components/inventory/stock-badge";
import { metres } from "@/lib/inventory/format";
import {
  filterMaterials,
  suggestMaterials,
  type InventoryMaterial,
} from "@/lib/inventory/search";

const DEBOUNCE_MS = 200;

type Draft = {
  query: string;
  type: string;
  lowOnly: boolean;
  reviewOnly: boolean;
  showArchived: boolean;
  missingPhoto: boolean;
};

function toParams(draft: Draft): URLSearchParams {
  const params = new URLSearchParams();
  const query = draft.query.trim();
  const type = draft.type.trim();
  if (query) params.set("q", query);
  if (type) params.set("type", type);
  if (draft.lowOnly) params.set("low", "1");
  if (draft.reviewOnly) params.set("review", "1");
  if (draft.showArchived) params.set("archived", "1");
  if (draft.missingPhoto) params.set("nophoto", "1");
  return params;
}

function materialHref(code: string): string {
  return `/inventory/${encodeURIComponent(code)}`;
}

export function InventoryBrowser({
  items,
  loadError,
  initialQuery,
  initialType,
  initialLow,
  initialReview,
  showArchived: initialArchived,
  missingPhoto: initialMissing,
  canEdit,
}: {
  items: InventoryMaterial[];
  loadError: boolean;
  initialQuery: string;
  initialType: string;
  initialLow: boolean;
  initialReview: boolean;
  showArchived: boolean;
  missingPhoto: boolean;
  canEdit: boolean;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const listId = useId();
  const boxRef = useRef<HTMLDivElement>(null);
  const writtenUrl = useRef(
    toParams({
      query: initialQuery,
      type: initialType,
      lowOnly: initialLow,
      reviewOnly: initialReview,
      showArchived: initialArchived,
      missingPhoto: initialMissing,
    }).toString(),
  );
  const draftRef = useRef<Draft>({
    query: initialQuery,
    type: initialType,
    lowOnly: initialLow,
    reviewOnly: initialReview,
    showArchived: initialArchived,
    missingPhoto: initialMissing,
  });

  const [query, setQuery] = useState(initialQuery);
  const [type, setType] = useState(initialType);
  const [lowOnly, setLowOnly] = useState(initialLow);
  const [reviewOnly, setReviewOnly] = useState(initialReview);
  const [showArchived, setShowArchived] = useState(initialArchived);
  const [missingPhoto, setMissingPhoto] = useState(initialMissing);
  const [appliedQuery, setAppliedQuery] = useState(initialQuery);
  const [appliedType, setAppliedType] = useState(initialType);
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(-1);

  const urlQuery = searchParams.get("q") ?? "";
  const urlType = searchParams.get("type") ?? "";
  const urlLow = searchParams.get("low") === "1";
  const urlReview = searchParams.get("review") === "1";
  const urlArchived = searchParams.get("archived") === "1";
  const urlMissing = searchParams.get("nophoto") === "1";

  function commit(draft: Draft) {
    const next = toParams(draft).toString();
    if (next === writtenUrl.current) return;
    writtenUrl.current = next;
    router.replace(next ? `/inventory?${next}` : "/inventory", {
      scroll: false,
    });
  }

  useEffect(() => {
    const canonical = toParams({
      query: urlQuery,
      type: urlType,
      lowOnly: urlLow,
      reviewOnly: urlReview,
      showArchived: urlArchived,
      missingPhoto: urlMissing,
    }).toString();
    if (canonical === writtenUrl.current) return;
    writtenUrl.current = canonical;
    draftRef.current = {
      query: urlQuery,
      type: urlType,
      lowOnly: urlLow,
      reviewOnly: urlReview,
      showArchived: urlArchived,
      missingPhoto: urlMissing,
    };
    setQuery(urlQuery);
    setType(urlType);
    setLowOnly(urlLow);
    setReviewOnly(urlReview);
    setShowArchived(urlArchived);
    setMissingPhoto(urlMissing);
    setAppliedQuery(urlQuery);
    setAppliedType(urlType);
  }, [urlQuery, urlType, urlLow, urlReview, urlArchived, urlMissing]);

  useEffect(() => {
    const handle = window.setTimeout(() => {
      const draft = draftRef.current;
      setAppliedQuery(draft.query);
      setAppliedType(draft.type);
      const next = toParams(draft).toString();
      if (next === writtenUrl.current) return;
      writtenUrl.current = next;
      router.replace(next ? `/inventory?${next}` : "/inventory", {
        scroll: false,
      });
    }, DEBOUNCE_MS);
    return () => window.clearTimeout(handle);
  }, [query, type, router]);

  const filters = {
    query: appliedQuery,
    type: appliedType,
    lowOnly,
    reviewOnly,
  };
  const pool = missingPhoto
    ? items.filter((item) => !item.photoThumbUrl)
    : items;
  const materials = filterMaterials(pool, filters);
  const suggestions = suggestMaterials(pool, filters);
  const pending =
    query.trim() !== appliedQuery.trim() || type.trim() !== appliedType.trim();
  const showSuggestions = open && query.trim().length > 0 && !pending;
  const filterKey = `${appliedQuery}\n${appliedType}\n${lowOnly}\n${reviewOnly}\n${missingPhoto}`;
  const [highlightKey, setHighlightKey] = useState(filterKey);
  if (highlightKey !== filterKey) {
    setHighlightKey(filterKey);
    setActiveIndex(-1);
  }
  const highlighted = highlightKey === filterKey ? activeIndex : -1;
  const activeId =
    showSuggestions && highlighted >= 0
      ? `${listId}-option-${highlighted}`
      : undefined;

  useEffect(() => {
    if (!activeId) return;
    document.getElementById(activeId)?.scrollIntoView({ block: "nearest" });
  }, [activeId]);

  function remember(next: Draft) {
    draftRef.current = next;
  }

  function onQueryChange(value: string) {
    const next = { ...draftRef.current, query: value };
    remember(next);
    setQuery(value);
    setOpen(true);
  }

  function onTypeChange(value: string) {
    const next = { ...draftRef.current, type: value };
    remember(next);
    setType(value);
  }

  function onLowChange(checked: boolean) {
    const next = { ...draftRef.current, lowOnly: checked };
    remember(next);
    setLowOnly(checked);
    commit(next);
  }

  function onReviewChange(checked: boolean) {
    const next = { ...draftRef.current, reviewOnly: checked };
    remember(next);
    setReviewOnly(checked);
    commit(next);
  }

  function onArchivedChange(checked: boolean) {
    const next = { ...draftRef.current, showArchived: checked };
    remember(next);
    setShowArchived(checked);
    commit(next);
  }

  function onMissingPhotoChange(checked: boolean) {
    const next = { ...draftRef.current, missingPhoto: checked };
    remember(next);
    setMissingPhoto(checked);
    commit(next);
  }

  function onSearchKeyDown(event: KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Escape") {
      if (!open) return;
      event.preventDefault();
      setOpen(false);
      setActiveIndex(-1);
      return;
    }
    if (!query.trim() || pending) return;
    if (event.key === "ArrowDown") {
      event.preventDefault();
      setOpen(true);
      if (suggestions.length === 0) return;
      setActiveIndex((index) => (index + 1) % suggestions.length);
      return;
    }
    if (event.key === "ArrowUp") {
      event.preventDefault();
      setOpen(true);
      if (suggestions.length === 0) return;
      setActiveIndex((index) =>
        index <= 0 ? suggestions.length - 1 : index - 1,
      );
      return;
    }
    if (event.key === "Enter" && showSuggestions && highlighted >= 0) {
      const pick = suggestions[highlighted];
      if (!pick) return;
      event.preventDefault();
      router.push(materialHref(pick.materialCode));
    }
  }

  return (
    <div className="flex flex-col gap-4">
      <div>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h1 className="font-serif text-3xl text-ink">Inventory</h1>
          {canEdit ? (
            <Link
              href="/inventory/new"
              className="inline-flex min-h-12 items-center rounded-full bg-ink px-4 font-medium text-white"
            >
              New material
            </Link>
          ) : null}
        </div>
        <p className="mt-2 text-sm text-muted" aria-live="polite">
          {materials.length} materials. On hand and reserved come from the stock
          ledger.
        </p>
        <Link
          href="/inventory/use"
          className="mt-4 inline-flex min-h-14 w-full items-center justify-center rounded-full bg-ink px-4 text-lg font-medium text-white sm:w-auto"
        >
          Log material use
        </Link>
        <Link
          href="/inventory/usage"
          className="mt-2 inline-flex min-h-12 items-center text-sm font-medium text-ink"
        >
          Usage log
        </Link>
        {canEdit ? (
          <Link
            href="/inventory/alerts"
            className="inline-flex min-h-12 items-center text-sm font-medium text-ink"
          >
            Low-stock alerts
          </Link>
        ) : null}
      </div>
      <div className="grid gap-3 rounded-2xl border border-line bg-card p-4">
        <div ref={boxRef} className="grid scroll-mt-4 gap-2">
          <label className="text-sm font-medium" htmlFor="q">
            Search
          </label>
          <input
            id="q"
            role="combobox"
            aria-autocomplete="list"
            aria-haspopup="listbox"
            aria-expanded={showSuggestions}
            aria-controls={showSuggestions ? listId : undefined}
            aria-activedescendant={activeId}
            value={query}
            onChange={(event) => onQueryChange(event.target.value)}
            onFocus={() => {
              setOpen(true);
              boxRef.current?.scrollIntoView({ block: "start" });
            }}
            onBlur={() => {
              window.setTimeout(() => {
                if (!boxRef.current?.contains(document.activeElement)) {
                  setOpen(false);
                  setActiveIndex(-1);
                }
              }, 0);
            }}
            onKeyDown={onSearchKeyDown}
            autoCapitalize="off"
            autoCorrect="off"
            spellCheck={false}
            autoComplete="off"
            enterKeyHint="search"
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <p className="sr-only">
            Suggestions appear as you type. Up and down arrows choose a
            material. Enter opens it. Escape closes the suggestions.
          </p>
          {showSuggestions ? (
            suggestions.length > 0 ? (
              <ul
                id={listId}
                role="listbox"
                aria-label="Matching materials"
                className="max-h-[min(20rem,40dvh)] overflow-y-auto rounded-xl border border-line"
              >
                {suggestions.map((item, index) => (
                  <li
                    key={item.id}
                    role="presentation"
                    className={`flex items-center gap-3 px-3 py-2 ${
                      index === highlighted ? "bg-paper" : "bg-card"
                    }`}
                  >
                    <PhotoThumb
                      thumbUrl={item.photoThumbUrl ?? null}
                      fullUrl={item.photoFullUrl ?? null}
                      label={item.materialCode}
                    />
                    <Link
                      id={`${listId}-option-${index}`}
                      role="option"
                      aria-selected={index === highlighted}
                      href={materialHref(item.materialCode)}
                      onPointerDown={(event) => event.preventDefault()}
                      onMouseEnter={() => setActiveIndex(index)}
                      className="min-h-16 min-w-0 flex-1 py-1"
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
                    </Link>
                  </li>
                ))}
              </ul>
            ) : (
              <p role="status" className="text-sm text-muted">
                No matching materials.
              </p>
            )
          ) : null}
        </div>
        <label className="text-sm font-medium" htmlFor="type">
          Type or content
        </label>
        <input
          id="type"
          value={type}
          onChange={(event) => onTypeChange(event.target.value)}
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
        />
        <label className="flex min-h-12 items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={lowOnly}
            onChange={(event) => onLowChange(event.target.checked)}
            className="size-5"
          />
          Low stock
        </label>
        <label className="flex min-h-12 items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={reviewOnly}
            onChange={(event) => onReviewChange(event.target.checked)}
            className="size-5"
          />
          Needs review
        </label>
        <label className="flex min-h-12 items-center gap-2 text-sm">
          <input
            type="checkbox"
            className="size-5"
            checked={showArchived}
            onChange={(event) => onArchivedChange(event.target.checked)}
          />
          Show archived
        </label>
        <label className="flex min-h-12 items-center gap-2 text-sm">
          <input
            type="checkbox"
            className="size-5"
            checked={missingPhoto}
            onChange={(event) => onMissingPhotoChange(event.target.checked)}
          />
          No photo
        </label>
      </div>
      {loadError ? (
        <p className="text-sm text-muted">The inventory list did not load.</p>
      ) : materials.length === 0 ? (
        <p className="text-sm text-muted">No materials match.</p>
      ) : (
        <ul className="flex flex-col gap-3">
          {materials.map((material) => (
            <li
              key={material.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <div className="flex items-start gap-3">
                <PhotoThumb
                  thumbUrl={material.photoThumbUrl ?? null}
                  fullUrl={material.photoFullUrl ?? null}
                  label={material.materialCode}
                />
                <div className="min-w-0">
                  <Link
                    href={materialHref(material.materialCode)}
                    className="inline-flex min-h-11 items-center font-medium text-ink"
                  >
                    {material.materialCode}
                  </Link>
                  <p className="text-sm text-muted">
                    {[
                      material.fabricName,
                      material.colourName,
                      material.content,
                    ]
                      .filter(Boolean)
                      .join(" · ")}
                  </p>
                  {material.binLocation ? (
                    <p className="text-sm text-muted">
                      Bin {material.binLocation}
                    </p>
                  ) : null}
                  {material.needsReview ? (
                    <p className="mt-1 text-xs font-medium text-ink">
                      Needs review
                    </p>
                  ) : null}
                  <StockBadge
                    onHand={material.onHandM}
                    reserved={material.reservedM}
                    available={material.availableM}
                    low={material.isLowStock}
                  />
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
