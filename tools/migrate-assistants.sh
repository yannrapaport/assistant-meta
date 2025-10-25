#!/bin/bash

# Migrate Assistants from Notion to Individual Git Repositories
# Uses the assistant-meta structure as template

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Migrate Assistants to Individual Repos"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Load Notion configuration
if [ ! -f ~/.config/claude-code/notion-config.sh ]; then
    echo "${RED}❌ Notion configuration not found${NC}"
    echo "Create ~/.config/claude-code/notion-config.sh with:"
    echo "  NOTION_API_KEY=\"your-key\""
    echo "  NOTION_VERSION=\"2022-06-28\""
    exit 1
fi

source ~/.config/claude-code/notion-config.sh

# Load notion-lib for fetching blocks
if [ ! -f ~/.config/claude-code/hooks/notion-lib.sh ]; then
    echo "${RED}❌ notion-lib.sh not found${NC}"
    exit 1
fi

source ~/.config/claude-code/hooks/notion-lib.sh

DATABASE_ID="29686de33aad807fbea3edb4899d1d2b"
DEV_DIR="$HOME/Documents/Dev"

# Fetch all assistants from Notion
echo "${BLUE}📥 Fetching assistants from Notion...${NC}"
RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/databases/$DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H "Content-Type: application/json" \
  -d '{}')

# Check if we got results
if [ "$(echo "$RESPONSE" | jq -r '.results | length')" -eq 0 ]; then
    echo "${RED}❌ No assistants found in database${NC}"
    exit 1
fi

# Parse and process each assistant
echo "$RESPONSE" | jq -c '.results[]' | while read -r assistant; do
    # Extract metadata
    NAME=$(echo "$assistant" | jq -r '.properties.Nom.title[0].text.content // .properties.Name.title[0].text.content // "Untitled"')
    DESCRIPTION=$(echo "$assistant" | jq -r '.properties.Description.rich_text[0].text.content // "No description"')
    CATEGORY=$(echo "$assistant" | jq -r '.properties.Category.select.name // "Uncategorized"')
    STATUS=$(echo "$assistant" | jq -r '.properties.Status.select.name // "Draft"')
    PAGE_ID=$(echo "$assistant" | jq -r '.id' | tr -d '-')
    NOTION_URL="https://www.notion.so/${PAGE_ID}"

    # Create slug from name
    SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
    REPO_NAME="assistant-${SLUG}"
    REPO_PATH="${DEV_DIR}/${REPO_NAME}"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "${GREEN}📦 Processing: ${NAME}${NC}"
    echo "   Category: ${CATEGORY}"
    echo "   Status: ${STATUS}"
    echo "   Slug: ${SLUG}"
    echo ""

    # Check if repo already exists
    if [ -d "$REPO_PATH" ]; then
        echo "${YELLOW}⚠️  Repository already exists: ${REPO_PATH}${NC}"
        read -p "   Skip this assistant? (y/n): " SKIP
        if [ "$SKIP" = "y" ]; then
            echo "   Skipped."
            continue
        fi
        rm -rf "$REPO_PATH"
    fi

    # Create directory structure
    echo "${BLUE}   📁 Creating directory structure...${NC}"
    mkdir -p "$REPO_PATH"/{commands,tools,docs}

    # Fetch content from Notion
    echo "${BLUE}   📥 Fetching content from Notion...${NC}"
    CONTENT=$(fetch_notion_blocks "$PAGE_ID")

    # Create assistant.md
    echo "${BLUE}   📝 Creating assistant.md...${NC}"
    echo "$CONTENT" > "$REPO_PATH/assistant.md"

    # Create README.md
    echo "${BLUE}   📝 Creating README.md...${NC}"
    cat > "$REPO_PATH/README.md" <<EOF
# ${NAME}

${DESCRIPTION}

## What is ${NAME}?

${NAME} is a specialized Claude Code assistant that helps you with specific tasks.

## Installation

Run the installer to set up commands:

