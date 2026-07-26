import { describe, expect, it } from "vitest";
import { navigation, site } from "../src/data/site";
import { projects } from "../src/data/projects";

describe("portfolio content", () => {
  it("uses the production domain", () => {
    expect(site.domain).toBe("aliberkyildiz.com");
  });

  it("keeps navigation routes unique", () => {
    expect(new Set(navigation.map(({ href }) => href)).size).toBe(
      navigation.length,
    );
  });

  it("publishes at least one concrete case study", () => {
    expect(projects.some(({ status }) => status === "Aktif")).toBe(true);
  });

  it("links to verified public profiles", () => {
    expect(site.linkedin).toBe("https://www.linkedin.com/in/aliberkyildiz/");
    expect(site.github).toBe("https://github.com/aliberkyldz");
  });
});
