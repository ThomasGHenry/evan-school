import { test, expect } from '@playwright/test';

test('home page has correct title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Evan's Meditation School/);
});

test('home page heading is visible', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: "Evan's Meditation School" })).toBeVisible();
});
