# Compacting Assistants - Token Optimization Guide

Reduce assistant token usage by 50-70% while maintaining full functionality.

## When to Compact

Compact an assistant when:
- Word count > 300 words
- Contains verbose examples, API documentation, or detailed workflows
- Has multiple code blocks (>3)
- Includes repetitive content

## Compacting Process

### 1. Analyze Current Assistant

**Identify extractable content:**
- API documentation and examples
- Detailed workflows and procedures
- Code templates and snippets
- Long lists and tables
- Redundant explanations
- "Scope boundaries" sections (usually obvious)
- "Starting a session" content (often repetitive)

**Count sections:**
```bash
wc -w assistant.md     # Total words
grep -c '```' assistant.md  # Code blocks
awk '/^##/ {count++} END {print count}' assistant.md  # Sections
```

### 2. Create Documentation Files

**Extract to docs/ directory:**

- `docs/notion-api.md` - Notion API examples, payload structures, block types
- `docs/workflows.md` - Detailed step-by-step workflows
- `docs/examples.md` - Code examples and templates
- `docs/reference.md` - Quick reference tables, lists
- `docs/migration.md` - Migration guides (if applicable)

**File naming convention:**
- Use lowercase with hyphens
- Be descriptive but concise
- Group related content

### 3. Rewrite Core Assistant

**Core assistant structure (~200-300 words):**

```markdown
# [Assistant Name]

[One-line description]

## Your Role

[Bullet points - 3-5 key responsibilities]

## Quick Reference

[Essential commands/actions - bullet format]

## Prerequisites

[Required setup - minimal list]

## Key Concepts

[3-5 important concepts - very brief]

## Common Tasks

[Top 3-5 tasks with references to docs/]

See `docs/workflows.md` for detailed processes.

## Scope

**IN SCOPE:**
[Brief list]

**OUT OF SCOPE:**
[Brief list]

Ready to [main purpose].
```

**Replace verbose content with references:**

❌ Before (verbose):
```markdown
## Creating a Notion Page

To create a page, use the following curl command:

\`\`\`bash
DATABASE_ID="abc123"
TITLE="Page Title"

curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": { "database_id": "DATABASE_ID" },
    "properties": {
      "Name": {
        "title": [{ "text": { "content": "TITLE" } }]
      }
    }
  }'
\`\`\`
```

✅ After (compact):
```markdown
## Notion API

See `docs/notion-api.md` for:
- Creating and updating pages
- Payload structures
- Block types and examples
```

### 4. Update References

**In core assistant:**
- Replace detailed sections with "See docs/[file].md"
- Keep only essential quick reference
- Link to docs for details

**Update /load-assistant command:**
- Ensure lazy loading is configured
- Test keyword detection for auto-loading extensions

### 5. Create .meta File

```bash
cd ~/Documents/Dev/assistant-[name]
GIT_HASH=$(git rev-parse HEAD)
cat > .meta << EOF
{
  "notion_page_id": "",
  "last_sync_hash": "$GIT_HASH",
  "last_sync_date": ""
}
EOF
```

### 6. Verify & Test

**Check word count:**
```bash
wc -w assistant.md
# Target: 200-350 words
```

**Test loading:**
```bash
/load-assistant [assistant-name]
# Should load core only
# Extensions should load on demand when keywords mentioned
```

**Test extensions:**
- Mention "notion api" → Should auto-load docs/notion-api.md
- Mention "workflow" → Should auto-load docs/workflows.md

### 7. Commit Changes

```bash
git add assistant.md docs/ .meta
git commit -m "Compact assistant: reduce from [X] to [Y] words (-[Z]%)"
```

## Token Savings Examples

**Meta Assistant:**
- Before: 799 words (~1000 tokens)
- After: 308 words (~380 tokens)
- Savings: 62% reduction

**Typical Savings:**
- 500-800 word assistants → 200-300 words (50-70% reduction)
- 300-500 word assistants → 150-250 words (30-50% reduction)
- <300 word assistants → Already optimal

## Extraction Guidelines

### Extract These:

✅ **API Documentation**
- Curl examples
- JSON payload structures
- Authentication details
- Error handling

✅ **Detailed Workflows**
- Step-by-step procedures
- Multi-step processes
- Command sequences
- Migration guides

✅ **Code Examples**
- Bash scripts >5 lines
- JSON templates
- Configuration files
- Example payloads

✅ **Reference Tables**
- Long lists
- Property definitions
- Block type catalogs
- Status/category options

✅ **Verbose Explanations**
- "How it works" sections
- Background information
- Detailed descriptions
- Redundant scope boundaries

### Keep in Core:

✅ **Essential Information**
- Role and purpose (1-2 sentences)
- Top 3-5 responsibilities
- Quick command reference
- Prerequisites (minimal)
- Brief scope summary

✅ **Compact Lists**
- 3-5 key concepts
- Top tasks with references
- Categories/statuses (brief)

## Lazy Loading Configuration

**Update load-assistant command to auto-load:**

```markdown
4. **Lazy Load Extensions:**

   Watch for keywords in user requests:

   - "notion api", "create page", "update notion" → Load `docs/notion-api.md`
   - "workflow", "process", "step by step" → Load `docs/workflows.md`
   - "example", "template", "sample" → Load `docs/examples.md`
   - "migrate", "migration", "convert" → Load `docs/migration.md`

   Prepend: "Loading extension: [file] for [purpose]"
```

## Batch Compacting Multiple Assistants

**For all assistants:**

```bash
for dir in ~/Documents/Dev/assistant-*/; do
    echo "Analyzing $(basename "$dir")..."
    cd "$dir"
    ~/Documents/Dev/assistant-meta/tools/compact-assistant.sh
done
```

**Then use Meta Assistant to compact each one:**
```
/load-assistant meta
Compact all assistants in ~/Documents/Dev/assistant-*
```

## Maintenance

**After compacting:**

1. Update README.md to mention compact structure
2. Add .meta to .gitignore if needed (or commit it)
3. Test loading and lazy loading
4. Update TODO.md to mark compacting as complete
5. Sync to Notion with `/save-assistant` if needed

**Periodic review:**
- Every 3-6 months, check if assistants have grown
- Re-compact if word count increases >30%
- Extract new verbose content to docs/

## Best Practices

1. **Always backup** before compacting: `cp assistant.md assistant.md.backup`
2. **Test after compacting** to ensure functionality preserved
3. **Keep docs/ organized** - don't create too many small files
4. **Use consistent references** in core assistant
5. **Update lazy loading** if adding new docs
6. **Commit incrementally** - easier to rollback if needed
7. **Document what was extracted** in commit message

## Troubleshooting

**Assistant feels incomplete:**
- Check that docs/ files were created
- Verify references in core assistant are correct
- Test lazy loading keywords

**Extensions not auto-loading:**
- Check /load-assistant command configuration
- Verify keyword detection logic
- Test with explicit keyword mentions

**Token count still high:**
- Look for remaining verbose content
- Check for redundant explanations
- Consider further extraction to docs/

**Lost functionality:**
- Restore from backup: `mv assistant.md.backup assistant.md`
- Re-extract more carefully
- Keep essential quick reference in core
