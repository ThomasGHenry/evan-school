import { describe, expect, test } from 'vitest';
import { oklchContrastRatio } from './contrast';
import { tokens } from './tokens';

describe('oklchContrastRatio', () => {
  test('is a function', () => {
    expect(typeof oklchContrastRatio).toBe('function');
  });

  test('pure black vs pure white returns the WCAG maximum of 21:1', () => {
    expect(oklchContrastRatio(0, 0, 0, 1, 0, 0)).toBeCloseTo(21, 0);
  });

  test('identical colors return a ratio of 1:1', () => {
    expect(oklchContrastRatio(0.5, 0.1, 200, 0.5, 0.1, 200)).toBeCloseTo(1, 5);
  });
});

describe('WCAG AA compliance — default token palette', () => {
  const { color } = tokens;

  test('text-default over background meets WCAG AA (>= 4.5:1)', () => {
    const ratio = oklchContrastRatio(
      color.textDefault.l, color.textDefault.c, color.textDefault.h,
      color.background.l, color.background.c, color.background.h,
    );
    expect(ratio).toBeGreaterThanOrEqual(4.5);
  });

  test('text-muted over background meets WCAG AA large text (>= 3:1)', () => {
    const ratio = oklchContrastRatio(
      color.textMuted.l, color.textMuted.c, color.textMuted.h,
      color.background.l, color.background.c, color.background.h,
    );
    expect(ratio).toBeGreaterThanOrEqual(3);
  });
});
