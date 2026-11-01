export function financesStatus(role: string | null | undefined): 200 | 403 {
  return role === "owner" ? 200 : 403;
}
