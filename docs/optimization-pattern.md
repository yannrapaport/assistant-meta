# Assistant Optimization Pattern

This document describes the pattern used to optimize Meta Assistant, reducing token usage by 60% (799 → 318 words). Apply this pattern to all other assistants.

## Overview

**Goal**: Reduce assistant token usage by 50-70% while maintaining full functionality.

**Method**: Extract verbose content to `docs/` directory, keep core assistant minimal, use lazy loading.

**Result**: Faster loading, lower token costs, better maintainability.

## Optimization Steps

### 1. Analyze Current Assistant

**Measure baseline:**
```bash
cd ~/Documents/Dev/assistant-[name]
wc -w assistant.md
```

**Identify extractable content:**
- API documentation and examples (>50 words)
- Detailed workflows and procedures (>100 words)
- Code blocks and templates (>3 blocks)
- Long lists and reference tables
- Redundant "Scope" or "Starting a Session" sections

**Calculate potential:**
- If <300 words: Already optimal, skip
- If 300-500 words: ~30-50% reduction possible
- If 500-800 words: ~50-70% reduction possible
- If >800 words: ~60-80% reduction possible

### 2. Create Documentation Structure

**Create docs directory:**
```bash
mkdir -p docs
```

**Common documentation files:**
- `docs/notion-api.md` - API examples, payloads, authentication
- `docs/workflows.md` - Step-by-step procedures
- `docs/examples.md` - Code templates and samples
- `docs/reference.md` - Tables, lists, catalogs
- `docs/[domain-specific].md` - Topic-specific detailed docs

### 3. Extract Verbose Content

**For each extractable section:**

1. Create appropriate doc file in `docs/`
2. Move detailed content from assistant.md
3. Replace in core with concise reference

**Example - API Documentation:**

Before (in assistant.md):
```markdown
## API Integration

To integrate with the API, use the following:

\`\`\`bash
curl -X POST "https://api.example.com/v1/resource" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "field1": "value1",
    "field2": "value2"
  }'
\`\`\`

The response will be:
\`\`\`json
{
  "id": "abc123",
  "status": "success"
}
\`\`\`
```

After (in assistant.md):
```markdown
## API Integration

See `docs/api-reference.md` for authentication, endpoints, and examples.
```

After (in docs/api-reference.md):
```markdown
# API Reference

## Authentication
...

## Endpoints
...

## Examples
...
```

### 4. Rewrite Core Assistant

**Target structure (~200-350 words):**

```markdown
# [Assistant Name]

[One-sentence description of primary purpose]

## Your Role

[3-5 bullet points of key responsibilities]

## Quick Reference

**[Key action 1]**: [One-line how-to]
**[Key action 2]**: [One-line how-to]
**[Key action 3]**: [One-line how-to]

## Prerequisites

- [Requirement 1]
- [Requirement 2]

## [Category 1]

[Brief list or categories with doc references]

See `docs/[topic].md` for [detailed information].

## [Category 2]

[Brief overview]

See `docs/[topic].md` for [step-by-step guide].

## Lazy Loading

Extensions auto-load on demand:
- **[keywords]** → Load `docs/[file].md`
- **[keywords]** → Load `docs/[file].md`

## Scope

**IN SCOPE:**
- [Brief list]

**OUT OF SCOPE:**
- [Brief list]

Ready to [primary purpose].
```

**Writing guidelines:**
- Use bullet points, not paragraphs
- Keep explanations to 1-2 sentences max
- Reference docs/ for details
- Remove redundant content
- Eliminate "Starting a Session" if it repeats earlier content
- Simplify "Scope Boundaries" to essential items only

### 5. Create .meta Tracking File

```bash
cd ~/Documents/Dev/assistant-[name]

GIT_HASH=$(git rev-parse HEAD 2>/dev/null || echo "")
cat > .meta << EOF
{
  "notion_page_id": "",
  "last_sync_hash": "$GIT_HASH",
  "last_sync_date": ""
}
EOF
```

### 6. Update /load-assistant for Lazy Loading

**Add keywords for this assistant's extensions:**

In `/Users/yannrapaport/.claude/commands/load-assistant.md`:

```markdown
4. **Lazy Load Extensions:**

   Watch for keywords:

   - "[keyword1]", "[keyword2]" → Load `docs/[file].md`
```

**Example keywords by file type:**
- `docs/notion-api.md`: "notion api", "create page", "update notion"
- `docs/workflows.md`: "workflow", "process", "step by step", "how to"
- `docs/examples.md`: "example", "template", "sample"
- `docs/api-reference.md`: "api", "endpoint", "authentication"

### 7. Verify & Commit

**Check word count:**
```bash
BEFORE=799  # Replace with original
AFTER=$(wc -w < assistant.md)
REDUCTION=$(( ($BEFORE - $AFTER) * 100 / $BEFORE ))

echo "Optimized: $BEFORE → $AFTER words (-$REDUCTION%)"
```

