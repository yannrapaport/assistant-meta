#!/bin/bash

# Meta Assistant Installer
# Sets up bootstrap commands for loading and managing assistants

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Meta Assistant Installer"
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

echo "📦 Installing bootstrap commands..."

# Copy load-assistant command
if [ -f "$SCRIPT_DIR/commands/load-assistant.md" ]; then
    cp "$SCRIPT_DIR/commands/load-assistant.md" "$COMMANDS_DIR/"
    echo "  ✓ Installed /load-assistant command"
else
    echo "  ⚠️  load-assistant.md not found in $SCRIPT_DIR/commands/"
fi

# Copy save-assistant command
if [ -f "$SCRIPT_DIR/commands/save-assistant.md" ]; then
    cp "$SCRIPT_DIR/commands/save-assistant.md" "$COMMANDS_DIR/"
    echo "  ✓ Installed /save-assistant command"
else
    echo "  ⚠️  save-assistant.md not found in $SCRIPT_DIR/commands/"
fi

echo ""
echo "🔧 Installing tools..."

# Copy status line script
if [ -f "$SCRIPT_DIR/tools/statusline.sh" ]; then
    cp "$SCRIPT_DIR/tools/statusline.sh" "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/statusline.sh"
    echo "  ✓ Installed statusline.sh"
else
    echo "  ⚠️  statusline.sh not found in $SCRIPT_DIR/tools/"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Meta Assistant installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Configure status line in ~/.claude/settings.json:"
echo "   {"
echo "     \"statusline\": {"
echo "       \"script\": \"~/.config/claude-code/statusline.sh\""
echo "     }"
echo "   }"
echo ""
echo "2. Restart Claude Code"
echo ""
echo "3. Load the Meta Assistant:"
echo "   /load-assistant $SCRIPT_DIR/assistant.md"
echo ""
echo "4. Start managing your assistants!"
echo ""
