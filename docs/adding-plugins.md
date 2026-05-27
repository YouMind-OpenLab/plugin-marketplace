# Adding Plugins

The marketplace supports two common entry styles.

## Local Plugin

Use this when the plugin package is maintained in this repository:

```json
{
  "name": "example-plugin",
  "source": {
    "source": "local",
    "path": "./plugins/example-plugin"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

The plugin package must include:

```text
plugins/example-plugin/.codex-plugin/plugin.json
```

## External Git Subdirectory

Use this when the plugin package is maintained in another Git repository:

```json
{
  "name": "example-plugin",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/example/codex-plugins.git",
    "path": "./plugins/example-plugin",
    "ref": "main"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

## Required Entry Fields

- `name`: plugin identifier, kebab-case preferred.
- `source`: plugin source descriptor.
- `policy.installation`: `AVAILABLE`, `NOT_AVAILABLE`, or `INSTALLED_BY_DEFAULT`.
- `policy.authentication`: `ON_INSTALL` or `ON_USE`.
- `category`: display category.
