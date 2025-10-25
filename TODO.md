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

## Completed

- ✅ Initial assistant-meta structure
- ✅ Bootstrap installation system (install.sh)
- ✅ /load-assistant command
- ✅ /save-assistant command
- ✅ Status line integration
- ✅ Multi-assistant support
- ✅ GitHub repository setup

## Ideas / Future

- Auto-update bootstrap commands when Meta Assistant detects changes
- `/list-assistants` command to show all available assistants
- Assistant dependencies (e.g., LinkedIn assistant requires Content Manager)
- Assistant versioning and rollback
- Export/import assistants as shareable packages
- Analytics: which assistants are used most often

---

**Note:** This TODO.md is managed by the assistant itself. When you load this assistant and make progress, use `/save-assistant` to update this file along with other changes.
