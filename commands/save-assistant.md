---
description: Save or update an assistant's context to Notion and git
---

Save a new assistant or update an existing one based on the current conversation.

**Usage:**
- `/save-assistant` - Interactive mode

**Your task:**

## Step 1: Check Sync Status

First, verify that Notion and git are in sync:

```bash
# Load configuration
source ~/.config/claude-code/notion-config.sh

# Get list of local assistants
LOCAL_ASSISTANTS=$(ls ~/Documents/Dev/claude-code-config/contexts/*.md | grep -v "README\|notion-database" | xargs -I {} basename {} .md)

# Query Notion database for all assistants
DATABASE_ID="29686de33aad807fbea3edb4899d1d2b"
NOTION_ASSISTANTS=$(curl -s -X POST "https://api.notion.com/v1/databases/$DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H "Content-Type: application/json" | jq -r '.results[].properties.Name.title[0].text.content')

# Compare the two lists
# Warn if there are differences
```

If there's a mismatch, inform the user and ask if they want to continue.

## Step 2: Ask User's Intent

Use AskUserQuestion to ask:
- **Create a new assistant** - Start fresh with new context
- **Update an existing assistant** - Improve/modify an existing one

## Step 3a: Create New Assistant

If creating new:

1. **Gather metadata** using AskUserQuestion:
   - Name
   - Description
   - Category (Content Creation, Product Management, Technical/Development, Meta)
   - Status (Idea, Draft, Ready)
   - Expert References (optional)

2. **Get content:**
   - Ask user to provide the full context/prompt
   - Or offer to extract from current conversation

3. **Save to both locations:**
   ```bash
   # Save to local file
   echo "$CONTENT" > ~/Documents/Dev/claude-code-config/contexts/XX-assistant-name.md

   # Convert and save to Notion
   python3 ~/Documents/Dev/claude-code-config/convert-md-to-notion.py \
     ~/Documents/Dev/claude-code-config/contexts/XX-assistant-name.md > /tmp/notion-blocks.json

   BLOCKS=$(cat /tmp/notion-blocks.json | jq -c '.children')

   curl -s -X POST "https://api.notion.com/v1/pages" \
     -H "Authorization: Bearer $NOTION_API_KEY" \
     -H "Notion-Version: $NOTION_VERSION" \
     -H "Content-Type: application/json" \
     -d "{
       \"parent\": { \"database_id\": \"$DATABASE_ID\" },
       \"properties\": {
         \"Name\": { \"title\": [{ \"text\": { \"content\": \"$NAME\" } }] },
         \"Description\": { \"rich_text\": [{ \"text\": { \"content\": \"$DESCRIPTION\" } }] },
         \"Category\": { \"select\": { \"name\": \"$CATEGORY\" } },
         \"Status\": { \"select\": { \"name\": \"$STATUS\" } }
       },
       \"children\": $BLOCKS
     }"
   ```

## Step 3b: Update Existing Assistant

If updating:

1. **Show list of assistants** from local directory:
   ```bash
   ls ~/Documents/Dev/claude-code-config/contexts/*.md | grep -v "README\|notion-database"
   ```

2. **Let user select** which assistant to update

3. **Read current content** of that assistant

4. **Analyze conversation** and propose updates:
   - Review the conversation history
   - Identify new learnings, patterns, or improvements
   - Propose specific changes to the assistant's context

5. **Show proposed changes** to user for approval

6. **Update both locations** if approved:
   ```bash
   # Update local file
   echo "$UPDATED_CONTENT" > ~/Documents/Dev/claude-code-config/contexts/XX-assistant-name.md

   # Update Notion page
   # First get the page ID from the database
   # Then use the sync script
   cd ~/Documents/Dev/context-manager/scripts
   PAGE_ID="..." ./sync-to-notion.sh
   ```

## Step 4: Confirm Success

- Show confirmation message
- Display both locations (file path and Notion URL)
- Suggest next steps (e.g., "You can now load this assistant with `/load-assistant <url>`")

**Important:**
- Always maintain sync between git and Notion
- Warn if sync check fails
- Be smart about extracting relevant content from conversation
- Don't lose existing content when updating

Be efficient and clear in your communication.
