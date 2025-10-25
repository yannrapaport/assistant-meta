#!/bin/bash

# Create Assistant Repository Script
# Generates a new assistant repository based on the assistant-meta template

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Create Assistant Repository"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get assistant information
read -p "Assistant name (e.g., 'Git Assistant'): " ASSISTANT_NAME
read -p "Short slug (e.g., 'git'): " SLUG
read -p "Description: " DESCRIPTION
read -p "Category (Content Creation/Product Management/Technical Development/Meta): " CATEGORY

# Derived values
REPO_NAME="assistant-${SLUG}"
REPO_PATH="$HOME/Documents/Dev/${REPO_NAME}"

# Check if directory already exists
if [ -d "$REPO_PATH" ]; then
    echo ""
    echo "${YELLOW}⚠️  Directory $REPO_PATH already exists${NC}"
    read -p "Continue and overwrite? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

# Create directory structure
echo ""
echo "${BLUE}📦 Creating directory structure...${NC}"
mkdir -p "$REPO_PATH"/{commands,tools,docs}

# Create assistant.md
echo "${BLUE}📝 Creating assistant.md...${NC}"
cat > "$REPO_PATH/assistant.md" <<EOF
# ${ASSISTANT_NAME}

${DESCRIPTION}

## Your Role

[Define the assistant's role and responsibilities here]

## Key Responsibilities

- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

## Workflow

### [Common Task 1]

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

### [Common Task 2]

**Steps:**
1. [Step 1]
2. [Step 2]

## Scope Boundaries

**IN SCOPE:**
- [What this assistant handles]
- [Core responsibilities]

**OUT OF SCOPE:**
- [What this assistant doesn't handle]
- [Tasks for other assistants]

## Expert References

- [Expert Name]: [URL or description]

## Starting a Session

When you load this assistant, I'll help you with [primary function].

Let's get started!
EOF

# Create README.md
echo "${BLUE}📝 Creating README.md...${NC}"
cat > "$REPO_PATH/README.md" <<EOF
# ${ASSISTANT_NAME}

${DESCRIPTION}

## What is ${ASSISTANT_NAME}?

${ASSISTANT_NAME} helps you:
- [Primary benefit 1]
- [Primary benefit 2]
- [Primary benefit 3]

## Installation

Run the installer to set up commands:

\`\`\`bash
cd ~/Documents/Dev/${REPO_NAME}
./install.sh
\`\`\`

This installs:
- Custom slash commands (if any)
- Custom tools (if any)

## Usage

After installation and restarting Claude Code:

\`\`\`bash
# Load the ${ASSISTANT_NAME}
/load-assistant ~/Documents/Dev/${REPO_NAME}/assistant.md

# Or from Notion (after syncing)
/load-assistant https://www.notion.so/${ASSISTANT_NAME}-[page-id]
\`\`\`

## Directory Structure

\`\`\`
${REPO_NAME}/
├── README.md                    # This file
├── assistant.md                 # Assistant prompt/instructions
├── TODO.md                      # Persistent todo list
├── install.sh                   # Installer script
├── commands/                    # Custom slash commands
├── tools/                       # Custom tools/scripts
└── docs/                        # Documentation
\`\`\`

## Features

[Describe key features]

## Requirements

- Claude Code v2.0+
- [Any other dependencies]

## License

MIT
EOF

# Create TODO.md
echo "${BLUE}📝 Creating TODO.md...${NC}"
cat > "$REPO_PATH/TODO.md" <<EOF
# ${ASSISTANT_NAME} - TODO

## In Progress

- [ ] Initial setup and configuration

## Planned

- [ ] Add core functionality
- [ ] Write comprehensive documentation
- [ ] Create example use cases

## Completed

- [x] Repository structure created

## Future Ideas

- [ ] [Future enhancement ideas]
EOF

# Create .gitignore
echo "${BLUE}📝 Creating .gitignore...${NC}"
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
echo "${BLUE}📝 Creating install.sh...${NC}"
cat > "$REPO_PATH/install.sh" <<'EOF'
#!/bin/bash

# ${ASSISTANT_NAME} Installer
# Sets up commands and tools

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 ${ASSISTANT_NAME} Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Determine the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directories
COMMANDS_DIR="$HOME/.claude/commands"
TOOLS_DIR="$HOME/.config/claude-code"

# Create directories if they don't exist
mkdir -p "$COMMANDS_DIR"
mkdir -p "$TOOLS_DIR"

echo "📦 Installing commands and tools..."

# Copy custom commands (if any exist)
if [ -d "$SCRIPT_DIR/commands" ] && [ "$(ls -A $SCRIPT_DIR/commands)" ]; then
    for cmd in "$SCRIPT_DIR/commands"/*.md; do
        if [ -f "$cmd" ]; then
            cp "$cmd" "$COMMANDS_DIR/"
            echo "  ✓ Installed /$(basename "$cmd" .md) command"
        fi
    done
else
    echo "  ℹ️  No custom commands to install"
fi

# Copy tools (if any exist)
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
echo "✅ ${ASSISTANT_NAME} installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Restart Claude Code"
echo ""
echo "2. Load the assistant:"
echo "   /load-assistant $SCRIPT_DIR/assistant.md"
echo ""
EOF

# Replace placeholders in install.sh
sed -i '' "s/\${ASSISTANT_NAME}/${ASSISTANT_NAME}/g" "$REPO_PATH/install.sh"

chmod +x "$REPO_PATH/install.sh"

# Initialize git repository
echo ""
echo "${BLUE}🔧 Initializing git repository...${NC}"
cd "$REPO_PATH"
git init
git add .
git commit -m "Initial commit: ${ASSISTANT_NAME}

Category: ${CATEGORY}
Description: ${DESCRIPTION}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${GREEN}✅ ${ASSISTANT_NAME} repository created!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Location: ${REPO_PATH}"
echo ""
echo "Next steps:"
echo "1. Edit ${REPO_PATH}/assistant.md with the assistant prompt"
echo "2. Add any custom commands to ${REPO_PATH}/commands/"
echo "3. Add any tools to ${REPO_PATH}/tools/"
echo "4. Run ./install.sh to install the assistant"
echo "5. Use /save-assistant to sync with Notion"
echo ""
