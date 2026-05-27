# Plugin Marketplace

A Codex-compatible marketplace for curated agent plugins, including skills,
MCP servers, apps, and related agent capabilities.

This repository starts with the native Codex marketplace format:

```text
.agents/plugins/marketplace.json
plugins/
```

## Use With Codex

Add this marketplace from a local checkout:

```bash
codex plugin marketplace add /Users/ganlin/Projects/plugin-marketplace
```

After the repository is published, add it from GitHub:

```bash
codex plugin marketplace add youmind-openlab/plugin-marketplace
```

## Structure

```text
.
|-- .agents/plugins/marketplace.json
|-- plugins/
|-- scripts/validate-marketplace.mjs
`-- docs/adding-plugins.md
```

## Marketplace Policy

- Keep marketplace entries in `.agents/plugins/marketplace.json`.
- Prefer `git-subdir` sources when indexing plugins maintained in external repositories.
- Use local `./plugins/<plugin-name>` sources when this repository owns the plugin package.
- Every plugin entry must include `name`, `source`, `policy`, and `category`.
- `policy.installation` defaults to `AVAILABLE`.
- `policy.authentication` defaults to `ON_INSTALL`.

## Validate

```bash
node scripts/validate-marketplace.mjs
```
