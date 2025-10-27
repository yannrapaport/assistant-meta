#!/usr/bin/env python3
"""Convert assistant.md to Notion blocks and sync."""

import json
import re
import sys

def parse_markdown_to_blocks(md_content):
    """Convert markdown content to Notion block structure."""
    blocks = []
    lines = md_content.split('\n')
    i = 0

    while i < len(lines):
        line = lines[i]

        # Skip empty lines
        if not line.strip():
            i += 1
            continue

        # Heading 1
        if line.startswith('# '):
            blocks.append({
                "type": "heading_1",
                "heading_1": {
                    "rich_text": [{"text": {"content": line[2:].strip()}}]
                }
            })

        # Heading 2
        elif line.startswith('## '):
            blocks.append({
                "type": "heading_2",
                "heading_2": {
                    "rich_text": [{"text": {"content": line[3:].strip()}}]
                }
            })

        # Heading 3
        elif line.startswith('### '):
            blocks.append({
                "type": "heading_3",
                "heading_3": {
                    "rich_text": [{"text": {"content": line[4:].strip()}}]
                }
            })

        # Bullet point with bold
        elif line.startswith('- '):
            content = line[2:].strip()
            rich_text = parse_inline_formatting(content)
            blocks.append({
                "type": "bulleted_list_item",
                "bulleted_list_item": {
                    "rich_text": rich_text
                }
            })

        # Bold paragraph (starts with **)
        elif line.startswith('**'):
            rich_text = parse_inline_formatting(line)
            blocks.append({
                "type": "paragraph",
                "paragraph": {
                    "rich_text": rich_text
                }
            })

        # Regular paragraph
        else:
            rich_text = parse_inline_formatting(line)
            blocks.append({
                "type": "paragraph",
                "paragraph": {
                    "rich_text": rich_text
                }
            })

        i += 1

    return blocks

def parse_inline_formatting(text):
    """Parse inline markdown formatting (bold, links)."""
    rich_text = []

    # Pattern to match: **bold**, [link text](url), or plain text
    pattern = r'\*\*(.+?)\*\*|\[(.+?)\]\((.+?)\)|([^*\[]+)'

    for match in re.finditer(pattern, text):
        if match.group(1):  # Bold text
            rich_text.append({
                "text": {"content": match.group(1)},
                "annotations": {"bold": True}
            })
        elif match.group(2) and match.group(3):  # Link
            rich_text.append({
                "text": {"content": match.group(2), "link": {"url": match.group(3)}}
            })
        elif match.group(4):  # Plain text
            content = match.group(4)
            if content:
                rich_text.append({
                    "text": {"content": content}
                })

    # If no matches, return plain text
    if not rich_text:
        rich_text = [{"text": {"content": text}}]

    return rich_text

def main():
    if len(sys.argv) < 2:
        print("Usage: sync-to-notion.py <markdown-file>")
        sys.exit(1)

    md_file = sys.argv[1]

    with open(md_file, 'r') as f:
        content = f.read()

    blocks = parse_markdown_to_blocks(content)

    # Output JSON
    print(json.dumps(blocks, indent=2))

if __name__ == "__main__":
    main()
