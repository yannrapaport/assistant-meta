# Notion API Reference

Complete API examples for managing assistants in Notion.

## Configuration

Load Notion credentials:
```bash
source ~/.config/claude-code/notion-config.sh
```

Required variables:
- `NOTION_API_KEY` - Your Notion integration API key
- `NOTION_VERSION` - API version (default: "2022-06-28")
- `DATABASE_ID` - Assistant Library database ID (default: "29686de33aad807fbea3edb4899d1d2b")

## Creating a Page

```bash
DATABASE_ID="29686de33aad807fbea3edb4899d1d2b"
TITLE="Assistant Name"
DESCRIPTION="Brief description"
CATEGORY="Meta"  # Content Creation, Product Management, Technical/Development, Meta
STATUS="Ready"   # Idea, Draft, Ready
EXPERTS="Expert Name (https://linkedin.com/...)"

curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H "Content-Type: application/json" \
  -d @payload.json
```

## JSON Payload Structure

```json
{
  "parent": { "database_id": "DATABASE_ID" },
  "properties": {
    "Nom": {
      "title": [{ "text": { "content": "TITLE" } }]
    },
    "Description": {
      "rich_text": [{ "text": { "content": "DESCRIPTION" } }]
    },
    "Category": {
      "select": { "name": "CATEGORY" }
    },
    "Status": {
      "select": { "name": "STATUS" }
    },
    "Expert References": {
      "rich_text": [{ "text": { "content": "EXPERTS" } }]
    }
  },
  "children": [
    {
      "type": "heading_1",
      "heading_1": {
        "rich_text": [{ "text": { "content": "Section Title" } }]
      }
    },
    {
      "type": "paragraph",
      "paragraph": {
        "rich_text": [{ "text": { "content": "Content here..." } }]
      }
    },
    {
      "type": "code",
      "code": {
        "language": "bash",
        "rich_text": [{ "text": { "content": "echo 'code example'" } }]
      }
    },
    {
      "type": "bulleted_list_item",
      "bulleted_list_item": {
        "rich_text": [{ "text": { "content": "Bullet point" } }]
      }
    }
  ]
}
```

## Common Block Types

- `heading_1`, `heading_2`, `heading_3` - Section headings
- `paragraph` - Regular text paragraphs
- `bulleted_list_item` - Bullet points
- `numbered_list_item` - Numbered lists
- `code` - Code blocks with syntax highlighting
- `quote` - Blockquotes
- `callout` - Highlighted callouts

## Updating a Page

```bash
PAGE_ID="abc123"  # Extract from Notion URL (last 32 chars without hyphens)

curl -X PATCH "https://api.notion.com/v1/pages/$PAGE_ID" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Status": { "select": { "name": "Ready" } }
    }
  }'
```

## Querying Database

```bash
DATABASE_ID="29686de33aad807fbea3edb4899d1d2b"

# Find assistant by name
curl -X POST "https://api.notion.com/v1/databases/$DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H "Content-Type: application/json" \
  -d '{
    "filter": {
      "property": "Nom",
      "title": { "equals": "Meta Assistant" }
    }
  }'

# List all assistants
curl -X POST "https://api.notion.com/v1/databases/$DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H "Content-Type: application/json"
```

## Fetching Page Content

Using the notion-lib.sh helper:
```bash
source ~/.config/claude-code/hooks/notion-lib.sh
PAGE_ID="abc123def456"  # 32 hex chars without hyphens
fetch_notion_blocks "$PAGE_ID"
```

## Error Handling

Common errors:
- `401 Unauthorized` - Check NOTION_API_KEY
- `404 Not Found` - Verify page/database ID
- `400 Bad Request` - Check JSON payload structure
- `429 Rate Limited` - Implement retry with backoff

## Best Practices

1. **Always remove hyphens from page IDs**: `echo "$page_id" | tr -d '-'`
2. **Escape special characters** in JSON strings
3. **Use heredoc for complex payloads** to avoid escaping issues
4. **Cache responses** to minimize API calls
5. **Check sync status** before pushing updates
