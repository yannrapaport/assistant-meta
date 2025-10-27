---
description: Save or update an assistant to Notion and git
---

Save a new assistant or update an existing one with automatic token optimization.

**Usage:**
- `/save-assistant` - Interactive mode
- `/save-assistant <assistant-name>` - Update specific assistant

**Your task:**

## Step 0: Ensure Meta Assistant is Loaded

**IMPORTANT:** Before proceeding, check if Meta Assistant is currently active.

If Meta Assistant is not loaded:
1. Load it first: `/load-assistant meta`
2. Wait for it to load completely
3. Then proceed with the save-assistant logic below

If Meta Assistant is already loaded, proceed directly to Step 1.

## Step 1: Determine Intent

Use AskUserQuestion to ask:
- **Create a new assistant** - Start fresh
- **Update an existing assistant** - Modify current assistant
- **Compact an assistant** - Optimize token usage only

## Step 2a: Create New Assistant

If creating new:

1. **Check if creation script should be used:**
   - Recommend using `~/Documents/Dev/assistant-meta/tools/create-assistant-repo.sh`
   - Or proceed with manual creation if user prefers

2. **Gather metadata** using AskUserQuestion (with smart defaults):
   - **Name**: Default from context if obvious
   - **Slug**: Suggest kebab-case from name (e.g., "Git Assistant" → "git-assistant")
   - **Description**: Propose based on conversation (1-2 sentences)
   - **Category**: Content Creation, Product Management, Technical/Development, Meta
   - **Status**: Idea, Draft, Ready (default: Draft)
   - **Expert References**: Optional

3. **Get content:**
   - Ask user to provide full prompt
   - Or extract from current conversation
   - Or load from file

4. **Compact before saving** (if >300 words):
   - Load `docs/compacting.md` for guidance
   - Extract verbose content to docs/
   - Create minimal core assistant.md
   - Target: 200-350 words

5. **Create repository structure:**
   ```bash
   SLUG="assistant-name"
   REPO_DIR=~/Documents/Dev/assistant-$SLUG

   mkdir -p "$REPO_DIR"/{commands,tools,docs}
   cd "$REPO_DIR"

   # Create assistant.md (compacted)
   echo "$COMPACTED_CONTENT" > assistant.md

   # Create extracted docs
   echo "$API_DOCS" > docs/notion-api.md  # if applicable
   echo "$WORKFLOWS" > docs/workflows.md  # if applicable

   # Create .meta
   cat > .meta << EOF
{
  "notion_page_id": "",
  "last_sync_hash": "",
  "last_sync_date": ""
}
EOF

   # Initialize git
   git init
   git add .
   git commit -m "Initial commit: $NAME assistant"
   ```

6. **Save to Notion:**
   ```bash
   source ~/.config/claude-code/notion-config.sh
   DATABASE_ID="29686de33aad807fbea3edb4899d1d2b"

   # Get GitHub URL from git remote if available
   GITHUB_URL=$(git remote get-url origin 2>/dev/null || echo "")

   # Parse assistant.md into Notion blocks
   # (Use python script or manual construction)

   RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/pages" \
     -H "Authorization: Bearer $NOTION_API_KEY" \
     -H "Notion-Version: $NOTION_VERSION" \
     -H "Content-Type: application/json" \
     -d "{
       \"parent\": { \"database_id\": \"$DATABASE_ID\" },
       \"properties\": {
         \"Nom\": { \"title\": [{ \"text\": { \"content\": \"$NAME\" } }] },
         \"Description\": { \"rich_text\": [{ \"text\": { \"content\": \"$DESCRIPTION\" } }] },
         \"Category\": { \"select\": { \"name\": \"$CATEGORY\" } },
         \"Status\": { \"select\": { \"name\": \"$STATUS\" } },
         \"github\": { \"url\": \"$GITHUB_URL\" }
       },
       \"children\": $BLOCKS
     }")

   # Extract page ID from response
   PAGE_ID=$(echo "$RESPONSE" | jq -r '.id' | tr -d '-')

   # Update .meta with Notion page ID
   jq ".notion_page_id = \"$PAGE_ID\" | .last_sync_hash = \"$(git rev-parse HEAD)\" | .last_sync_date = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" .meta > .meta.tmp
   mv .meta.tmp .meta

   git add .meta
   git commit -m "Link to Notion: $PAGE_ID"
   ```

7. **Report success:**
   - Show word count reduction (if compacted)
   - Display file path: `$REPO_DIR/assistant.md`
   - Display Notion URL: `https://notion.so/[page-id]`
   - Suggest: "Load with `/load-assistant $SLUG`"

## Step 2b: Update Existing Assistant

If updating:

1. **Find assistant to update:**

   If argument provided, use it:
   ```bash
   SLUG="$1"
   REPO_DIR=~/Documents/Dev/assistant-$SLUG
   ```

   Otherwise, list available assistants:
   ```bash
   ls -d ~/Documents/Dev/assistant-* | xargs -n1 basename
   ```

2. **Check if sync needed:**
   ```bash
   cd "$REPO_DIR"

   if [ ! -f .meta ]; then
       echo "Warning: .meta file missing. Will create after sync."
   else
       CURRENT_HASH=$(git rev-parse HEAD 2>/dev/null || echo "")
       LAST_SYNC_HASH=$(jq -r '.last_sync_hash' .meta 2>/dev/null || echo "")

       if [ "$CURRENT_HASH" = "$LAST_SYNC_HASH" ] && [ -n "$CURRENT_HASH" ]; then
           echo "Already synced - no changes since last sync"
           # Ask if user wants to continue anyway
       fi
   fi
   ```

