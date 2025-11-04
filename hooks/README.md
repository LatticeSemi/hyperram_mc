# Git Hooks for HyperRAM Memory Controller

This directory contains Git hooks that help maintain code quality.

## Available Hooks

### pre-commit

Runs automatically before each commit to check:
- 🛡️ **Blocks direct commits to main branch**
- ✅ No trailing whitespace
- ✅ No tab characters (enforces spaces)
- ✅ UTF-8 file encoding
- ✅ LF line endings (Unix-style)
- ✅ Python syntax (if Python files)
- ✅ XML well-formedness (if xmllint installed)
- ✅ No large files (>1MB)

### pre-push

Runs automatically before pushing to remote:
- 🛡️ **Blocks direct pushes to main branch**
- ✅ Enforces pull request workflow
- ✅ Ensures code review process

## Installation

### Automatic (Linux/macOS/Git Bash on Windows)

```bash
./hooks/install-hooks.sh
```

### Manual Installation

Copy the hooks to your `.git/hooks` directory:

```bash
# Linux/macOS/Git Bash
cp hooks/pre-commit .git/hooks/pre-commit
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push

# Windows PowerShell
Copy-Item hooks/pre-commit .git/hooks/pre-commit
Copy-Item hooks/pre-push .git/hooks/pre-push
icacls .git\hooks\pre-commit /grant Everyone:RX
icacls .git\hooks\pre-push /grant Everyone:RX
```

## Usage

Once installed, the hooks run automatically:

```bash
# This will be BLOCKED if on main branch
git add file.v
git commit -m "Add feature"  # pre-commit hook runs here

# This will be BLOCKED if pushing to main
git push origin main  # pre-push hook runs here
```

### Main Branch Protection

**Commits to main branch are BLOCKED:**
```bash
$ git checkout main
$ git commit -m "Direct commit to main"
❌ COMMIT TO MAIN BLOCKED!
You cannot commit directly to the main branch.
```

**Pushes to main branch are BLOCKED:**
```bash
$ git push origin main
❌ PUSH TO MAIN BLOCKED!
You cannot push directly to the main branch.
```

**Proper workflow:**
```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Commit to feature branch (allowed)
git commit -m "Add feature"

# 3. Push feature branch (allowed)
git push origin feature/my-feature

# 4. Create Pull Request on GitHub
```

### Skipping the Hooks

If you absolutely need to bypass (NOT RECOMMENDED):

```bash
# Skip commit checks
git commit --no-verify

# Skip push checks
git push --no-verify
```

**⚠️ Warning:** Bypassing hooks defeats the purpose of code review and CI/CD!

## What Gets Checked

### For Verilog/SystemVerilog Files (.v, .sv)
- Trailing whitespace
- Tab characters (should use 2 spaces)
- UTF-8 encoding
- LF line endings

### For XML Files (.xml)
- Trailing whitespace
- Tab characters (should use 4 spaces)
- UTF-8 encoding
- XML syntax validation (if xmllint installed)

### For Python Files (.py)
- Trailing whitespace
- Tab characters (should use 4 spaces)
- UTF-8 encoding
- Python syntax errors

## Dependencies

### Required
- Git
- Bash (included with Git for Windows)

### Optional (Enhanced Checks)
- **xmllint**: For XML validation
  ```bash
  # Ubuntu/Debian
  sudo apt-get install libxml2-utils

  # macOS
  brew install libxml2
  ```

- **Python 3**: For Python syntax checking
  - Usually pre-installed on Linux/macOS
  - Windows: Download from https://python.org

## Troubleshooting

### Hook Not Running

Check if the hook is executable:
```bash
ls -l .git/hooks/pre-commit
# Should show: -rwxr-xr-x
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Windows Line Ending Issues

If you see CRLF warnings, convert files to LF:
```bash
# Install dos2unix
# Then convert file:
dos2unix filename.v
```

Or configure Git to handle line endings:
```bash
git config --global core.autocrlf input
```

## Customization

Edit `hooks/pre-commit` to:
- Add/remove checks
- Change severity levels
- Add project-specific validation
- Modify error messages

After editing, reinstall:
```bash
./hooks/install-hooks.sh
```

## For Team Members

When you clone this repository:
1. Navigate to the repository
2. Run: `./hooks/install-hooks.sh`
3. Hooks are now active!

The hooks are stored in `hooks/` directory (tracked by Git) but must be installed to `.git/hooks/` (not tracked) to work.

