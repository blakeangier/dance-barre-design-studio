import Image from "next/image";

const LOGO_WIDTH = 1000;
const LOGO_HEIGHT = 679;

export function BrandLogo({
  className,
  priority = false,
}: {
  className?: string;
  priority?: boolean;
}) {
  return (
    <Image
      src="/brand/dancebarre-logo.webp"
      alt="Dance Barre"
      width={LOGO_WIDTH}
      height={LOGO_HEIGHT}
      priority={priority}
      sizes={priority ? "280px" : "168px"}
      className={className}
    />
  );
}
