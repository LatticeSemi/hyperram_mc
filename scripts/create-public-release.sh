#!/bin/bash
# =============================================================================
# HyperRAM IP Release Script (Three Remote Strategy)
# =============================================================================
# This script creates release branches with only selected files/directories
# and automatically manages version numbering.
#
# Three Remote Repositories:
#   origin  - Private development repo (main, feature, develop branches)
#   public  - Public release repo (major/minor/bugfix releases only)
#   staging - Private internal staging repo (internal releases only)
#
# Version Format: X.Y.Z.##
#   X  = Major release (breaking changes)
#   Y  = Minor release (new features, backward compatible)
#   Z  = Bugfix release (bug fixes only)
#   ## = Internal release counter (2 digits)
#
# Usage:
#   ./create-public-release.sh <type> "<message>" ["<revision_description>"]
#
# Examples (External Releases - require revision description):
#   ./create-public-release.sh major "Complete redesign of controller FSM" "Major redesign for improved performance"
#   ./create-public-release.sh minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices"
#   ./create-public-release.sh bugfix "Fixed timing issue in read path" "Fixed read timing violation"
#
# Examples (Internal Releases - revision description optional):
#   ./create-public-release.sh internal "Internal testing build"
#
# =============================================================================

set -e  # Exit on error

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
VERSION_FILE="VERSION"
METADATA_FILE="metadata.xml"

# Directories/files to include in public release
PUBLIC_DIRS=(
    "rtl/"
    "doc/"
    "plugin/"
)

PUBLIC_FILES=(
    "README.md"
    "QUICKSTART.md"
    "soc/"
    "metadata.xml"
    "bus_interface.xml"
    "memory_map.xml"
)

# Patterns to exclude (even if inside public directories)
EXCLUDE_PATTERNS=(
    "*.bak"
    "*~"
    "INTERNAL_*"
    "TODO*"
    ".DS_Store"
)

# -----------------------------------------------------------------------------
# Color output
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

