# Changelog - Meta Assistant

## 2025-10-27 - Notion Sync Centralization

### Added
- **Notion sync tools** (`tools/push-to-notion.sh`, `tools/sync-to-notion.py`)
  - Generic scripts to sync any assistant to Notion
  - Extracts `notion_page_id` from `.meta` file
  - Converts markdown to Notion blocks format
  - Updates sync tracking automatically

- **Auto-load mechanism** in `/save-assistant`
  - Checks if Meta Assistant is loaded before proceeding
  - Auto-loads Meta if not present
  - Prevents code duplication across assistants
  - Guards against infinite recursion in `/load-assistant`

### Changed
- **Quick Reference** - Added `tools/push-to-notion.sh` usage
- **Scope** - Clarified that Git/Notion sync is centralized in Meta
- **Architecture** - Documented auto-load pattern

### Impact
All assistants can now delegate Notion sync to Meta Assistant without duplicating sync logic.

---

## Previous Updates

See git history for earlier changes.
