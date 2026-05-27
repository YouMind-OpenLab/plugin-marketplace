#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const repoRoot = process.cwd();
const marketplacePath = path.join(repoRoot, ".agents", "plugins", "marketplace.json");

function fail(message) {
  console.error(`marketplace validation failed: ${message}`);
  process.exitCode = 1;
}

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    fail(`unable to read ${filePath}: ${error.message}`);
    return null;
  }
}

const payload = readJson(marketplacePath);

if (!isObject(payload)) {
  fail("marketplace root must be a JSON object");
  process.exit();
}

if (typeof payload.name !== "string" || payload.name.trim() === "") {
  fail("top-level `name` must be a non-empty string");
}

if (payload.interface !== undefined && !isObject(payload.interface)) {
  fail("top-level `interface` must be an object when present");
}

if (!Array.isArray(payload.plugins)) {
  fail("top-level `plugins` must be an array");
}

const names = new Set();
const installationValues = new Set(["NOT_AVAILABLE", "AVAILABLE", "INSTALLED_BY_DEFAULT"]);
const authValues = new Set(["ON_INSTALL", "ON_USE"]);
const sourceKinds = new Set(["local", "url", "git-subdir"]);

for (const [index, plugin] of payload.plugins.entries()) {
  const label = `plugins[${index}]`;

  if (!isObject(plugin)) {
    fail(`${label} must be an object`);
    continue;
  }

  if (typeof plugin.name !== "string" || plugin.name.trim() === "") {
    fail(`${label}.name must be a non-empty string`);
  } else if (names.has(plugin.name)) {
    fail(`duplicate plugin name: ${plugin.name}`);
  } else {
    names.add(plugin.name);
  }

  if (!isObject(plugin.source)) {
    fail(`${label}.source must be an object`);
  } else {
    if (!sourceKinds.has(plugin.source.source)) {
      fail(`${label}.source.source must be one of: ${Array.from(sourceKinds).join(", ")}`);
    }

    if (plugin.source.source === "local") {
      if (typeof plugin.source.path !== "string" || !plugin.source.path.startsWith("./")) {
        fail(`${label}.source.path must be a relative ./ path for local sources`);
      }
    }

    if (plugin.source.source === "url" || plugin.source.source === "git-subdir") {
      if (typeof plugin.source.url !== "string" || plugin.source.url.trim() === "") {
        fail(`${label}.source.url must be a non-empty string`);
      }
    }

    if (plugin.source.source === "git-subdir") {
      if (typeof plugin.source.path !== "string" || plugin.source.path.trim() === "") {
        fail(`${label}.source.path must be present for git-subdir sources`);
      }
    }
  }

  if (!isObject(plugin.policy)) {
    fail(`${label}.policy must be an object`);
  } else {
    if (!installationValues.has(plugin.policy.installation)) {
      fail(`${label}.policy.installation must be one of: ${Array.from(installationValues).join(", ")}`);
    }

    if (!authValues.has(plugin.policy.authentication)) {
      fail(`${label}.policy.authentication must be one of: ${Array.from(authValues).join(", ")}`);
    }
  }

  if (typeof plugin.category !== "string" || plugin.category.trim() === "") {
    fail(`${label}.category must be a non-empty string`);
  }
}

if (process.exitCode) {
  process.exit();
}

console.log(`marketplace validation passed: ${payload.plugins.length} plugin(s)`);