error()   { echo -e "${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
info()    { echo -e "${BLUE}ℹ $1${NC}"; }

# -----------------------------------------------------------------------------
# Update revision history in doc/introduction.html
# -----------------------------------------------------------------------------
update_revision_history() {
    local version=$1
    local description=$2
    local html_file="doc/introduction.html"

    if [ ! -f "$html_file" ]; then
        warning "doc/introduction.html not found, skipping revision history update"
        return 0
    fi

    info "Updating revision history in $html_file..."

    # Create new table row
    local new_row="    <TR>\n      <TD><B>${version}</B></TD> <TD>${description}</TD>\n    </TR>"

    # Use sed to insert the new row after the first <TR> (which is after the table opening)
    # The revision history table structure is:
    #   <TABLE cellpadding="10">
    #     <TR>
    #       <TD><B>version</B></TD> <TD>description</TD>
    #     </TR>
    #   </TABLE>
    #
    # We want to insert the new row as the FIRST row in the table

    # Using awk to find the table and insert after the <TABLE> line
    awk -v new_row="$new_row" '
        /<H2>Revision History<\/H2>/ {
            in_section=1
        }
        in_section && /<TABLE/ {
            print
            print new_row
            in_section=0
            next
        }
        { print }
    ' "$html_file" > "${html_file}.tmp"

    mv "${html_file}.tmp" "$html_file"
    success "Revision history updated with version $version"
}

# -----------------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------------
usage() {
    cat << EOF
Usage: $0 <type> "<message>" ["<revision_description>"]

Release Types:
    major     - Increment X (X.Y.Z.##) - Breaking changes
    minor     - Increment Y (X.Y.Z.##) - New features (backward compatible)
    bugfix    - Increment Z (X.Y.Z.##) - Bug fixes only
    internal  - Increment ## (X.Y.Z.##) - Internal release (not public)

Arguments:
    type                 - Release type (major|minor|bugfix|internal)
    message              - Release message describing changes (quoted string)
    revision_description - Revision history description (REQUIRED for major/minor/bugfix, optional for internal)

Examples (External Releases):
    $0 major "Complete redesign of controller FSM" "Major redesign for improved performance"
    $0 minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices"
    $0 bugfix "Fixed timing issue in read path" "Fixed read timing violation"

Examples (Internal Releases):
    $0 internal "Internal testing build"

Version Format: X.Y.Z.##
    X  = Major version
    Y  = Minor version
    Z  = Bugfix version
    ## = Internal counter (2 digits)

Public Tags: vX.Y.Z (internal counter not shown for major/minor/bugfix)
Internal Tags: vX.Y.Z.## (full version for internal releases)

EOF
    exit 1
}

# -----------------------------------------------------------------------------
# Validate arguments
# -----------------------------------------------------------------------------
if [ $# -lt 2 ]; then
    error "Missing arguments"
    usage
fi

RELEASE_TYPE=$1
RELEASE_MESSAGE=$2
REVISION_DESCRIPTION=$3

# Validate release type
case "$RELEASE_TYPE" in
    major|minor|bugfix|internal)
        ;;
    *)
        error "Invalid release type: $RELEASE_TYPE"
        usage
        ;;
esac

if [ -z "$RELEASE_MESSAGE" ]; then
    error "Release message cannot be empty"
    usage
fi

# For external releases (major/minor/bugfix), require revision description
if [ "$RELEASE_TYPE" != "internal" ] && [ -z "$REVISION_DESCRIPTION" ]; then
    error "Revision description is REQUIRED for external releases (major/minor/bugfix)"
    error "This will be added to the revision history in doc/introduction.html"
    usage
fi

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------
info "Running pre-flight checks..."

# Check we're in the right directory
if [ ! -d "hyperram_mc" ]; then
    error "Must run from repository root (hyperram/ directory)"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    error "You have uncommitted changes. Commit or stash them first."
    git status --short
    exit 1
fi

# Ensure we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    warning "You're on branch '$CURRENT_BRANCH', not 'main'"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check that critical files exist
if [ ! -f "$METADATA_FILE" ]; then
    error "metadata.xml not found at: $METADATA_FILE"
    exit 1
fi

success "Pre-flight checks passed"

# -----------------------------------------------------------------------------
# Read current version
# -----------------------------------------------------------------------------
if [ ! -f "$VERSION_FILE" ]; then
    warning "VERSION file not found. Creating with version 1.0.0.00"
    echo "1.0.0.00" > "$VERSION_FILE"
    git add "$VERSION_FILE"
    git commit -m "Initialize VERSION file"
fi

CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
info "Current version: $CURRENT_VERSION"

# Parse version components
if [[ ! $CURRENT_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]{2})$ ]]; then
    error "Invalid version format in VERSION file: $CURRENT_VERSION"
    error "Expected format: X.Y.Z.## (e.g., 1.2.3.05)"
    exit 1
fi

MAJOR=${BASH_REMATCH[1]}
MINOR=${BASH_REMATCH[2]}
BUGFIX=${BASH_REMATCH[3]}
INTERNAL=${BASH_REMATCH[4]}

# -----------------------------------------------------------------------------
# Calculate new version
# -----------------------------------------------------------------------------
case "$RELEASE_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        BUGFIX=0
        INTERNAL=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        BUGFIX=0
        INTERNAL=0
        ;;
    bugfix)
        BUGFIX=$((BUGFIX + 1))
        INTERNAL=0
        ;;
    internal)
        INTERNAL=$((INTERNAL + 1))
        ;;
esac

# Format internal counter as 2 digits
INTERNAL_FORMATTED=$(printf "%02d" $INTERNAL)
NEW_VERSION="${MAJOR}.${MINOR}.${BUGFIX}.${INTERNAL_FORMATTED}"

# Determine target remote and branch prefix based on release type
if [ "$RELEASE_TYPE" = "internal" ]; then
    TARGET_REMOTE="staging"
    BRANCH_PREFIX="staging"
    RELEASE_TAG="v${NEW_VERSION}"
    IS_PUBLIC_RELEASE=false
else
    TARGET_REMOTE="public"
    BRANCH_PREFIX="release"
    RELEASE_TAG="v${MAJOR}.${MINOR}.${BUGFIX}"
    IS_PUBLIC_RELEASE=true
fi

