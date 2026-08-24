import { describe, it, expect } from 'vitest';
import { parseEnv } from './index';

const validEnv = {
  DATABASE_URL: 'postgresql://localhost/test',
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: 'non_secret_test_value_pub',
  CLERK_SECRET_KEY: 'non_secret_test_value_sec',
};

describe('parseEnv', () => {
  it('throws on missing DATABASE_URL', () => {
    const { DATABASE_URL: _omit, ...rest } = validEnv;
    expect(() => parseEnv(rest)).toThrow('Invalid environment variables');
  });

  it('throws on missing NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY', () => {
    const { NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: _omit, ...rest } = validEnv;
    expect(() => parseEnv(rest)).toThrow('Invalid environment variables');
  });

  it('throws on missing CLERK_SECRET_KEY', () => {
    const { CLERK_SECRET_KEY: _omit, ...rest } = validEnv;
    expect(() => parseEnv(rest)).toThrow('Invalid environment variables');
  });

  it('returns parsed env when all required vars present', () => {
    const result = parseEnv(validEnv);
    expect(result.DATABASE_URL).toBe('postgresql://localhost/test');
    expect(result.NODE_ENV).toBe('development');
    expect(result.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY).toBe('non_secret_test_value_pub');
    expect(result.CLERK_SECRET_KEY).toBe('non_secret_test_value_sec');
  });
});
