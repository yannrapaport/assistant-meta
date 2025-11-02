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
   echo "$API_DOCS" > docs/api.md  # if applicable
   echo "$WORKFLOWS" > docs/workflows.md  # if applicable

   # Initialize git
   git init
   git add .
   git commit -m "Initial commit: $NAME assistant"
   ```

6. **Report success:**
   - Show word count reduction (if compacted)
   - Display file path: `$REPO_DIR/assistant.md`
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

2. **Propose updates:**
   - Read current assistant.md
   - Review conversation for improvements
   - Show specific proposed changes
   - Get user approval

3. **Update local file:**
   ```bash
   # Apply changes using Edit tool
   # Or rewrite with Write tool if major changes
   ```

4. **Compact if needed** (if word count grew >30%):
   - Check current vs original word count
   - If >300 words or >30% growth, suggest compacting
   - Load `docs/compacting.md` for guidance
   - Extract new verbose content to docs/

5. **Commit changes:**
   ```bash
   git add assistant.md docs/
   git commit -m "Update: [description of changes]"
   ```

6. **Report success:**
   - Show changes made
   - Display word count (before/after if compacted)

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

## Git-Only Principle

**Git is the single source of truth:**

1. Save to git repository
2. Commit changes
3. All versioning managed by git

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
- ✅ Word count reduced (if compacted)
- ✅ File paths provided to user

Be efficient and clear. Don't over-explain - focus on execution.
