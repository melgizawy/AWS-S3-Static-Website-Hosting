const { test, expect } = require('@playwright/test');

test.describe('Static website smoke tests', () => {
  test('homepage loads and has correct title and main sections', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/AWS S3 Portfolio Project/i);
    await expect(page.locator('header.header')).toBeVisible();
    await expect(page.locator('nav.navbar')).toBeVisible();
    await expect(page.locator('footer.footer')).toBeVisible();
  });

  test('no console errors during load', async ({ page }) => {
    const errors = [];
    page.on('pageerror', e => errors.push(e));
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
    await page.goto('/');
    expect(errors).toHaveLength(0);
  });

  test('internal links respond (basic check)', async ({ page, request }) => {
    await page.goto('/');
    const anchors = await page.$$eval('a[href]', els => els.map(a => a.getAttribute('href')));
    expect(anchors.length).toBeGreaterThan(0);
    const base = 'http://localhost:3000';
    for (const href of anchors) {
      if (!href) continue;
      if (href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('http')) continue;
      const url = new URL(href, base).toString();
      const res = await request.get(url);
      expect(res.status()).toBeLessThan(400);
    }
  });
});