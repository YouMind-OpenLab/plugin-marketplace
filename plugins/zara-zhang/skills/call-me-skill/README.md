# Call Me

A voice-first content capture skill for AI agents.

Your agent calls you on the phone, has a conversation, and turns what you said into publishable content (tweets, LinkedIn posts, or any format you define).

## How It Works

1. Your agent triggers a phone call via Retell AI
2. You talk for a few minutes — the voice agent asks questions and draws out your ideas
3. After you hang up, your agent processes the transcript into content drafts
4. Drafts are sent to you for review via your preferred channel
5. The conversation is saved to the voice agent's memory for better future calls

## Requirements

- A [Retell AI](https://retellai.com) account (for phone calls)
- An AI agent platform (OpenClaw, Claude Code, or any agent with bash access)

## Installation

### OpenClaw

Copy the `call-me` directory to `~/.openclaw/workspace/skills/`:

```bash
cp -r call-me-skill ~/.openclaw/workspace/skills/call-me
```

Then tell your agent: "Set up Call Me" — it will walk you through onboarding.

### Claude Code

Add to your project's `.claude/skills/` directory or `~/.claude/skills/`.

## Configuration

After onboarding, your `openclaw.json` will have:

```json
{
  "skills": {
    "entries": {
      "call-me": {
        "env": {
          "RETELL_API_KEY": "key_...",
          "RETELL_AGENT_ID": "agent_...",
          "RETELL_FROM_NUMBER": "+1...",
          "YOUR_PHONE_NUMBER": "+1...",
          "RETELL_KNOWLEDGE_BASE_ID": "knowledge_base_..."
        }
      }
    }
  }
}
```

## Customization

- **Templates:** Edit files in `templates/` to change how content is generated. Add new `.md` files for new formats.
- **Schedule:** Modify the cron job to change call frequency.
- **Voice agent:** Update the agent prompt in the Retell dashboard to change the interviewer's style.

## License

MIT