info "New version: $NEW_VERSION"
info "Release tag: $RELEASE_TAG"
info "Target remote: $TARGET_REMOTE"

# -----------------------------------------------------------------------------
# Confirmation
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
echo "Release Summary"
echo "========================================="
echo "Type:           $RELEASE_TYPE"
echo "Current:        $CURRENT_VERSION"
echo "New Version:    $NEW_VERSION"
echo "Release Tag:    $RELEASE_TAG"
echo "Target Remote:  $TARGET_REMOTE"
echo "Branch Prefix:  $BRANCH_PREFIX"
echo "Public Release: $IS_PUBLIC_RELEASE"
echo "Message:        $RELEASE_MESSAGE"
if [ -n "$REVISION_DESCRIPTION" ]; then
    echo "Revision Desc:  $REVISION_DESCRIPTION"
fi
echo "========================================="
echo ""

read -p "Proceed with release? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Release cancelled"
    exit 0
fi

# -----------------------------------------------------------------------------
# Update VERSION file on main branch
# -----------------------------------------------------------------------------
info "Updating VERSION file on main branch..."
echo "$NEW_VERSION" > "$VERSION_FILE"
git add "$VERSION_FILE"
git commit -m "Bump version to $NEW_VERSION for $RELEASE_TYPE release"
success "VERSION file updated on main"

# -----------------------------------------------------------------------------
# Create release branch
# -----------------------------------------------------------------------------
RELEASE_BRANCH="${BRANCH_PREFIX}/v${NEW_VERSION}"
info "Creating orphan release branch: $RELEASE_BRANCH"

# Create orphan branch (no shared history)
git checkout --orphan "$RELEASE_BRANCH"

# Remove everything
git rm -rf . > /dev/null 2>&1 || true

# -----------------------------------------------------------------------------
# Copy public files/directories from main
# -----------------------------------------------------------------------------
info "Copying public files from main..."

# Copy directories
for dir in "${PUBLIC_DIRS[@]}"; do
    if git cat-file -e main:"$dir" 2>/dev/null; then
        info "  Copying directory: $dir"
        git checkout main -- "$dir" 2>/dev/null || warning "Failed to copy $dir"
    else
        warning "  Directory not found on main: $dir (skipping)"
    fi
done

# Copy individual files (may not exist yet)
for file in "${PUBLIC_FILES[@]}"; do
    if git cat-file -e main:"$file" 2>/dev/null; then
        info "  Copying file: $file"
        git checkout main -- "$file" 2>/dev/null || true
    else
        warning "  File not found on main: $file (will be included when created)"
    fi
done

success "Files copied"

# -----------------------------------------------------------------------------
# Clean up excluded patterns
# -----------------------------------------------------------------------------
info "Removing excluded patterns..."
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    find . -name "$pattern" -type f -delete 2>/dev/null || true
done
success "Cleanup complete"

# -----------------------------------------------------------------------------
# Update version in metadata.xml
# -----------------------------------------------------------------------------
if [ -f "$METADATA_FILE" ]; then
    info "Updating version in metadata.xml..."

    # Update version tag (handle both with and without namespace prefix)
    sed -i.bak "s|<lsccip:version>.*</lsccip:version>|<lsccip:version>${MAJOR}.${MINOR}.${BUGFIX}</lsccip:version>|g" "$METADATA_FILE"
    sed -i.bak "s|<version>.*</version>|<version>${MAJOR}.${MINOR}.${BUGFIX}</version>|g" "$METADATA_FILE"

    rm -f "${METADATA_FILE}.bak"
    success "metadata.xml updated with version ${MAJOR}.${MINOR}.${BUGFIX}"
fi

# -----------------------------------------------------------------------------
# Update revision history in doc/introduction.html (for external releases only)
# -----------------------------------------------------------------------------
if [ "$IS_PUBLIC_RELEASE" = true ] && [ -n "$REVISION_DESCRIPTION" ]; then
    update_revision_history "${MAJOR}.${MINOR}.${BUGFIX}" "$REVISION_DESCRIPTION"
fi

# -----------------------------------------------------------------------------
# Create VERSION file in release branch
# -----------------------------------------------------------------------------
echo "$NEW_VERSION" > "$VERSION_FILE"
git add "$VERSION_FILE"

