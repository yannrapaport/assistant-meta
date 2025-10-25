# Assistant Management Workflows

Detailed step-by-step workflows for common assistant management tasks.

## Creating a New Assistant Repository

**Use the creation script:**
```bash
~/Documents/Dev/assistant-meta/tools/create-assistant-repo.sh
```

**Manual Steps:**

1. **Initialize repository structure**
   ```bash
   SLUG="example"
   mkdir -p ~/Documents/Dev/assistant-$SLUG/{commands,tools,docs}
   cd ~/Documents/Dev/assistant-$SLUG
   ```

2. **Create core files**
   - `assistant.md` - Main assistant prompt
   - `README.md` - Documentation
   - `TODO.md` - Task tracking
   - `.meta` - Sync tracking
   - `install.sh` - Bootstrap installer

3. **Initialize git**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: $NAME assistant"
   ```

4. **Create GitHub repository** (optional)
   ```bash
   gh repo create assistant-$SLUG --private
   git push -u origin main
   ```

## Saving a New Assistant to Notion

**Prerequisites:**
- Assistant content in `assistant.md`
- Metadata ready (name, description, category, status)
- Notion API configured

**Steps:**

1. **Gather metadata** (if not provided)
   - Assistant name (title)
   - Description (1-2 sentences)
   - Category: Content Creation, Product Management, Technical/Development, Meta
   - Status: Idea, Draft, Ready
   - Expert references (optional)

2. **Parse assistant.md into Notion blocks**
   - Convert markdown headings to heading blocks
   - Convert paragraphs to paragraph blocks
   - Convert code blocks to code blocks with language
   - Convert lists to bulleted_list_item or numbered_list_item

3. **Create JSON payload**
   - See `docs/notion-api.md` for structure
   - Set database parent
   - Set properties
   - Add children blocks

4. **Execute API call**
   ```bash
   source ~/.config/claude-code/notion-config.sh
   curl -X POST "https://api.notion.com/v1/pages" \
     -H "Authorization: Bearer $NOTION_API_KEY" \
     -H "Notion-Version: $NOTION_VERSION" \
     -H "Content-Type: application/json" \
     -d @payload.json
   ```

5. **Update .meta file**
   ```bash
   NOTION_PAGE_ID="extracted-from-response"
   GIT_HASH=$(git rev-parse HEAD)
   echo "{
     \"notion_page_id\": \"$NOTION_PAGE_ID\",
     \"last_sync_hash\": \"$GIT_HASH\",
     \"last_sync_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
   }" > .meta
   git add .meta
   git commit -m "Sync to Notion: $NOTION_PAGE_ID"
   ```

6. **Verify and return**
   - Confirm creation success
   - Return Notion page URL
   - Assistant ready for `/load-assistant`

## Updating an Existing Assistant

**Check if sync needed:**
```bash
# Compare git hash with .meta
CURRENT_HASH=$(git rev-parse HEAD)
LAST_SYNC_HASH=$(jq -r '.last_sync_hash' .meta)

if [ "$CURRENT_HASH" != "$LAST_SYNC_HASH" ]; then
  echo "Sync needed: changes since last sync"
else
  echo "Already synced: no changes"
fi
```

**Update workflow:**

1. **Get page ID from .meta**
   ```bash
   PAGE_ID=$(jq -r '.notion_page_id' .meta)
   ```

2. **Update properties** (if metadata changed)
   ```bash
   curl -X PATCH "https://api.notion.com/v1/pages/$PAGE_ID" \
     -H "Authorization: Bearer $NOTION_API_KEY" \
     -H "Notion-Version: $NOTION_VERSION" \
     -H "Content-Type: application/json" \
     -d '{"properties": {...}}'
   ```

3. **Update content** (if assistant.md changed)
   - Fetch existing blocks
   - Archive old blocks
   - Append new blocks
   - Or replace entire page content

4. **Update .meta and commit**
   ```bash
   # Update .meta with new hash and timestamp
   git add .meta
   git commit -m "Sync changes to Notion"
   ```

5. **Verify sync**
   - Check Notion page updated
   - Confirm git and Notion in sync

## Local-First Loading

**Priority order for `/load-assistant`:**

1. **Check current directory**: `./.meta`, `./assistant.md`
2. **Check assistant directories**: `./assistant-*/assistant.md`
3. **Check home directory**: `~/Documents/Dev/assistant-*/assistant.md`
4. **Check by name**: Match against known assistants
5. **Fall back to Notion**: Only if local not found

**Caching strategy:**
```bash
# Check if already loaded
CACHE_FILE=~/.config/claude-code/assistant-cache.json
CURRENT_HASH=$(git rev-parse HEAD)
CACHED_HASH=$(jq -r ".\"$ASSISTANT_NAME\".hash" "$CACHE_FILE")

if [ "$CURRENT_HASH" = "$CACHED_HASH" ]; then
  echo "Assistant unchanged, skip reload"
  exit 0
fi
```

## Lazy Loading Extensions

**Load core only by default**, then auto-load extensions on demand:

```markdown
# User asks about Notion API
→ Auto-load docs/notion-api.md

# User asks to create an assistant
→ Auto-load docs/workflows.md

# User asks about migration
→ Auto-load docs/migration.md (if exists)
```

**Implementation:**
- Core assistant references extension files
- `/load-assistant` watches for keywords
- Auto-loads relevant docs when needed
- Keeps token usage minimal until required

## Migration from Centralized to Distributed

**Use the migration script:**
```bash
~/Documents/Dev/assistant-meta/tools/migrate-assistants.sh
```

**What it does:**
1. Fetches all assistants from Notion database
2. Creates individual git repositories for each
3. Extracts content and metadata
4. Initializes git with proper structure
5. Creates .meta tracking files
6. Maintains links to original Notion pages

## Best Practices

1. **Always work in git first**, sync to Notion second
2. **Check .meta** before syncing to avoid unnecessary API calls
3. **Use local loading** whenever possible
4. **Keep core assistant minimal**, extract details to docs/
5. **Update TODO.md** as you work, commit with changes
6. **Test after updates** to ensure everything works
7. **Document new workflows** in this file for future reference
