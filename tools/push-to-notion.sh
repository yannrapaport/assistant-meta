#!/bin/bash
# Sync any assistant.md to its Notion page
# Usage: push-to-notion.sh [assistant-dir]

set -e

# Determine assistant directory
if [ -n "$1" ]; then
    ASSISTANT_DIR="$1"
else
    ASSISTANT_DIR="$(pwd)"
fi

cd "$ASSISTANT_DIR"

# Verify we're in an assistant directory
if [ ! -f assistant.md ]; then
    echo "Error: assistant.md not found in $ASSISTANT_DIR"
    exit 1
fi

if [ ! -f .meta ]; then
    echo "Error: .meta file not found. Run from assistant directory."
    exit 1
fi

# Extract PAGE_ID from .meta
PAGE_ID=$(jq -r '.notion_page_id' .meta)

if [ -z "$PAGE_ID" ] || [ "$PAGE_ID" = "null" ]; then
    echo "Error: No Notion page linked in .meta"
    echo "Run /save-assistant first to create a Notion page"
    exit 1
fi

# Load Notion config
source ~/.config/claude-code/notion-config.sh

# Get script directory to find sync-to-notion.py
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Generate blocks JSON
python3 "$SCRIPT_DIR/sync-to-notion.py" assistant.md > blocks.json

# Append to Notion page
BLOCKS=$(cat blocks.json)

RESPONSE=$(curl -s -X PATCH "https://api.notion.com/v1/blocks/$PAGE_ID/children" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d "{\"children\": $BLOCKS}")

# Check for errors
if echo "$RESPONSE" | jq -e '.object == "error"' > /dev/null 2>&1; then
    echo "Error syncing to Notion:"
    echo "$RESPONSE" | jq '.message'
    rm blocks.json
    exit 1
fi

echo "✓ Synced to Notion: https://notion.so/$PAGE_ID"

# Update .meta
CURRENT_HASH=$(git rev-parse HEAD 2>/dev/null || echo "no-git")
SYNC_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq ".last_sync_hash = \"$CURRENT_HASH\" | .last_sync_date = \"$SYNC_DATE\"" .meta > .meta.tmp
mv .meta.tmp .meta

echo "✓ Updated .meta tracking"

# Cleanup
rm blocks.json
