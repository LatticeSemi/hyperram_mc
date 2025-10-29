# Git Hooks for HyperRAM Memory Controller

This directory contains Git hooks that help maintain code quality.

## Available Hooks

### pre-commit

Runs automatically before each commit to check:
- ✅ No trailing whitespace
- ✅ No tab characters (enforces spaces)
- ✅ UTF-8 file encoding
- ✅ LF line endings (Unix-style)
- ✅ Python syntax (if Python files)
- ✅ XML well-formedness (if xmllint installed)
- ✅ No large files (>1MB)

## Installation

### Automatic (Linux/macOS/Git Bash on Windows)

```bash
./hooks/install-hooks.sh
```

### Manual Installation

Copy the hook to your `.git/hooks` directory:

```bash
# Linux/macOS/Git Bash
cp hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Windows PowerShell
Copy-Item hooks/pre-commit .git/hooks/pre-commit
icacls .git\hooks\pre-commit /grant Everyone:RX
```

## Usage

Once installed, the hook runs automatically:

```bash
git add file.v
git commit -m "Add feature"
# Hook runs here automatically
```

### Skipping the Hook

If you need to skip the checks (not recommended):

```bash
git commit --no-verify
```

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

