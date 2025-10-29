# Cursor Workspace Rules

This directory contains AI rules that automatically apply to this project when opened in Cursor IDE.

## Current Rules

### `directorystructure.mdc`
**Purpose:** Enforces FPGA IP directory structure standards
**Status:** Always Applied
**Scope:** All file operations and AI suggestions

**What it does:**
- Ensures IP blocks follow standard directory layout
- Enforces naming conventions (e.g., `ip_name.sv`, `ip_name_tb.sv`)
- Requires proper documentation for each IP
- Guides integration example structure

## How Rules Work

1. **Automatic:** Rules apply when you open this project in Cursor
2. **AI-Powered:** AI assistant follows these rules automatically
3. **No Configuration:** No manual setup required
4. **Workspace-Specific:** Only affects this project

## For New Team Members

When you clone this repository and open it in Cursor:
- ✅ Rules load automatically
- ✅ AI suggestions follow project standards
- ✅ No manual configuration needed

## Modifying Rules

To update project rules:
1. Edit `.mdc` files in this directory
2. Commit changes to version control
3. Team members get updates via `git pull`
4. Cursor auto-reloads rules

## Rule Format

Rules are written in Markdown with YAML frontmatter:

```markdown
---
alwaysApply: true
---

# Rule Content

Your rule documentation here...
```

## More Information

- **Project Documentation:** See main `README.md`
- **Cursor Documentation:** https://cursor.sh/docs

---

**Note:** This directory should be committed to version control so all team members benefit from standardized AI behavior.

