---
description: Load a specialized assistant from Notion or local file
---

Load a specialized assistant to help with specific tasks.

**Usage:**
- `/load-assistant <notion-url>` - Load assistant from a Notion page
- `/load-assistant <file-path>` - Load assistant from a local file
- `/load-assistant` (no arguments) - Show interactive options

**Your task:**

1. **Determine the source type:**
   - **If called with NO arguments:** Use the AskUserQuestion tool to present these options:
     - "Notion page" - User will provide a Notion URL
     - "Local file" - User will provide a file path
     - "Paste content" - User will paste text directly
   - **If called with an argument:**
     - If it's a Notion URL (contains `notion.so`), extract the page ID and fetch from Notion
     - If it's a file path that exists locally, read the file
     - Otherwise treat it as pasted content

2. **Fetch the content:**
   - **For Notion:**
     - Extract the page ID from the URL (the last 32 hex characters before any `?` parameter)
     - Remove hyphens: `page_id=$(echo "$page_id" | tr -d '-')`
     - Load configuration: `source ~/.config/claude-code/notion-config.sh`
     - Load library: `source ~/.config/claude-code/hooks/notion-lib.sh`
     - Fetch content: `fetch_notion_blocks "$page_id"`
   - **For local files:** Use the Read tool
   - **For pasted content:** Use it directly

3. **Present the context:**
   - Display a clear summary of what was loaded
   - Make this context available for the rest of the conversation

4. **Add to active assistants list:**
   - Extract the assistant name from the content (usually the first # heading)
   - Append it to `.active-assistants` file in the current directory (one per line)
   - Avoid duplicates - check if it's already in the list first
   ```bash
   ASSISTANT_NAME="Git Assistant"  # Extract from content
   ASSISTANTS_FILE=".active-assistants"

   # Create file if it doesn't exist
   touch "$ASSISTANTS_FILE"

   # Add only if not already present
   if ! grep -qx "$ASSISTANT_NAME" "$ASSISTANTS_FILE"; then
       echo "$ASSISTANT_NAME" >> "$ASSISTANTS_FILE"
   fi
   ```
   - This allows the status line to display all active assistants

Be concise and efficient. Don't over-explain - just load the context and confirm it's ready.
