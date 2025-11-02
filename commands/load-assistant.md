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

## Step 1: Local Search (Priority Order)

   Search in this order, use first match found:

   a. **Current directory**: `./assistant.md`

   b. **Assistant subdirectory**: `./assistant-*/assistant.md` (if multiple, ask user)

   c. **Home directory assistants**: `~/Documents/Dev/assistant-*/assistant.md`
      - If argument is a name (e.g., "meta"), search for `~/Documents/Dev/assistant-{name}/assistant.md`
      - If exact match not found, fuzzy match against existing assistants

   d. **Full file path**: If argument is an absolute path, use it directly

   e. **Interactive fallback**: If nothing found and no argument, ask user

2. **Load the content:**

   - Use the Read tool to load `assistant.md`
   - Load ONLY the core assistant (not docs/ extensions yet)

3. **Lazy Load Extensions:**

   After loading core assistant, watch for keywords in user requests:

   - User mentions "workflow", "process", "how to create" → Load `docs/workflows.md`
   - User mentions "compact", "minimize", "optimize", "token" → Load `docs/compacting.md`
   - User mentions "migrate", "migration" → Load `docs/migration.md` (if exists)

   When loading extensions, prepend with: "Loading extension: docs/[file].md for [purpose]"

4. **Present the context:**

   - Display concise summary: "Loaded [Assistant Name] (308 words, local)"
   - Show source: file path
   - Note: "Extensions available: workflows, compacting" (if docs/ exists)

Be concise and efficient. Don't over-explain - just load the context and confirm it's ready.
