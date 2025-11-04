# Release Scripts

This directory contains automation scripts for IP release management.

## Release Structure Overview

This script implements a **three-remote release strategy** where one local repository pushes to development, staging, and public remotes:

```
┌────────────────────────────────────────────────┐
│   YOUR LOCAL: hyperram_mc/                     │
│                                                │
│   Branches:                                    │
│   • main (active development)                  │
│   • develop                                    │
│   • feature/new-feature                        │
│   • release/v1.0.0 (for public)                │
│   • staging/v1.0.0.01 (for internal)           │
└────────────────────────────────────────────────┘
       │                │                 │
       │                │                 │
       ↓                ↓                 ↓
┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│   ORIGIN    │  │   STAGING    │  │   PUBLIC    │
│ (private)   │  │  (private)   │  │  (public)   │
│             │  │              │  │             │
│ • main      │  │ • main ──────┼─→│ • release   │
│ • develop   │  │ • tags       │  │ • tags      │
│ • feature/* │  │              │  │             │
│ ALL history │  │ STAGING only │  │ PUBLIC only │
└─────────────┘  └──────────────┘  └─────────────┘
```

**Key Points:**
- **One local repository** - All work happens in one place
- **Three remotes:**
  - `origin` - Private development repo (all branches, full history)
  - `staging` - Private internal staging repo (internal releases only)
  - `public` - Public release repo (public releases only)
- **Branch separation:**
  - `release/*` branches → pushed to `public` remote (major/minor/bugfix)
  - `staging/*` branches → pushed to `staging` remote (internal releases)
- **Clean history** - Both staging and public repos have clean, isolated history

---

## create-public-release.sh

Automated script for creating public releases with version management.

### Features

- ✅ **Automatic version incrementing** based on release type
- ✅ **Selective file inclusion** - only public files in release
- ✅ **Version format: X.Y.Z.##**
  - X = Major (breaking changes)
  - Y = Minor (new features)
  - Z = Bugfix (fixes only)
  - ## = Internal counter (2 digits)
- ✅ **Orphan branches** - no shared history with private repo
- ✅ **Automatic metadata.xml version updates**
- ✅ **Automatic doc/introduction.html revision history updates** for external releases
- ✅ **Safety checks** - prevents accidental releases with uncommitted changes
- ✅ **Interactive confirmation** before committing

### Usage

**For External Releases (major/minor/bugfix):**
```bash
./scripts/create-public-release.sh <type> "<message>" "<revision_description>"
```

**For Internal Releases:**
```bash
./scripts/create-public-release.sh internal "<message>"
```

**Release Types:**

| Type | Increments | Use Case | Tag | Target Remote |
|------|------------|----------|-----|---------------|
| `major` | X.0.0.00 | Breaking changes | vX.0.0 | `public` |
| `minor` | 0.Y.0.00 | New features (backward compatible) | v0.Y.0 | `public` |
| `bugfix` | 0.0.Z.00 | Bug fixes only | v0.0.Z | `public` |
| `internal` | 0.0.0.## | Internal testing | v0.0.0.## | `staging` |

### Examples

**Major Release:**
```bash
./scripts/create-public-release.sh major "Complete redesign of controller FSM" "Major redesign for improved performance and reduced latency"
```
- Current: 1.2.3.05 → New: 2.0.0.00
- Tag: v2.0.0
- Revision history updated with: "Major redesign for improved performance and reduced latency"

**Minor Release:**
```bash
./scripts/create-public-release.sh minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices"
```
- Current: 1.2.3.05 → New: 1.3.0.00
- Tag: v1.3.0
- Revision history updated with: "Added support for dual-rank HyperRAM devices"

**Bugfix Release:**
```bash
./scripts/create-public-release.sh bugfix "Fixed timing issue in read path" "Fixed read timing violation in high-speed mode"
```
- Current: 1.2.3.05 → New: 1.2.4.00
- Tag: v1.2.4
- Revision history updated with: "Fixed read timing violation in high-speed mode"

**Internal Release:**
```bash
./scripts/create-public-release.sh internal "Internal test build"
```
- Current: 1.2.3.05 → New: 1.2.3.06
- Tag: v1.2.3.06
- No revision history update (internal only)
- Branch: staging/v1.2.3.06
- Target: staging remote (private only, NOT pushed to public)

### What Gets Released

The script includes **only these files/directories** in public releases:

```
release/vX.Y.Z.## branch contains:
├── rtl/                 # All RTL files
├── doc/                 # Documentation
├── plugin/              # Plugin scripts
├── metadata.xml         # IP metadata
├── bus_interface.xml    # Bus interface definitions
├── memory_map.xml       # Memory map definitions
├── README.md            # Project README
├── QUICKSTART.md        # Quick start guide (when created)
├── soc/                 # Integration examples (when created)
├── VERSION              # Version file
└── LICENSE              # License file
```

**Excluded (stays private):**
- `IP_RELEASE_CHECKLIST.md`
- `.editorconfig`
- `.cursor/`
- `hooks/`
- Any `INTERNAL_*` files
- Backup files (`*.bak`, `*~`)

### Automatic Revision History Updates

For **external releases only** (major/minor/bugfix), the script automatically updates the revision history in `doc/introduction.html`:

**What happens:**
1. You provide a revision description when running the script (3rd parameter)
2. Script automatically adds a new row to the revision history table
3. New row contains: version number + your description
4. Inserted at the TOP of the table (most recent first)

