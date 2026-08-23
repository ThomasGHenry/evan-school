export function oklchContrastRatio(l1: number, c1: number, h1: number, l2: number, c2: number, h2: number): number {
  const lum1 = relativeLuminance(oklchToLinearSrgb(l1, c1, h1));
  const lum2 = relativeLuminance(oklchToLinearSrgb(l2, c2, h2));
  const lighter = Math.max(lum1, lum2);
  const darker = Math.min(lum1, lum2);
  return (lighter + 0.05) / (darker + 0.05);
}

function oklchToLinearSrgb(l: number, c: number, h: number): { r: number; g: number; b: number } {
  const rad = (h * Math.PI) / 180;
  const a = c * Math.cos(rad);
  const b = c * Math.sin(rad);
  const lp = l + 0.3963377774 * a + 0.2158037573 * b;
  const mp = l - 0.1055613458 * a - 0.0638541728 * b;
  const sp = l - 0.0894841775 * a - 1.2914855480 * b;
  return {
    r: clamp01(4.0767416621 * lp ** 3 - 3.3077115913 * mp ** 3 + 0.2309699292 * sp ** 3),
    g: clamp01(-1.2684380046 * lp ** 3 + 2.6097574011 * mp ** 3 - 0.3413193965 * sp ** 3),
    b: clamp01(-0.0041960863 * lp ** 3 - 0.7034186147 * mp ** 3 + 1.7076147010 * sp ** 3),
  };
}

function relativeLuminance({ r, g, b }: { r: number; g: number; b: number }): number {
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function clamp01(v: number): number {
  return Math.max(0, Math.min(1, v));
}
