#!/bin/bash
# Pushes a call summary to a Retell Knowledge Base.
# This gives the voice agent memory across calls.
#
# Usage: sync-memory.sh <knowledge_base_id> "<summary text>"
#
# Required environment variables:
#   RETELL_API_KEY — your Retell API key

set -e

KB_ID="$1"
SUMMARY="$2"

if [ -z "$KB_ID" ] || [ -z "$SUMMARY" ]; then
  echo "ERROR: Usage: sync-memory.sh <knowledge_base_id> \"<summary>\"" >&2
  exit 1
fi

if [ -z "$RETELL_API_KEY" ]; then
  echo "ERROR: RETELL_API_KEY not set" >&2
  exit 1
fi

# Create a title with today's date
TITLE="Call on $(date '+%A, %B %d, %Y')"

# Use a temp file for the JSON payload to handle special characters safely
PAYLOAD_FILE=$(mktemp)
python3 -c "
import json, sys
payload = json.dumps({
    'knowledge_base_texts': [{'title': sys.argv[1], 'text': sys.argv[2]}]
})
print(payload)
" "$TITLE" "$SUMMARY" > "$PAYLOAD_FILE"

response=$(curl -s -w "\n%{http_code}" -X POST \
  "https://api.retellai.com/add-knowledge-base-sources/$KB_ID" \
  -H "Authorization: Bearer $RETELL_API_KEY" \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD_FILE")

rm -f "$PAYLOAD_FILE"

http_code=$(echo "$response" | tail -1)

if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
  echo "Memory synced: $TITLE"
else
  echo "ERROR: Failed to sync memory (HTTP $http_code)" >&2
  echo "$response" | sed '$d' >&2
  exit 1
fi
