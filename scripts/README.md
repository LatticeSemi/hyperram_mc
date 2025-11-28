# Release Scripts

This directory contains automation scripts for IP release management.

## Release Structure Overview

This script implements a **two-remote release strategy** where one local repository pushes to development and public remotes:

```
┌────────────────────────────────────────────────┐
│   YOUR LOCAL: hyperram_mc/                     │
│                                                │
│   Branches:                                    │
│   • main (active development)                  │
│   • feature/new-feature                        │
│   • release/v1.0.0 (for external release)      │
└────────────────────────────────────────────────┘
       │                          │
       │                          │
       ↓                          ↓
┌─────────────┐          ┌─────────────┐
│   ORIGIN    │          │   PUBLIC    │
│ (private)   │          │  (public)   │
│             │          │             │
│ • main      │          │ • release   │
│ • feature/* │          │ • tags      │
│ ALL history │          │             │
└─────────────┘          └─────────────┘
```

**Key Points:**
- **One local repository** - All work happens in one place
- **Two remotes:**
  - `origin` - Private development repo (main branch for development, full history)
  - `public` - Public release repo (release branch for external releases)
- **Branch separation:**
  - `main` branch → development work
  - `release/*` branches → pushed to `public` remote (major/minor/bugfix releases)
- **Clean history** - Public repo has clean, isolated history

---

## create-public-release.sh

Automated script for creating public releases with version management.

### Features

- ✅ **Automatic version incrementing** based on release type
- ✅ **Selective file inclusion** - only public files in release
- ✅ **Version format: X.Y.Z**
  - X = Major (breaking changes)
  - Y = Minor (new features)
  - Z = Bugfix (fixes only)
- ✅ **Orphan branches** - no shared history with private repo
- ✅ **Automatic metadata.xml version updates**
- ✅ **Automatic IP Release Notes.md revision history updates**
- ✅ **Tag-based releases** - select a specific tag or commit to base release on
- ✅ **Safety checks** - prevents accidental releases with uncommitted changes
- ✅ **Interactive confirmation** before committing

### Usage

```bash
./scripts/create-public-release.sh <type> "<message>" "<revision_description>" ["<software_version>"]
```

**Release Types:**

| Type | Increments | Use Case | Tag | Target Remote |
|------|------------|----------|-----|---------------|
| `major` | X.0.0 | Breaking changes | vX.0.0 | `public` |
| `minor` | 0.Y.0 | New features (backward compatible) | v0.Y.0 | `public` |
| `bugfix` | 0.0.Z | Bug fixes only | v0.0.Z | `public` |

### Examples

**Major Release:**
```bash
./scripts/create-public-release.sh major "Complete redesign of controller FSM" "Major redesign for improved performance and reduced latency" "2025.2"
```
- Current: 1.2.3 → New: 2.0.0
- Tag: v2.0.0
- Revision history updated with: "Major redesign for improved performance and reduced latency"

**Minor Release:**
```bash
./scripts/create-public-release.sh minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices" "2025.2"
```
- Current: 1.2.3 → New: 1.3.0
- Tag: v1.3.0
- Revision history updated with: "Added support for dual-rank HyperRAM devices"

**Bugfix Release:**
```bash
./scripts/create-public-release.sh bugfix "Fixed timing issue in read path" "Fixed read timing violation in high-speed mode" "2025.1.1"
```
- Current: 1.2.3 → New: 1.2.4
- Tag: v1.2.4
- Revision history updated with: "Fixed read timing violation in high-speed mode"

### What Gets Released

The script includes **only these files/directories** in releases:

```
release/vX.Y.Z branch contains:
├── rtl/                 # All RTL files
├── doc/                 # Documentation
├── plugin/              # Plugin scripts
├── testbench/           # Testbench files
├── sim/                 # Simulation scripts, memory init files, prebuilt libraries
├── example_design/      # Example Radiant/Propel projects
├── metadata.xml         # IP metadata (includes version)
├── bus_interface.xml    # Bus interface definitions
├── memory_map.xml       # Memory map definitions
├── README.md            # Project README
├── QUICKSTART.md        # Quick start guide (when created)
├── IP Release Notes.md  # IP Release Notes, containing revision histories
└── license.txt          # License Agreement
```

**Excluded (stays private):**
- `IP_RELEASE_CHECKLIST.md`
- `.editorconfig`
- `.cursor/`
- `hooks/`
- Any `INTERNAL_*` files
- Backup files (`*.bak`, `*~`)

**Excluded from git (via .gitignore):**
- Simulation artifacts (`*.wlf`, `*.log`, `transcript`)
- Compiled working directory (`work/`)
- These files are never committed to git, so they won't be in releases

**Included in sim/ directory (committed to git and released):**
- ✅ `bht_ini.bin` - Required by cpu0.v during simulation
- ✅ Prebuilt libraries in `sim/lfmxo5/`, `sim/pmi/`, `sim/uaplatform/` (all compiled artifacts)
- ✅ Simulation scripts (`.do`, `.f`)
- ✅ Memory init files (`.mem`, `.bin`, `.txt`)