3. **Propose updates:**
   - Read current assistant.md
   - Review conversation for improvements
   - Show specific proposed changes
   - Get user approval

4. **Update local file:**
   ```bash
   # Apply changes using Edit tool
   # Or rewrite with Write tool if major changes
   ```

5. **Compact if needed** (if word count grew >30%):
   - Check current vs original word count
   - If >300 words or >30% growth, suggest compacting
   - Load `docs/compacting.md` for guidance
   - Extract new verbose content to docs/

6. **Commit changes:**
   ```bash
   git add assistant.md docs/
   git commit -m "Update: [description of changes]"
   ```

7. **Sync to Notion** (only if changes made):
   ```bash
   PAGE_ID=$(jq -r '.notion_page_id' .meta)

   # Get GitHub URL from git remote if available
   GITHUB_URL=$(git remote get-url origin 2>/dev/null || echo "")

   if [ -z "$PAGE_ID" ] || [ "$PAGE_ID" = "null" ]; then
       echo "No Notion page linked. Create new page? (y/n)"
       # If yes, create new page (same as Step 2a #6)
   else
       # Update existing page properties
       curl -X PATCH "https://api.notion.com/v1/pages/$PAGE_ID" \
         -H "Authorization: Bearer $NOTION_API_KEY" \
         -H "Notion-Version: $NOTION_VERSION" \
         -H "Content-Type: application/json" \
         -d "{
           \"properties\": {
             \"Description\": { \"rich_text\": [{ \"text\": { \"content\": \"$DESCRIPTION\" } }] },
             \"Status\": { \"select\": { \"name\": \"$STATUS\" } },
             \"github\": { \"url\": \"$GITHUB_URL\" }
           }
         }"

       # Update content blocks (archive old, append new)
       # Or use full page replacement
   fi

   # Update .meta
   jq ".last_sync_hash = \"$(git rev-parse HEAD)\" | .last_sync_date = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" .meta > .meta.tmp
   mv .meta.tmp .meta

   git add .meta
   git commit -m "Sync to Notion: $(date +%Y-%m-%d)"
   ```

8. **Report success:**
   - Show changes made
   - Display word count (before/after if compacted)
   - Confirm sync status

## Step 2c: Compact Assistant Only

If compacting only:

1. **Load compacting guide:**
   - Read `docs/compacting.md` for detailed process

2. **Find assistant:**
   ```bash
   ls -d ~/Documents/Dev/assistant-* | xargs -n1 basename
   ```

3. **Analyze current assistant:**
   ```bash
   cd ~/Documents/Dev/assistant-$SLUG
   ORIGINAL_WORDS=$(wc -w < assistant.md)
   echo "Current: $ORIGINAL_WORDS words"

   # Check if already compact
   if [ "$ORIGINAL_WORDS" -lt 300 ]; then
       echo "Already compact (<300 words)"
       exit 0
   fi
   ```

4. **Extract verbose content:**
   - Identify API docs, workflows, examples
   - Extract to docs/notion-api.md, docs/workflows.md, etc.
   - Replace with references in assistant.md

5. **Rewrite core assistant:**
   - Keep only essential content
   - Target: 200-350 words
   - Maintain functionality with references

6. **Verify & commit:**
   ```bash
   NEW_WORDS=$(wc -w < assistant.md)
   REDUCTION=$(( ($ORIGINAL_WORDS - $NEW_WORDS) * 100 / $ORIGINAL_WORDS ))

   git add assistant.md docs/
   git commit -m "Compact assistant: $ORIGINAL_WORDS → $NEW_WORDS words (-$REDUCTION%)"
   ```

7. **Optionally sync to Notion:**
   - Ask user if they want to sync compacted version
   - If yes, follow Step 2b #7

## Smart Defaults

**When gathering metadata, propose defaults based on context:**

- **Name**: Extract from conversation or current directory
- **Slug**: Convert name to kebab-case
- **Description**: Summarize conversation topic (1-2 sentences)
- **Category**: Infer from conversation:
  - Git/code/dev topics → "Technical/Development"
  - Content/writing/posts → "Content Creation"
  - Product/features/ideas → "Product Management"
  - Assistants/meta/config → "Meta"
- **Status**: "Draft" for new, keep existing for updates

**Present defaults to user for quick confirmation rather than asking each individually.**

## Local-First Principle

**Always prioritize git over Notion:**

1. Save to git repository first
2. Commit changes
3. Sync to Notion second (optional)
4. Update .meta to track sync status
5. Never fetch from Notion unless explicitly requested

**Only sync to Notion when:**
- User explicitly requests it
- Changes have been made since last sync (check .meta)
- Creating a new assistant for the first time

## Token Optimization

**Always compact when saving if:**
- Word count > 300 words
- Contains >3 code blocks
- Has verbose API documentation
- Includes detailed workflows

**Target reduction:** 50-70%

**Report savings:** "[X] → [Y] words (-[Z]%)"

## Verification

Before finishing, verify:
- ✅ Git repository initialized/updated
- ✅ Changes committed
- ✅ .meta file created/updated
- ✅ Word count reduced (if compacted)
- ✅ Notion synced (if requested)
- ✅ File paths and URLs provided to user

Be efficient and clear. Don't over-explain - focus on execution.