**Verify target met:**
- Target: 200-350 words
- If >350: Look for more extractable content
- If <200: May be too minimal, add back essential quick reference

**Commit changes:**
```bash
git add assistant.md docs/ .meta
git commit -m "Optimize assistant: $BEFORE → $AFTER words (-$REDUCTION%)"
```

### 8. Test Loading

**Test core loading:**
```bash
/load-assistant [assistant-name]
# Should show: "Loaded [Name] ([words] words, local)"
# Should note: "Extensions available: [list]"
```

**Test lazy loading:**
- Mention keywords → Extension should auto-load
- Verify correct extension loads for each keyword set

**Test functionality:**
- Ensure core assistant still works
- Verify references to docs are correct
- Confirm essential info still present

## Application to Other Assistants

### Git Assistant

**Current**: ~350 words (estimate)
**Extractable**:
- Git workflows → `docs/workflows.md`
- Commit message templates → `docs/templates.md`
- Git commands reference → `docs/git-reference.md`
**Target**: ~200 words (-43%)

### LinkedIn Post Writer

**Current**: ~500 words (estimate)
**Extractable**:
- Post templates and examples → `docs/templates.md`
- LinkedIn best practices → `docs/best-practices.md`
- Writing formulas → `docs/formulas.md`
**Target**: ~250 words (-50%)

### Content Manager

**Current**: ~600 words (estimate)
**Extractable**:
- Content workflows → `docs/workflows.md`
- Platform-specific guides → `docs/platforms.md`
- Content calendar templates → `docs/templates.md`
**Target**: ~280 words (-53%)

### Expert Prompt Writer

**Current**: ~700 words (estimate)
**Extractable**:
- Prompt frameworks → `docs/frameworks.md`
- Examples and templates → `docs/examples.md`
- Evaluation criteria → `docs/evaluation.md`
**Target**: ~300 words (-57%)

### Product Idea Brainstormer

**Current**: ~650 words (estimate)
**Extractable**:
- Brainstorming frameworks → `docs/frameworks.md`
- Validation processes → `docs/validation.md`
- Market analysis templates → `docs/templates.md`
**Target**: ~280 words (-57%)

### Context Manager

**Current**: ~400 words (estimate)
**Extractable**:
- Context management workflows → `docs/workflows.md`
- File structure patterns → `docs/patterns.md`
**Target**: ~220 words (-45%)

## Batch Optimization Script

**Optimize all assistants:**

```bash
#!/bin/bash
# optimize-all-assistants.sh

for dir in ~/Documents/Dev/assistant-*/; do
    name=$(basename "$dir")
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Optimizing $name..."
    cd "$dir"

    before=$(wc -w < assistant.md 2>/dev/null || echo "0")

    if [ "$before" -lt 300 ]; then
        echo "  Already optimal (<300 words)"
        continue
    fi

    echo "  Current: $before words"
    echo "  Run: /load-assistant meta"
    echo "  Then: Compact the $name assistant"
    echo ""
done
```

## Maintenance

**Periodic review (every 3-6 months):**

```bash
# Check all assistants for growth
for dir in ~/Documents/Dev/assistant-*/; do
    cd "$dir"
    name=$(basename "$dir")
    words=$(wc -w < assistant.md)

    if [ "$words" -gt 350 ]; then
        echo "$name: $words words (needs re-compacting)"
    fi
done
```

**After re-compacting:**
1. Extract new verbose content
2. Update .meta file
3. Commit changes
4. Optionally sync to Notion

## Best Practices

1. **Always extract >50 word sections** - Not worth extracting tiny sections
2. **Group related content** - Don't create too many small docs
3. **Keep quick reference in core** - Essential commands stay accessible
4. **Use consistent file names** - workflows.md, examples.md, reference.md
5. **Test after optimization** - Ensure functionality preserved
6. **Update lazy loading** - Add keywords for new docs
7. **Document what was extracted** - Clear commit messages
8. **Maintain .meta files** - Track sync status properly

## Success Metrics

**Meta Assistant Results:**
- Before: 799 words (~1000 tokens)
- After: 318 words (~380 tokens)
- Reduction: 60%
- Token savings: ~620 tokens per load
- Extensions: 3 files (notion-api, workflows, compacting)
- Loading: Core only, extensions on demand

**Expected Results for Others:**
- Average reduction: 50-60%
- Token savings: 300-600 tokens per assistant
- Faster load times
- Better maintainability
- No functionality loss

## Next Steps

1. Apply this pattern to Git Assistant first (good test case)
2. Measure results and refine process
3. Batch optimize remaining assistants
4. Update TODO.md to track optimization status
5. Sync optimized versions to Notion (optional)
