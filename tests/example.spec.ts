
import { TestPage } from "@/pages/TestPage";
import { exampleData } from "@/data/example.data";
import { test, expect } from "@playwright/test";

test("has title", async ({ page }) => {
  const testPage = new TestPage(page);

  await testPage.goto(exampleData.homepage.url);

  await expect(page).toHaveTitle(exampleData.homepage.title);
});

test("get started link", async ({ page }) => {
  const testPage = new TestPage(page);

  await testPage.goto(exampleData.homepage.url);

  await testPage.getByRole("link", { name: exampleData.getStarted.linkName }).click();

  await expect(
    testPage.getByRole("heading", { name: exampleData.getStarted.headingName }),
  ).toBeVisible();
});
