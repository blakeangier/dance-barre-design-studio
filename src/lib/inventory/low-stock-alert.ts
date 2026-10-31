export type LowStockAlertLine = {
  materialCode: string;
  fabricName: string | null;
  availableM: number;
  reorderPointM: number;
  pageUrl: string;
  thumbUrl: string | null;
};

export function crossedBelowReorderPoint(
  beforeM: number | null,
  afterM: number | null,
  reorderPointM: number,
): boolean {
  if (beforeM === null || afterM === null) return false;
  return beforeM > reorderPointM && afterM <= reorderPointM;
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function metresText(value: number): string {
  return `${value.toLocaleString("en-CA", { maximumFractionDigits: 2 })} m`;
}

export function lowStockDigest(lines: readonly LowStockAlertLine[]): {
  subject: string;
  text: string;
  html: string;
} {
  const subject =
    lines.length === 1
      ? `Low fabric: ${lines[0]?.materialCode ?? "1 material"}`
      : `Low fabric: ${lines.length} materials`;
  const text = [
    "These fabrics are at or below their reorder point.",
    "",
    ...lines.flatMap((line) => [
      [line.materialCode, line.fabricName].filter(Boolean).join(" · "),
      `Available ${metresText(line.availableM)}`,
      `Reorder point ${metresText(line.reorderPointM)}`,
      line.pageUrl,
      "",
    ]),
  ].join("\n");
  const html = [
    "<p>These fabrics are at or below their reorder point.</p>",
    ...lines.map((line) => {
      const name = escapeHtml(
        [line.materialCode, line.fabricName].filter(Boolean).join(" · "),
      );
      const image = line.thumbUrl
        ? `<img src="${escapeHtml(line.thumbUrl)}" alt="" width="64" height="64" />`
        : "";
      return `<p>${image}<br /><strong>${name}</strong><br />Available ${escapeHtml(metresText(line.availableM))}<br />Reorder point ${escapeHtml(metresText(line.reorderPointM))}<br /><a href="${escapeHtml(line.pageUrl)}">Open this fabric</a></p>`;
    }),
  ].join("");
  return { subject, text, html };
}

export type DigestDelivery = "missing-key" | "empty" | "sent" | "failed";

export async function deliverLowStockDigest(input: {
  apiKey: string | undefined;
  from: string;
  to: string;
  lines: readonly LowStockAlertLine[];
  send?: (message: {
    from: string;
    to: string;
    subject: string;
    html: string;
    text: string;
  }) => Promise<{ ok: boolean }>;
}): Promise<DigestDelivery> {
  const apiKey = input.apiKey?.trim();
  if (!apiKey) return "missing-key";
  if (input.lines.length === 0) return "empty";
  const digest = lowStockDigest(input.lines);
  const send =
    input.send ??
    ((message) =>
      postResend(apiKey, {
        ...message,
      }));
  try {
    const result = await send({
      from: input.from,
      to: input.to,
      subject: digest.subject,
      html: digest.html,
      text: digest.text,
    });
    return result.ok ? "sent" : "failed";
  } catch {
    return "failed";
  }
}

async function postResend(
  apiKey: string,
  message: {
    from: string;
    to: string;
    subject: string;
    html: string;
    text: string;
  },
): Promise<{ ok: boolean }> {
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: message.from,
      to: [message.to],
      subject: message.subject,
      html: message.html,
      text: message.text,
    }),
  });
  return { ok: response.ok };
}
