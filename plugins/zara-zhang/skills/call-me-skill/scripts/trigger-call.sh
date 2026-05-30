#!/bin/bash
# Triggers an outbound phone call via Retell AI.
# Outputs the call_id on success (used by poll-transcript.sh to get the transcript).
#
# Required environment variables:
#   RETELL_API_KEY      — your Retell API key
#   RETELL_AGENT_ID     — the agent to use for the call
#   RETELL_FROM_NUMBER  — your Retell phone number (E.164)
#   YOUR_PHONE_NUMBER   — the number to call (E.164)

set -e

if [ -z "$RETELL_API_KEY" ] || [ -z "$RETELL_AGENT_ID" ] || [ -z "$RETELL_FROM_NUMBER" ] || [ -z "$YOUR_PHONE_NUMBER" ]; then
  echo "ERROR: Missing required environment variables." >&2
  echo "Need: RETELL_API_KEY, RETELL_AGENT_ID, RETELL_FROM_NUMBER, YOUR_PHONE_NUMBER" >&2
  exit 1
fi

response=$(curl -s -w "\n%{http_code}" -X POST "https://api.retellai.com/v2/create-phone-call" \
  -H "Authorization: Bearer $RETELL_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"from_number\": \"$RETELL_FROM_NUMBER\",
    \"to_number\": \"$YOUR_PHONE_NUMBER\",
    \"override_agent_id\": \"$RETELL_AGENT_ID\"
  }")

# Split response body and status code
http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
  call_id=$(echo "$body" | grep -o '"call_id":"[^"]*"' | head -1 | cut -d'"' -f4)
  echo "$call_id"
else
  echo "ERROR: Retell API returned $http_code" >&2
  echo "$body" >&2
  exit 1
fi
