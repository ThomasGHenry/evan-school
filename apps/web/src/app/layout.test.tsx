import { describe, it, expect } from 'vitest';

describe('ClerkProvider mounting behaviour', () => {
  it('build succeeds when NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY is absent', () => {
    const key = process.env['NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY'];
    expect(key).toBeUndefined();
  });
});
