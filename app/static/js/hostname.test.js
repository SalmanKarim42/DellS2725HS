import { determineFutureOrigin } from "./hostname.js";
import { describe, it } from "mocha";
import assert from "assert";

describe("determineFutureOrigin", () => {
  it("returns origin by replacing old hostname with new hostname", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-dells2725hs/"),
        "old-dells2725hs",
        "new-dells2725hs"
      ),
      "https://new-dells2725hs"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-dells2725hs.local/"),
        "old-dells2725hs",
        "new-dells2725hs"
      ),
      "https://new-dells2725hs.local"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-dells2725hs.domain.local/"),
        "old-dells2725hs",
        "new-dells2725hs"
      ),
      "https://new-dells2725hs.domain.local"
    );
  });
  it("returns origin using only new hostname", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-dells2725hs/"),
        undefined,
        "new-dells2725hs"
      ),
      "https://new-dells2725hs"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-dells2725hs.local/"),
        undefined,
        "new-dells2725hs"
      ),
      "https://new-dells2725hs"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-dells2725hs.domain.local/"),
        undefined,
        "new-dells2725hs"
      ),
      "https://new-dells2725hs"
    );
  });
  it("maintains port number", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("https://old-dells2725hs:8080/"),
        "old-dells2725hs",
        "new-dells2725hs"
      ),
      "https://new-dells2725hs:8080"
    );
  });
  it("maintains protocol", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("http://old-dells2725hs/"),
        "old-dells2725hs",
        "new-dells2725hs"
      ),
      "http://new-dells2725hs"
    );
    assert.strictEqual(
      determineFutureOrigin(
        new URL("ftp://old-dells2725hs/"),
        "old-dells2725hs",
        "new-dells2725hs"
      ),
      "ftp://new-dells2725hs"
    );
  });
  it("strips pathname", () => {
    assert.strictEqual(
      determineFutureOrigin(
        new URL("http://old-dells2725hs/some-path/"),
        "old-dells2725hs",
        "new-dells2725hs"
      ),
      "http://new-dells2725hs"
    );
  });
});
