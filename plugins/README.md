# Plugins

Local plugin packages owned by this marketplace live here.

Use this layout for a local plugin:

```text
plugins/<plugin-name>/
|-- .codex-plugin/plugin.json
|-- skills/
|   `-- <skill-name>/SKILL.md
|-- assets/
|-- scripts/
|-- .mcp.json
`-- .app.json
```

For plugins maintained in other repositories, prefer a `git-subdir` entry in
`.agents/plugins/marketplace.json` instead of copying files into this directory.
