type OklchColor = { l: number; c: number; h: number };

type ColorTokens = {
  background: OklchColor;
  surface: OklchColor;
  border: OklchColor;
  primary: OklchColor;
  primaryHover: OklchColor;
  textDefault: OklchColor;
  textMuted: OklchColor;
  destructive: OklchColor;
};

export const tokens: { color: ColorTokens } = {
  color: {
    background:   { l: 0.14, c: 0.005, h: 250 },
    surface:      { l: 0.19, c: 0.008, h: 250 },
    border:       { l: 0.30, c: 0.010, h: 250 },
    primary:      { l: 0.62, c: 0.140, h: 250 },
    primaryHover: { l: 0.68, c: 0.140, h: 250 },
    textDefault:  { l: 0.96, c: 0.004, h: 250 },
    textMuted:    { l: 0.72, c: 0.010, h: 250 },
    destructive:  { l: 0.55, c: 0.190, h: 22  },
  },
};