# -----------------------------------------------------------------------------
# Create LICENSE file if not present
# -----------------------------------------------------------------------------
if [ ! -f "LICENSE" ]; then
    info "Creating LICENSE file..."
    cat > LICENSE << 'EOF'
Copyright (c) 2024 Lattice Semiconductor Corporation

This HyperRAM Memory Controller IP is provided under the Lattice Reference
Design License Agreement.

For license terms, please refer to the Lattice Semiconductor website or
contact Lattice Semiconductor directly.
EOF
    git add LICENSE
    success "LICENSE file created"
fi

# -----------------------------------------------------------------------------
# List files to be released
# -----------------------------------------------------------------------------
echo ""
info "Files in release branch:"
git ls-files | while read file; do
    echo "  - $file"
done
echo ""

# -----------------------------------------------------------------------------
# Final confirmation
# -----------------------------------------------------------------------------
read -p "Commit and tag this release? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    error "Release aborted. Cleaning up..."
    git checkout main
    git branch -D "$RELEASE_BRANCH" 2>/dev/null || true
    # Revert VERSION file update
    git reset --hard HEAD~1
    exit 1
fi

# -----------------------------------------------------------------------------
# Commit release
# -----------------------------------------------------------------------------
info "Committing release..."
git add -A

COMMIT_MSG="Release ${RELEASE_TAG}

Type: ${RELEASE_TYPE}
Version: ${NEW_VERSION}
Target: ${TARGET_REMOTE}

${RELEASE_MESSAGE}
"

git commit -m "$COMMIT_MSG"
success "Release committed"

# -----------------------------------------------------------------------------
# Create tag
# -----------------------------------------------------------------------------
info "Creating tag: $RELEASE_TAG"
git tag -a "$RELEASE_TAG" -m "$COMMIT_MSG"
success "Tag created: $RELEASE_TAG"

# -----------------------------------------------------------------------------
# Success message
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
success "Release ${RELEASE_TAG} created successfully!"
echo "========================================="
echo ""
echo "Branch: $RELEASE_BRANCH"
echo "Tag:    $RELEASE_TAG"
echo "Remote: $TARGET_REMOTE"
echo ""
echo "Next steps:"
echo "========================================="
echo ""

if [ "$IS_PUBLIC_RELEASE" = true ]; then
    echo "PUBLIC RELEASE (major/minor/bugfix)"
    echo "-----------------------------------"
    echo ""
    echo "1. Review the release branch:"
    echo "   git log --oneline --graph $RELEASE_BRANCH"
    echo ""
    echo "2. Review files in release:"
    echo "   git ls-tree -r --name-only $RELEASE_BRANCH"
    echo ""
    echo "3. Push to PUBLIC remote:"
    echo "   git push public $RELEASE_BRANCH:main --force"
    echo "   git push public $RELEASE_TAG"
    echo ""
    echo "4. Push to ORIGIN (development) remote:"
    echo "   git checkout main"
    echo "   git push origin main"
    echo "   git push origin $RELEASE_TAG"
    echo ""
    echo "5. Optionally push to STAGING for record:"
    echo "   git push staging $RELEASE_TAG"
else
    echo "INTERNAL RELEASE (staging only)"
    echo "-------------------------------"
    echo ""
    echo "1. Review the release branch:"
    echo "   git log --oneline --graph $RELEASE_BRANCH"
    echo ""
    echo "2. Review files in release:"
    echo "   git ls-tree -r --name-only $RELEASE_BRANCH"
    echo ""
    echo "3. Push to STAGING remote (internal testing):"
    echo "   git push staging $RELEASE_BRANCH:main --force"
    echo "   git push staging $RELEASE_TAG"
    echo ""
    echo "4. Push to ORIGIN (development) remote:"
    echo "   git checkout main"
    echo "   git push origin main"
    echo "   git push origin $RELEASE_TAG"
    echo ""
    echo "5. DO NOT push to PUBLIC (this is internal only)"
    echo ""
    echo "6. To test: git checkout $RELEASE_BRANCH"
fi

echo ""
echo "To return to main branch:"
echo "   git checkout main"
echo ""
echo "========================================="

exit 0