\`\`\`bash
cd ~/Documents/Dev/${REPO_NAME}
./install.sh
\`\`\`

## Usage

After installation and restarting Claude Code:

\`\`\`bash
# Load the ${NAME}
/load-assistant ~/Documents/Dev/${REPO_NAME}/assistant.md

# Or from Notion
/load-assistant ${NOTION_URL}
\`\`\`

## Directory Structure

\`\`\`
${REPO_NAME}/
├── README.md          # This file
├── assistant.md       # Assistant prompt/instructions
├── TODO.md            # Task tracking
├── install.sh         # Installer script
├── commands/          # Custom slash commands
├── tools/             # Custom tools/scripts
└── docs/              # Documentation
\`\`\`

## Metadata

- **Category**: ${CATEGORY}
- **Status**: ${STATUS}
- **Notion URL**: ${NOTION_URL}

## Requirements

- Claude Code v2.0+

## License

MIT
EOF

    # Create TODO.md
    echo "${BLUE}   📝 Creating TODO.md...${NC}"
    cat > "$REPO_PATH/TODO.md" <<EOF
# ${NAME} - TODO

## In Progress

- [ ] Review migrated content
- [ ] Add any missing documentation

## Planned

- [ ] Test assistant functionality
- [ ] Add custom commands if needed
- [ ] Add custom tools if needed

## Completed

- [x] Migrated from Notion to git repository

## Future Ideas

- [ ] [Add future enhancements here]
EOF

    # Create .gitignore
    cat > "$REPO_PATH/.gitignore" <<EOF
# OS
.DS_Store
Thumbs.db

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
*.tmp
.active-assistants

# Local configuration
.env
.env.local
EOF

    # Create install.sh
    echo "${BLUE}   📝 Creating install.sh...${NC}"
    cat > "$REPO_PATH/install.sh" <<'INSTALL_EOF'
#!/bin/bash

# ASSISTANT_NAME Installer

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 ASSISTANT_NAME Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"
TOOLS_DIR="$HOME/.config/claude-code"

mkdir -p "$COMMANDS_DIR"
mkdir -p "$TOOLS_DIR"

echo "📦 Installing commands and tools..."

# Copy custom commands (if any)
if [ -d "$SCRIPT_DIR/commands" ] && [ "$(ls -A $SCRIPT_DIR/commands 2>/dev/null)" ]; then
    for cmd in "$SCRIPT_DIR/commands"/*.md; do
        if [ -f "$cmd" ]; then
            cp "$cmd" "$COMMANDS_DIR/"
            echo "  ✓ Installed /$(basename "$cmd" .md) command"
        fi
    done
else
    echo "  ℹ️  No custom commands to install"
fi

# Copy tools (if any)
if [ -d "$SCRIPT_DIR/tools" ] && [ "$(ls -A $SCRIPT_DIR/tools/*.sh 2>/dev/null)" ]; then
    for tool in "$SCRIPT_DIR/tools"/*.sh; do
        if [ -f "$tool" ]; then
            cp "$tool" "$TOOLS_DIR/"
            chmod +x "$TOOLS_DIR/$(basename "$tool")"
            echo "  ✓ Installed $(basename "$tool")"
        fi
    done
else
    echo "  ℹ️  No custom tools to install"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ASSISTANT_NAME installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Restart Claude Code"
echo "2. Load the assistant:"
echo "   /load-assistant $SCRIPT_DIR/assistant.md"
echo ""
INSTALL_EOF

    sed -i '' "s/ASSISTANT_NAME/${NAME}/g" "$REPO_PATH/install.sh"
    chmod +x "$REPO_PATH/install.sh"

    # Initialize git repository
    echo "${BLUE}   🔧 Initializing git repository...${NC}"
    cd "$REPO_PATH"
    git init -q
    git add .
    git commit -q -m "Initial commit: ${NAME}

Migrated from Notion
Category: ${CATEGORY}
Status: ${STATUS}
Notion URL: ${NOTION_URL}

${DESCRIPTION}"

    echo "${GREEN}   ✅ ${NAME} repository created!${NC}"
    echo "   Location: ${REPO_PATH}"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${GREEN}✅ Migration complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "All assistants have been migrated to individual repositories in:"
echo "${DEV_DIR}"
echo ""
echo "Next steps:"
echo "1. Review each assistant's content"
echo "2. Run ./install.sh in each assistant directory"
echo "3. Use /load-assistant to load any assistant"
echo ""
