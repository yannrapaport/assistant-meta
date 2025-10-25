# Meta Assistant - TODO

Track ongoing work and future improvements for this assistant.

## In Progress

_Nothing currently in progress_

## Planned

### New Features

- **save-assistant default answers**: The command should propose default answers to questions based on current context
  - Example: If working in assistant-git repo, default name = "Git Assistant"
  - Example: If Meta Assistant is loaded, default category = "Meta"
  - Example: Infer description from conversation context

### Documentation

- **Managing assistants guide**: Add comprehensive documentation about:
  - Creating new assistants from scratch
  - Extracting assistants from conversations
  - Updating existing assistants
  - Syncing between git and Notion
  - Best practices for assistant design
  - Template for new assistants

### Bugs / Issues

- **Status line showing raw JSON**: Currently displaying raw JSON output instead of formatted status bar
  - Output: `{"sections": [{"text": "🤖 Meta Assistant", "color": "blue"},{"text": "📁 assistant-meta"}]}`
  - Expected: Formatted status bar with colored sections
  - May require Claude Code restart or version-specific configuration

## Completed

- ✅ Initial assistant-meta structure
- ✅ Bootstrap installation system (install.sh)
- ✅ /load-assistant command
- ✅ /save-assistant command
- ✅ Status line integration
- ✅ Multi-assistant support
- ✅ GitHub repository setup
- ✅ **Migration tooling**: Created scripts to reorganize assistant library
  - ✅ `create-assistant-repo.sh` - Generate new assistant repos from template
  - ✅ `migrate-assistants.sh` - Extract assistants from Notion to individual git repos
  - ✅ Successfully migrated all 6 assistants to independent repositories
- ✅ **Status line fix**: Updated settings.json to properly display active assistants
- ✅ **Permissions configuration**: Added default allow rules for common operations
  - ✅ File operations (Read, Write, Edit, Glob) in home directory
  - ✅ Notion API calls and database access
  - ✅ Git operations (commit, init)
  - ✅ Common bash commands (curl, python3, etc.)
- ✅ **Token optimization**: Reduced assistant from 799 to 318 words (-60%)
  - ✅ Extracted verbose content to docs/ (notion-api.md, workflows.md, compacting.md)
  - ✅ Implemented local-first loading with .meta tracking
  - ✅ Added lazy loading for docs extensions
  - ✅ Created compacting feature in /save-assistant
  - ✅ Documented optimization pattern for other assistants
  - ✅ Token savings: ~620 tokens per load

## Ideas / Future

- Auto-update bootstrap commands when Meta Assistant detects changes
- `/list-assistants` command to show all available assistants
- Assistant dependencies (e.g., LinkedIn assistant requires Content Manager)
- Assistant versioning and rollback
- Export/import assistants as shareable packages
- Analytics: which assistants are used most often

---

**Note:** This TODO.md is managed by the assistant itself. When you load this assistant and make progress, use `/save-assistant` to update this file along with other changes.