### Automatic Revision History Updates

The script automatically updates the revision history in `IP Release Notes.md` for all releases:

**What happens:**
1. You provide a revision description when running the script (3rd parameter)
2. Script automatically adds a new version section to the release notes
3. New section contains: version number, software version, and your description (formatted as bullet points)
4. Inserted at the TOP of the release notes (most recent first)

**Example:**

Running this command:
```bash
./scripts/create-public-release.sh minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices; Improved timing" "2025.2"
```

Updates `IP Release Notes.md` with a new version section containing the changes formatted as bullet points.


### Workflow

1. **Prepare:**
   ```bash
   git checkout main
   git pull origin main
   git status  # Ensure clean working directory
   ```

2. **Run Script:**
   ```bash
   # For external release (major/minor/bugfix) - include revision description and software version
   ./scripts/create-public-release.sh minor "Added new feature X" "Added feature X for improved functionality" "2025.2"
   ```

3. **Tag Selection:**
   - If the release tag doesn't exist, script will prompt you to:
     - Select a commit from recent history (1-10)
     - Use HEAD (current commit)
     - Provide a specific commit SHA
     - Use an existing tag
   - Script creates the tag at the selected commit in the main branch
   - If tag already exists, you can choose to use it or cancel

4. **Review:**
   - Script shows summary and asks for confirmation
   - Review files to be released
   - Confirm version increment
   - Check revision description
   - Verify source tag/commit

5. **Script Automatically:**
   - Creates tag in main branch (if not already exists)
   - Updates metadata.xml version on main (X.Y.Z format)
   - Creates orphan release branch from the selected tag
   - Copies only public files from the tagged commit
   - Updates IP Release Notes.md revision history
   - Creates commit in release branch

6. **Push (Manual):**
   ```bash
   # Push to PUBLIC remote (release branch)
   git push public release/vX.Y.Z:release --force
   git push public vX.Y.Z

   # Push to ORIGIN (development)
   git checkout main
   git push origin main
   git push origin vX.Y.Z
   ```

### Prerequisites

- Git configured with **two remotes:**
  - `origin` - Private development repository (main branch for development)
  - `public` - Public release repository (release branch for external releases)
- On `main` branch with no uncommitted changes
- `metadata.xml` exists with valid version

### Setup Git Remotes

```bash
# View current remotes
git remote -v

# Add public remote (public, for external releases)
git remote add public git@github.com:yourorg/hyperram-mc-public.git

# Verify remotes
git remote -v
# origin   git@private-server:yourorg/hyperram-internal.git (fetch)
# origin   git@private-server:yourorg/hyperram-internal.git (push)
# public   git@github.com:yourorg/hyperram-mc-public.git (fetch)
# public   git@github.com:yourorg/hyperram-mc-public.git (push)
```

**Remote Strategy:**
- **origin**: Development work, main branch, full history
- **public**: Public releases, release branch only (major/minor/bugfix)

### Version Management (metadata.xml)

The script uses `metadata.xml` as the **single source of truth** for versioning:

```xml
<lsccip:version>1.0.0</lsccip:version>
```

**Format:** `X.Y.Z`

**How it works:**
- Version follows semantic versioning (X.Y.Z format)
- Automatically updated on `main` branch by the script
- Copied to release branch

**Version Progression Example:**
```
Initial:        metadata.xml = 1.0.0
Bugfix release: metadata.xml = 1.0.1
Minor release:  metadata.xml = 1.1.0
Major release:  metadata.xml = 2.0.0
```

### Error Handling

The script performs safety checks:

- ❌ Not in repository root directory
- ❌ Uncommitted changes detected
- ❌ Invalid release type
- ❌ Empty release message
- ❌ Invalid metadata.xml version format
- ❌ Missing critical files (metadata.xml)
- ❌ Missing revision description (for external releases)

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

**"Invalid version format in metadata.xml"**
Ensure metadata.xml contains a valid version in `X.Y.Z` format:
```xml
<lsccip:version>1.0.0</lsccip:version>
```

**Want to abort a release?**
Press `n` when prompted for confirmation. The script will clean up automatically and revert the metadata.xml update.

**Release branch still exists after abort?**
```bash
git checkout main
git branch -D release/vX.Y.Z
```

**Need to redo a release?**
```bash
# Delete the release branch
git branch -D release/vX.Y.Z

# Delete the tag
git tag -d vX.Y.Z

# Revert metadata.xml version update
git reset --hard HEAD~1

# Rerun the script
./scripts/create-public-release.sh ...
```

### Best Practices

1. **Always review** the files list before confirming
2. **Update documentation** before creating release
3. **Run checklist** (IP_RELEASE_CHECKLIST.md) before release
4. **Tag messages** should be descriptive
5. **Ensure CI passes** before creating release

### See Also

- [IP_RELEASE_CHECKLIST.md](../IP_RELEASE_CHECKLIST.md) - Complete release checklist
- [metadata.xml](../metadata.xml) - IP metadata (includes version)
- [README.md](../README.md) - Project README

