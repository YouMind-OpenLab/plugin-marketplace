# Baoyu

This plugin vendors the public skills from [JimLiu/baoyu-skills](https://github.com/JimLiu/baoyu-skills).

The upstream repository describes these as AI Agent skills for Claude Code, Codex, and compatible runtimes. This marketplace plugin exposes the upstream `skills/baoyu-*` directories as one installable plugin while preserving each skill as an individually browsable marketplace item.

## Included Skills

- `baoyu-article-illustrator`
- `baoyu-comic`
- `baoyu-compress-image`
- `baoyu-cover-image`
- `baoyu-danger-gemini-web`
- `baoyu-danger-x-to-markdown`
- `baoyu-diagram`
- `baoyu-electron-extract`
- `baoyu-format-markdown`
- `baoyu-image-gen`
- `baoyu-infographic`
- `baoyu-markdown-to-html`
- `baoyu-post-to-weibo`
- `baoyu-post-to-wechat`
- `baoyu-post-to-x`
- `baoyu-slide-deck`
- `baoyu-translate`
- `baoyu-url-to-markdown`
- `baoyu-wechat-summary`
- `baoyu-xhs-images`
- `baoyu-youtube-transcript`

## Notes

- The upstream `.claude/skills/release-skills` helper is not included as a user-facing skill because upstream's marketplace manifest does not publish it.
- `packages/baoyu-codex-imagegen` is included because some image-generation references look for that helper from the plugin root.
