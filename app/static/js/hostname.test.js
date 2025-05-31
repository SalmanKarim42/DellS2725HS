import { determineFutureOrigin } from "./hostname.js";
import { describe, it } from "mocha";
import assert from "assert";

describe("determineFutureOrigin", () => {
  it("returns origin by replacing old hostname with new hostname", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-DellS2725HS/"),
        "old-DellS2725HS",
        "new-DellS2725HS"
      ),
      "https://new-DellS2725HS"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-DellS2725HS.local/"),
        "old-DellS2725HS",
        "new-DellS2725HS"
      ),
      "https://new-DellS2725HS.local"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-DellS2725HS.domain.local/"),
        "old-DellS2725HS",
        "new-DellS2725HS"
      ),
      "https://new-DellS2725HS.domain.local"
    );
  });
  it("returns origin using only new hostname", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-DellS2725HS/"),
        undefined,
        "new-DellS2725HS"
      ),
      "https://new-DellS2725HS"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-DellS2725HS.local/"),
        undefined,
        "new-DellS2725HS"
      ),
      "https://new-DellS2725HS"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-DellS2725HS.domain.local/"),
        undefined,
        "new-DellS2725HS"
      ),
      "https://new-DellS2725HS"
    );
  });
  it("maintains port number", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-DellS2725HS:8080/"),
        "old-DellS2725HS",
        "new-DellS2725HS"
      ),
      "https://new-DellS2725HS:8080"
    );
  });
  it("maintains protocol", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("http://old-DellS2725HS/"),
        "old-DellS2725HS",
        "new-DellS2725HS"
      ),
      "http://new-DellS2725HS"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("ftp://old-DellS2725HS/"),
        "old-DellS2725HS",
        "new-DellS2725HS"
      ),
      "ftp://new-DellS2725HS"
    );
  });
  it("strips pathname", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("http://old-DellS2725HS/some-path/"),
        "old-DellS2725HS",
        "new-DellS2725HS"
      ),
      "http://new-DellS2725HS"
    );
  });
});
