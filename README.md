# Meta Assistant

A specialized Claude Code assistant for managing other assistants and Claude Code configurations.

## What is Meta Assistant?

Meta Assistant helps you:
- Create and manage Claude Code assistants
- Save assistants to Notion and git
- Configure Claude Code features (hooks, commands, status line)
- Maintain your assistant ecosystem
- Ensure sync between Notion and git repositories

## Installation

Run the installer to set up bootstrap commands:

```bash
cd ~/Documents/Dev/assistant-meta
./install.sh
```

This installs:
- `/load-assistant` - Bootstrap command to load assistants
- `/save-assistant` - Command to create/update assistants
- `statusline.sh` - Displays active assistants in Claude Code

## Usage

After installation and restarting Claude Code:

```bash
# Load the Meta Assistant
/load-assistant ~/Documents/Dev/assistant-meta/assistant.md

# Or from Notion (after syncing)
/load-assistant https://www.notion.so/Meta-Assistant-[page-id]
```

Once loaded, Meta Assistant can:
- Create new assistants with `/save-assistant`
- Update existing assistants
- Manage Claude Code configurations
- Check sync between Notion and git

## Directory Structure

```
assistant-meta/
├── README.md                    # This file
├── assistant.md                 # Meta Assistant prompt/instructions
├── TODO.md                      # Persistent todo list for this assistant
├── install.sh                   # Bootstrap installer
├── commands/
│   ├── load-assistant.md        # Load assistant command
│   └── save-assistant.md        # Save assistant command
├── tools/
│   └── statusline.sh           # Status line script
└── docs/
    └── (future documentation)
```

## Configuration

### Status Line

To see active assistants in your Claude Code status line, add to `~/.claude/settings.json`:

```json
{
  "statusline": {
    "script": "~/.config/claude-code/statusline.sh"
  }
}
```

### Notion Integration

Meta Assistant can sync with Notion. Configure your Notion API credentials in:
`~/.config/claude-code/notion-config.sh`

```bash
NOTION_API_KEY="your-api-key"
NOTION_VERSION="2022-06-28"
DATABASE_ID="29686de33aad807fbea3edb4899d1d2b"  # Your Assistant Library
```

## Features

### Multi-Assistant Support

Load multiple assistants simultaneously:
```bash
/load-assistant ~/Documents/Dev/assistant-git/assistant.md
/load-assistant ~/Documents/Dev/assistant-linkedin/assistant.md
```

All active assistants will show in your status line:
```
🤖 Git Assistant, LinkedIn Post Writer
```

### Self-Contained Bootstrap

Meta Assistant contains everything needed to bootstrap the assistant management system:
1. Install once with `./install.sh`
2. Load Meta Assistant with `/load-assistant`
3. Meta Assistant can update its own commands if needed

### Template for Other Assistants

Use this repository structure as a template for creating other assistants:
- Each assistant gets its own git repo
- Independent versioning and sharing
- Self-contained with docs and tools

## Development

Meta Assistant is itself managed by Meta Assistant! To update:

1. Load Meta Assistant
2. Make changes to the assistant
3. Use `/save-assistant` to update both git and Notion
4. Run `./install.sh` to update bootstrap commands if needed

### TODO List

Each assistant includes a `TODO.md` file for tracking:
- In-progress work
- Planned features
- Completed tasks
- Future ideas

See [TODO.md](TODO.md) for current Meta Assistant tasks.

When you make progress on a todo item, update the TODO.md and use `/save-assistant` to commit the changes.

## Requirements

- Claude Code v2.0+
- `jq` for JSON parsing: `brew install jq`
- Notion API key (optional, for Notion sync)

## License

MIT