**Example:**

Running this command:
```bash
./scripts/create-public-release.sh minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices"
```

Updates `doc/introduction.html` from:
```html
<H2>Revision History</H2>
<TABLE cellpadding="10">
  <TR>
    <TD><B>1.0.0</B></TD> <TD>Initial release.</TD>
  </TR>
</TABLE>
```

To:
```html
<H2>Revision History</H2>
<TABLE cellpadding="10">
  <TR>
    <TD><B>1.1.0</B></TD> <TD>Added support for dual-rank HyperRAM devices</TD>
  </TR>
  <TR>
    <TD><B>1.0.0</B></TD> <TD>Initial release.</TD>
  </TR>
</TABLE>
```

**Note:** Internal releases do NOT update the revision history (they're not published).

### Workflow

1. **Prepare:**
   ```bash
   git checkout main
   git pull origin main
   git status  # Ensure clean working directory
   ```

2. **Run Script:**
   ```bash
   # For external release (major/minor/bugfix) - include revision description
   ./scripts/create-public-release.sh minor "Added new feature X" "Added feature X for improved functionality"

   # For internal release - no revision description needed
   ./scripts/create-public-release.sh internal "Internal test build"
   ```

3. **Review:**
   - Script shows summary and asks for confirmation
   - Review files to be released
   - Confirm version increment
   - Check revision description (for external releases)

4. **Script Automatically:**
   - Updates VERSION file on main
   - Creates orphan release branch
   - Copies only public files
   - Updates metadata.xml version
   - Updates doc/introduction.html revision history (external releases only)
   - Creates commit and tag

5. **Push (Manual):**

   **Public Release (major/minor/bugfix):**
   ```bash
   # Push to PUBLIC remote
   git push public release/vX.Y.Z.##:main --force
   git push public vX.Y.Z

   # Push to ORIGIN (development)
   git checkout main
   git push origin main
   git push origin vX.Y.Z
   ```

   **Internal Release:**
   ```bash
   # Push to STAGING remote
   git push staging staging/vX.Y.Z.##:main --force
   git push staging vX.Y.Z.##

   # Push to ORIGIN (development)
   git checkout main
   git push origin main
   git push origin vX.Y.Z.##

   # Do NOT push to public
   ```

### Prerequisites

- Git configured with **three remotes:**
  - `origin` - Private development repository (all branches)
  - `staging` - Private internal staging repository (internal releases)
  - `public` - Public release repository (public releases only)
- On `main` branch with no uncommitted changes
- `VERSION` file exists (created automatically if missing)

### Setup Git Remotes

```bash
# View current remotes
git remote -v

# Add staging remote (private, for internal releases)
git remote add staging git@private-server:yourorg/hyperram-mc-staging.git

# Add public remote (public, for external releases)
git remote add public git@github.com:yourorg/hyperram-mc-public.git

# Verify all three remotes
git remote -v
# origin   git@private-server:yourorg/hyperram-internal.git (fetch)
# origin   git@private-server:yourorg/hyperram-internal.git (push)
# staging  git@private-server:yourorg/hyperram-mc-staging.git (fetch)
# staging  git@private-server:yourorg/hyperram-mc-staging.git (push)
# public   git@github.com:yourorg/hyperram-mc-public.git (fetch)
# public   git@github.com:yourorg/hyperram-mc-public.git (push)
```

**Remote Strategy:**
- **origin**: All development work, all branches, full history
- **staging**: Internal release testing, `staging/*` branches only
- **public**: Public releases, `release/*` branches only (major/minor/bugfix)

### VERSION File

The script maintains a `VERSION` file at the repository root:

```
1.2.3.05
```

Format: `X.Y.Z.##`
- Automatically incremented by script
- Updated on `main` branch
- Included in release branch

### Error Handling

The script performs safety checks:

- ❌ Not in repository root directory
- ❌ Uncommitted changes detected
- ❌ Invalid release type
- ❌ Empty release message
- ❌ Invalid VERSION file format
- ❌ Missing critical files (metadata.xml)

All checks must pass before proceeding.

### Troubleshooting

**"Must run from repository root"**
```bash
cd /path/to/hyperram/
./scripts/create-public-release.sh ...
```

**"You have uncommitted changes"**
```bash
git status
git add .
git commit -m "Commit message"
# Or stash changes
git stash
```

**"VERSION file not found"**
The script creates it automatically with version `1.0.0.00`.

**Want to abort a release?**
Press `n` when prompted for confirmation. The script will clean up automatically.

**Release branch still exists after abort?**
```bash
git checkout main
git branch -D release/vX.Y.Z.##
```

**Need to redo a release?**
```bash
# Delete the release branch
git branch -D release/vX.Y.Z.##

# Delete the tag
git tag -d vX.Y.Z.##

# Manually revert VERSION file (optional)
# Edit VERSION file to previous version
git add VERSION
git commit --amend

# Rerun the script
./scripts/create-public-release.sh ...
```

### Best Practices

1. **Always review** the files list before confirming
2. **Test internal releases** before public releases
3. **Update documentation** before creating release
4. **Run checklist** (IP_RELEASE_CHECKLIST.md) before release
5. **Tag messages** should be descriptive
6. **Internal releases** should not be pushed to public

### See Also

- [IP_RELEASE_CHECKLIST.md](../IP_RELEASE_CHECKLIST.md) - Complete release checklist
- [VERSION](../VERSION) - Current version number
- [README.md](../README.md) - Project README

