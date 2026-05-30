#!/bin/bash
# Polls Retell API until a call's transcript is available.
# Waits up to 10 minutes, checking every 30 seconds.
# Outputs the plain-text transcript on success.
#
# Usage: poll-transcript.sh <call_id>
#
# Required environment variables:
#   RETELL_API_KEY — your Retell API key

set -e

CALL_ID="$1"
MAX_ATTEMPTS=20   # 20 attempts x 30 seconds = 10 minutes
INTERVAL=30       # seconds between polls

if [ -z "$CALL_ID" ]; then
  echo "ERROR: Usage: poll-transcript.sh <call_id>" >&2
  exit 1
fi

if [ -z "$RETELL_API_KEY" ]; then
  echo "ERROR: RETELL_API_KEY not set" >&2
  exit 1
fi

attempt=0
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  attempt=$((attempt + 1))

  response=$(curl -s -X GET "https://api.retellai.com/v2/get-call/$CALL_ID" \
    -H "Authorization: Bearer $RETELL_API_KEY")

  # Check if transcript field exists and is non-empty
  transcript=$(echo "$response" | grep -o '"transcript":"[^"]*"' | head -1 | cut -d'"' -f4)
  call_status=$(echo "$response" | grep -o '"call_status":"[^"]*"' | head -1 | cut -d'"' -f4)

  if [ -n "$transcript" ] && [ "$transcript" != "null" ]; then
    # Unescape the JSON string (newlines are \n in JSON)
    echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript',''))"
    exit 0
  fi

  # If call ended with an error, stop polling
  if [ "$call_status" = "error" ]; then
    echo "ERROR: Call ended with error status" >&2
    echo "$response" >&2
    exit 1
  fi

  echo "Waiting for transcript... (attempt $attempt/$MAX_ATTEMPTS)" >&2
  sleep $INTERVAL
done

echo "ERROR: Timed out waiting for transcript after $((MAX_ATTEMPTS * INTERVAL)) seconds" >&2
exit 1
