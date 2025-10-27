---
description: Load a specialized assistant from Notion or local file
---

Load a specialized assistant to help with specific tasks.

**Usage:**
- `/load-assistant <notion-url>` - Load assistant from a Notion page
- `/load-assistant <file-path>` - Load assistant from a local file
- `/load-assistant` (no arguments) - Show interactive options

**Your task:**

## Step 0: Check if Loading Meta Assistant

**IMPORTANT:** If the assistant being loaded is Meta Assistant itself:
- Skip this step and proceed directly to Step 1
- Do NOT create infinite recursion by trying to load Meta to load Meta

If loading any other assistant that may need Meta capabilities:
- Meta will be auto-loaded by `/save-assistant` when needed
- No need to pre-load Meta here

## Step 1: Local-First Search (Priority Order)

   Search in this order, use first match found:

   a. **Current directory**: `./assistant.md` or `./.meta` → `./assistant.md`

   b. **Assistant subdirectory**: `./assistant-*/assistant.md` (if multiple, ask user)

   c. **Home directory assistants**: `~/Documents/Dev/assistant-*/assistant.md`
      - If argument is a name (e.g., "meta"), search for `~/Documents/Dev/assistant-{name}/assistant.md`
      - If exact match not found, fuzzy match against existing assistants

   d. **Full file path**: If argument is an absolute path, use it directly

   e. **Notion URL**: Only if explicitly provided as `https://notion.so/...`

   f. **Interactive fallback**: If nothing found and no argument, ask user

2. **Check Cache Before Loading:**

   Before reading the assistant file:
   ```bash
   # If .meta exists in assistant directory, check if content changed
   if [ -f .meta ]; then
       CURRENT_HASH=$(git rev-parse HEAD 2>/dev/null || echo "")
       CACHED_HASH=$(jq -r '.last_sync_hash' .meta 2>/dev/null || echo "")

       # If hashes match and assistant already loaded this session, skip reload
       if [ "$CURRENT_HASH" = "$CACHED_HASH" ] && [ -n "$CURRENT_HASH" ]; then
           echo "Assistant unchanged since last load - using cached version"
           # Don't re-read file, just confirm it's active
       fi
   fi
   ```

3. **Fetch the content:**

   - **For local files:**
     - Use the Read tool to load `assistant.md`
     - Load ONLY the core assistant (not docs/ extensions yet)

   - **For Notion** (only if explicitly requested):
     - Extract page ID from URL
     - Remove hyphens: `page_id=$(echo "$page_id" | tr -d '-')`
     - Load configuration: `source ~/.config/claude-code/notion-config.sh`
     - Load library: `source ~/.config/claude-code/hooks/notion-lib.sh`
     - Fetch content: `fetch_notion_blocks "$page_id"`

4. **Lazy Load Extensions:**

   After loading core assistant, watch for keywords in user requests:

   - User mentions "notion api", "create page", "update notion" → Load `docs/notion-api.md`
   - User mentions "workflow", "process", "how to create" → Load `docs/workflows.md`
   - User mentions "compact", "minimize", "optimize", "token" → Load `docs/compacting.md`
   - User mentions "migrate", "migration" → Load `docs/migration.md` (if exists)

   When loading extensions, prepend with: "Loading extension: docs/[file].md for [purpose]"

5. **Present the context:**

   - Display concise summary: "Loaded [Assistant Name] (308 words, local)"
   - Show source: file path or Notion URL
   - Note: "Extensions available: notion-api, workflows" (if docs/ exists)

6. **Add to active assistants list:**

   ```bash
   ASSISTANT_NAME="Meta Assistant"  # Extract from first # heading
   ASSISTANTS_FILE=".active-assistants"

   touch "$ASSISTANTS_FILE"

   if ! grep -qx "$ASSISTANT_NAME" "$ASSISTANTS_FILE"; then
       echo "$ASSISTANT_NAME" >> "$ASSISTANTS_FILE"
   fi
   ```

Be concise and efficient. Don't over-explain - just load the context and confirm it's ready.
