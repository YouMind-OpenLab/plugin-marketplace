#!/bin/bash
# Creates the Retell LLM, knowledge base, and agent via API.
# Phone number must be purchased manually in the Retell dashboard
# (requires payment and ID verification).
#
# Outputs JSON with the IDs to save in config.
#
# Usage: setup-agent.sh "<system_prompt>" "<begin_message>" [voice_id]
#
# Required environment variables:
#   RETELL_API_KEY — your Retell API key
#
# Defaults:
#   voice_id: 11labs-Adrian

set -e

SYSTEM_PROMPT="$1"
BEGIN_MESSAGE="${2:-Hey! What's on your mind today?}"
VOICE_ID="${3:-11labs-Adrian}"

if [ -z "$RETELL_API_KEY" ]; then
  echo "ERROR: RETELL_API_KEY not set" >&2
  exit 1
fi

if [ -z "$SYSTEM_PROMPT" ]; then
  echo "ERROR: Usage: setup-agent.sh \"<system_prompt>\" [\"<begin_message>\"] [voice_id]" >&2
  exit 1
fi

API="https://api.retellai.com"
AUTH="Authorization: Bearer $RETELL_API_KEY"

echo "Setting up Retell agent..." >&2

# Step 1: Create knowledge base for agent memory
echo "Creating knowledge base..." >&2
kb_response=$(curl -s -X POST "$API/create-knowledge-base" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"knowledge_base_name": "Call Me Memory"}')

KB_ID=$(echo "$kb_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['knowledge_base_id'])")
echo "Knowledge base: $KB_ID" >&2

# Step 2: Create the LLM with the system prompt
echo "Creating LLM..." >&2
llm_payload=$(python3 -c "
import json, sys
print(json.dumps({
    'model': 'gpt-4.1',
    'general_prompt': sys.argv[1],
    'begin_message': sys.argv[2],
    'start_speaker': 'agent',
    'model_temperature': 0.7,
    'knowledge_base_ids': [sys.argv[3]],
    'general_tools': [{'type': 'end_call', 'name': 'end_call', 'description': 'End the call when the conversation is done.'}]
}))
" "$SYSTEM_PROMPT" "$BEGIN_MESSAGE" "$KB_ID")

llm_response=$(curl -s -X POST "$API/create-retell-llm" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d "$llm_payload")

LLM_ID=$(echo "$llm_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['llm_id'])")
echo "LLM: $LLM_ID" >&2

# Step 3: Create the agent
echo "Creating agent..." >&2
agent_payload=$(python3 -c "
import json, sys
print(json.dumps({
    'agent_name': 'Call Me Agent',
    'response_engine': {'type': 'retell-llm', 'llm_id': sys.argv[1]},
    'voice_id': sys.argv[2],
    'language': 'en-US'
}))
" "$LLM_ID" "$VOICE_ID")

agent_response=$(curl -s -X POST "$API/create-agent" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d "$agent_payload")

AGENT_ID=$(echo "$agent_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['agent_id'])")
echo "Agent: $AGENT_ID" >&2

# Output all IDs as JSON
echo ""
python3 -c "
import json
print(json.dumps({
    'knowledge_base_id': '$KB_ID',
    'llm_id': '$LLM_ID',
    'agent_id': '$AGENT_ID'
}, indent=2))
"
