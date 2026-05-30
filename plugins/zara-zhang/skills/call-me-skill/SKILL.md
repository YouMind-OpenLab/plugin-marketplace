---
name: call-me
description: Use when the user wants to set up a voice-first content capture agent that calls them on the phone, interviews them, and turns the conversation into publishable content like tweets and LinkedIn posts. Also use when the user says "call me", wants to schedule daily calls, or asks about generating content from phone conversations.
---

# Call Me — Voice-First Content Capture

A skill that calls you on the phone, has a conversation, and turns what you said into publishable content (tweets, LinkedIn posts, or any format you define).

## How It Works

1. An AI voice agent calls your phone at a scheduled time (or on demand)
2. You talk for a few minutes — the agent asks questions and draws out ideas
3. After the call, the transcript is processed into content drafts
4. Drafts are sent to you for review via your connected channel

Uses [Retell AI](https://retellai.com) for the phone calls. You need a Retell account and API key.

## First-Time Setup

If the user hasn't set this up before, read [ONBOARDING.md](ONBOARDING.md) and walk them through it step by step. Ask one question at a time.

**Check if already configured:** Look for these environment variables:
- `RETELL_API_KEY` — if missing, start onboarding
- `RETELL_AGENT_ID` — if missing, run automated setup
- `RETELL_FROM_NUMBER` — if missing, run automated setup
- `RETELL_KNOWLEDGE_BASE_ID` — optional, for agent memory

**Automated setup:** Once the user provides their Retell API key and interviewer style preferences, run `scripts/setup-agent.sh` to automatically create the knowledge base, LLM, and agent via API. The phone number must be purchased manually in the Retell dashboard (requires payment and ID verification).

**User context:** Don't ask the user for background info. Read OpenClaw's USER.md and memory system to compile context about the user, then push it to the Retell Knowledge Base via `scripts/sync-memory.sh`. This way the voice agent knows who it's talking to from the very first call.

## Triggering a Call

To call the user right now:

```bash
bash skills/call-me/scripts/trigger-call.sh
```

The script uses `RETELL_API_KEY`, `RETELL_AGENT_ID`, `RETELL_FROM_NUMBER`, and `YOUR_PHONE_NUMBER` from the environment.

## After the Call

After triggering a call, poll for the transcript:

```bash
bash skills/call-me/scripts/poll-transcript.sh <call_id>
```

This polls Retell every 30 seconds until the transcript is ready (max 10 minutes). Outputs the transcript to stdout.

## Generating Content

Once you have the transcript, generate drafts by reading the user's templates from `skills/call-me/templates/` and writing content in each format.

**Template files:** Each `.md` file in `templates/` is a prompt template. The filename is the content type (e.g., `tweet.md`, `linkedin.md`). Read each template, append the transcript, and generate content.

**Splitting drafts:** Generate multiple drafts per template. Separate each draft with `===SPLIT===` on its own line. Send each draft as a separate message to the user so they can approve/reject individually.

**Max drafts:** Cap at 10 drafts per template to avoid overwhelming the user.

## Memory Sync

After generating content, create a structured summary of the call and push it to the Retell Knowledge Base so the voice agent remembers past conversations:

```bash
bash skills/call-me/scripts/sync-memory.sh <knowledge_base_id> "<summary_text>"
```

The summary should include: key topics discussed, strong opinions, recurring themes, specific projects/people mentioned, and what content was generated.

## Setting Up the Cron Job

To schedule daily calls, use OpenClaw's built-in cron:

```bash
openclaw cron add \
  --name "call-me-daily" \
  --cron "<user's preferred schedule>" \
  --tz "<user's timezone>" \
  --session isolated \
  --message "Time for the daily Call Me session. Run the call-me skill: trigger a call, wait for the transcript, generate drafts from the templates, send each draft to the user, and sync the call summary to the knowledge base." \
  --announce
```

## User-Configurable Settings

Users can customize:

1. **Draft templates** — edit files in `skills/call-me/templates/`. Add new `.md` files for new formats
2. **Call schedule** — edit the cron job: `openclaw cron edit <job-id> --cron "0 9 * * *"`
3. **Voice agent personality** — update the agent prompt in the Retell dashboard
4. **Call frequency** — modify the cron expression
5. **Phone number** — change `YOUR_PHONE_NUMBER` in config
