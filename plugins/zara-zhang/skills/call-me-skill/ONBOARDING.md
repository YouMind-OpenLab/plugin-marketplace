# Call Me — Onboarding Guide

Get the user to a working test call as fast as possible. Details come after the aha moment.

## Phase 1: Get to First Call (3 steps)

### Step 1: Retell Account & API Key

Ask: "Do you have a Retell AI account? If not, sign up at https://retellai.com — it takes 30 seconds."

Then: "Go to your Retell dashboard → Settings → API Keys, and paste your API key here."

Save the key to `~/.openclaw/openclaw.json` under `skills.entries.call-me.env.RETELL_API_KEY`.

### Step 2: Phone Number

Ask: "Now you need a phone number for the agent to call from. In the Retell dashboard → Phone Numbers → Buy Number. You'll need to verify your identity (one-time). Pick any number and paste it here."

Then: "What's your personal phone number the agent should call?"

Save both as `RETELL_FROM_NUMBER` and `YOUR_PHONE_NUMBER`.

### Step 3: Test Call

Use the "podcast host" preset as the default — it works well for most people.

Create the agent automatically:

```bash
bash skills/call-me/scripts/setup-agent.sh "<podcast host prompt>" "Hey! What's on your mind today?"
```

Default podcast host prompt:
```
You're a podcast host interviewing someone about their ideas and observations. Be curious, encouraging, and conversational. Ask one question at a time. Follow up on interesting threads. Keep it to about 5 minutes. Wrap up naturally when they seem done.
```

Save the returned `agent_id` and `knowledge_base_id` to env config.

Seed user context from OpenClaw's USER.md and memory:

```bash
bash skills/call-me/scripts/sync-memory.sh "$RETELL_KNOWLEDGE_BASE_ID" "<compiled user context>"
```

Then trigger the test call:

```bash
call_id=$(bash skills/call-me/scripts/trigger-call.sh)
```

Tell the user: "Calling you now! Talk for a minute about whatever's on your mind, then hang up."

After the call, poll for transcript, generate drafts, send to user.

Tell the user: "Here are your first drafts! You can customize everything from here."

---

## Phase 2: Customize (after the aha moment)

### Interviewer Style

Ask: "Want to change how the interviewer sounds? Current default is 'podcast host'. Options:

- **Podcast host** (current) — curious, encouraging, draws out stories
- **Socratic coach** — challenges your thinking, asks probing questions
- **Quick capture** — stays quiet, lets you talk, minimal questions
- **Custom** — describe your own style"

Preset prompts:

**Podcast host:**
```
You're a podcast host interviewing someone about their ideas and observations. Be curious, encouraging, and conversational. Ask one question at a time. Follow up on interesting threads. Keep it to about 5 minutes. Wrap up naturally when they seem done.
```

**Socratic coach:**
```
You're a thinking partner who helps sharpen ideas. When someone makes a claim, ask them to defend it or find the nuance. Push for the contrarian angle. Ask one question at a time. Keep it to 5 minutes. Be direct but supportive.
```

**Quick capture:**
```
You're helping someone capture their thoughts. Keep it minimal. Let them talk. Only ask a short follow-up if something is interesting or unclear. Keep your responses very short. Wrap up after 3-5 minutes.
```

If they choose **Custom**, ask them to describe the style and write a prompt.

To update the agent's prompt, use the Retell API to update the LLM:

```bash
curl -X PATCH "https://api.retellai.com/update-retell-llm/$LLM_ID" \
  -H "Authorization: Bearer $RETELL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"general_prompt": "<new prompt>"}'
```

### Draft Templates

Ask: "Want to customize what content gets generated? You can edit the prompts or add new formats."

- Templates live in `skills/call-me/templates/`
- `tweet.md` — tweet generation prompt
- `linkedin.md` — LinkedIn post prompt
- Add any new `.md` file for a new format (e.g., `newsletter.md`, `rednote.md`)

### Schedule

Ask: "When should the agent call you?"

Common options:
- `0 9 * * *` — 9:00 AM daily
- `0 9 * * 1-5` — 9:00 AM weekdays
- `0 22 * * *` — 10:00 PM daily

```bash
openclaw cron add \
  --name "call-me-daily" \
  --cron "<expression>" \
  --tz "<timezone>" \
  --session isolated \
  --message "Run the call-me skill: trigger a call, poll for transcript, generate drafts from templates, send each draft to the user, sync call summary to knowledge base." \
  --announce
```

### Voice

Ask: "Want to try a different voice? You can change it in the Retell dashboard → your agent → Voice settings."

---

## Environment Variables Summary

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
          "RETELL_KNOWLEDGE_BASE_ID": "knowledge_base_...",
          "RETELL_LLM_ID": "llm_..."
        }
      }
    }
  }
}
```
