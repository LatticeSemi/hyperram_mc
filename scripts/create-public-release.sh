#!/bin/bash
# =============================================================================
# HyperRAM IP Release Script (Two Remote Strategy with Tagging)
# =============================================================================
# This script creates release branches with only selected files/directories
# and automatically manages version numbering using Git tags.
#
# Two Remote Repositories:
#   origin  - Private development repo (main branch for development)
#   public  - Public release repo (release branch for external releases)
#
# Version Format: X.Y.Z
#   X  = Major release (breaking changes)
#   Y  = Minor release (new features, backward compatible)
#   Z  = Bugfix release (bug fixes only)
#
# Workflow:
#   1. Tag a version in main branch (tag may or may not be latest commit)
#   2. Create release branch from the tag
#   3. Update release notes with provided changes description
#
# Usage:
#   ./create-public-release.sh <type> "<message>" "<revision_description>" ["<software_version>"]
#
# Examples:
#   ./create-public-release.sh major "Complete redesign of controller FSM" "Major redesign for improved performance" "2025.2"
#   ./create-public-release.sh minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices" "2025.2"
#   ./create-public-release.sh bugfix "Fixed timing issue in read path" "Fixed read timing violation" "2025.1.1"
#
# =============================================================================

set -e  # Exit on error

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
METADATA_FILE="metadata.xml"

# Directories/files to include in public release
PUBLIC_DIRS=(
    "rtl/"
    "doc/"
    "plugin/"
    "testbench/"
    "sim/"
    "example_design/"
)

PUBLIC_FILES=(
    "README.md"
    "QUICKSTART.md"
    "IP Release Notes.md"
    "metadata.xml"
    "bus_interface.xml"
    "memory_map.xml"
    "license.txt"
)

# Patterns to exclude (even if inside public directories)
EXCLUDE_PATTERNS=(
    "*.bak"
    "*~"
    "INTERNAL_*"
    "TODO*"
    ".DS_Store"
    # Note: Simulation artifacts (*.wlf, *.log, transcript, work/) are already
    # excluded by .gitignore and won't be in the repository
    # Note: Prebuilt libraries (sim/pmi/, sim/lfmxo5/, sim/uaplatform/) and
    # bht_ini.bin are kept in git and will be included in releases
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
# Update IP Release Notes.md (includes revision history)
# -----------------------------------------------------------------------------
update_release_notes() {
    local version=$1
    local software_version=$2
    local description=$3
    local release_notes_file="IP Release Notes.md"

    if [ ! -f "$release_notes_file" ]; then
        warning "IP Release Notes.md not found, skipping release notes update"
        return 0
    fi

    info "Updating release notes in $release_notes_file..."

    # Convert description to bullet points
    # Handle multiple formats: semicolon-separated, newline-separated, or single line
    # Split by semicolons or newlines, then format as bullet points
    # Use <br> tags for line breaks in markdown table cells
    local formatted_changes=$(echo "$description" | \
        sed 's/; */\n/g' | \
        sed 's/^[[:space:]]*//' | \
        sed 's/[[:space:]]*$//' | \
        grep -v '^$' | \
        sed 's/^/• /' | \
        tr '\n' '\001' | \
        sed 's/\001/<br>/g' | \
        sed 's/  */ /g')

    # Create new version section with table
    # Note: The IP name placeholder [IP Name] will need to be replaced manually
    # or can be extracted from metadata.xml if needed
    local new_section="## [IP Name] IP v${version}

| Software | Software Version | Summary of Changes |
|----------|------------------|-------------------|
| Lattice Radiant | ${software_version} | ${formatted_changes} |

---"

    # Insert the new section after the Introduction section
    # If there's a placeholder table (with [Version] or [IP Name] placeholders), replace it
    # Otherwise, insert before the first existing version section
    # Use a temporary file to pass new_section to awk to avoid issues with newlines and special characters
    local new_section_file=$(mktemp)
    printf '%s' "$new_section" > "$new_section_file"

    awk -v new_section_file="$new_section_file" '
        BEGIN {
            found_separator=0
            inserted=0
            in_placeholder=0
            placeholder_start=0
            # Read new_section from file
            while ((getline line < new_section_file) > 0) {
                new_section = (new_section == "" ? line : new_section "\n" line)
            }
            close(new_section_file)
        }
        /^---$/ && !found_separator {
            # Found the first separator after introduction
            print
            found_separator=1
            next
        }
        found_separator && !inserted && /^## \[IP Name\] IP v\[Version\]/ {
            # Found placeholder version section - mark it for replacement
            in_placeholder=1
            next
        }
        in_placeholder {
            # Skip lines until we find the next separator (end of placeholder section)
            if (/^---$/) {
                # End of placeholder section, replace with new section
                printf "%s", new_section
                inserted=1
                in_placeholder=0
            }
            # Skip all lines within placeholder section (do not print them)
            next
        }
        found_separator && !inserted && /^## \[IP Name\] IP v/ {
            # Found the first existing version section (non-placeholder), insert new one before it
            printf "%s", new_section
            inserted=1
        }
        { print }
        END {
            # If we found the separator but did not insert (no existing versions or placeholder), insert now
            if (found_separator && !inserted) {
                printf "%s", new_section
            }
        }
    ' "$release_notes_file" > "${release_notes_file}.tmp"

    rm -f "$new_section_file"
    mv "${release_notes_file}.tmp" "$release_notes_file"
    success "Release notes updated with version $version"
}

# -----------------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------------
usage() {
    cat << EOF
Usage: $0 <type> "<message>" "<revision_description>" ["<software_version>"]

Release Types:
    major     - Increment X (X.Y.Z) - Breaking changes
    minor     - Increment Y (X.Y.Z) - New features (backward compatible)
    bugfix    - Increment Z (X.Y.Z) - Bug fixes only

Arguments:
    type                 - Release type (major|minor|bugfix)
    message              - Release message describing changes (quoted string)
    revision_description - Revision history description (REQUIRED)
    software_version     - Lattice Radiant software version (REQUIRED, e.g., "2025.2")

Examples:
    $0 major "Complete redesign of controller FSM" "Major redesign for improved performance" "2025.2"
    $0 minor "Added dual-rank support" "Added support for dual-rank HyperRAM devices" "2025.2"
    $0 bugfix "Fixed timing issue in read path" "Fixed read timing violation" "2025.1.1"

Version Format: X.Y.Z
    X  = Major version
    Y  = Minor version
    Z  = Bugfix version

Tags: vX.Y.Z

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

RELEASE_TYPE=$1
RELEASE_MESSAGE=$2
REVISION_DESCRIPTION=$3
SOFTWARE_VERSION=$4

# Validate release type
case "$RELEASE_TYPE" in
    major|minor|bugfix)
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

# Require revision description and software version for all releases
if [ -z "$REVISION_DESCRIPTION" ]; then
    error "Revision description is REQUIRED"
    error "This will be added to the IP Release Notes.md"
    usage
fi

if [ -z "$SOFTWARE_VERSION" ]; then
    error "Software version is REQUIRED"
    error "Example: 2025.2, 2025.1.1, etc."
    usage
fi

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------
info "Running pre-flight checks..."

# Check we're in the right directory (should be in the repository root)
if [ ! -f "$METADATA_FILE" ] || [ ! -d ".git" ]; then
    error "Must run from repository root (where metadata.xml and .git directory exist)"
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

# Check CI status (must pass before publishing)
if [ "$CURRENT_BRANCH" = "main" ]; then
    info "Checking CI status for release..."

    # Get latest commit SHA
    LATEST_SHA=$(git rev-parse HEAD)

    # Check if CI has run and passed (requires gh CLI or curl to GitHub API)
    if command -v gh &> /dev/null; then
        # Using GitHub CLI
        CI_STATUS=$(gh api repos/{owner}/{repo}/commits/$LATEST_SHA/status --jq '.state' 2>/dev/null || echo "unknown")

        if [ "$CI_STATUS" = "success" ]; then
            success "CI status: PASSED ✅"
        elif [ "$CI_STATUS" = "pending" ]; then
            error "CI is still running. Wait for CI to complete before publishing."
            error "Check status: gh run list --branch main"
            exit 1
        elif [ "$CI_STATUS" = "failure" ] || [ "$CI_STATUS" = "error" ]; then
            error "CI FAILED ❌"
            error "Release is BLOCKED until CI passes on main branch"
            error "Fix CI failures and try again"
            error "Check failures: gh run list --branch main"
            exit 1
        else
            warning "Unable to determine CI status (gh CLI may need configuration)"
            warning "Proceeding with caution..."
            read -p "CI status unknown. Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        warning "GitHub CLI (gh) not installed - cannot verify CI status"
        warning "Install gh CLI: https://cli.github.com/"
        warning "CI must pass on main before publishing"
        read -p "Continue without CI check? (not recommended) (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

success "Pre-flight checks passed"

# -----------------------------------------------------------------------------
# Read current version from release branch (if exists) or use 1.0.0 for first release
# -----------------------------------------------------------------------------
RELEASE_BRANCH="release"

# Check if release branch exists (local or remote)
RELEASE_BRANCH_EXISTS=false
if git show-ref --verify --quiet refs/heads/release 2>/dev/null; then
    RELEASE_BRANCH_EXISTS=true
    info "Found local release branch"
elif git show-ref --verify --quiet refs/remotes/origin/release 2>/dev/null; then
    RELEASE_BRANCH_EXISTS=true
    info "Found remote release branch (origin/release)"
elif git show-ref --verify --quiet refs/remotes/public/release 2>/dev/null; then
    RELEASE_BRANCH_EXISTS=true
    info "Found remote release branch (public/release)"
fi

if [ "$RELEASE_BRANCH_EXISTS" = true ]; then
    # Release branch exists - read version from it
    info "Reading version from release branch..."

    # Try to read from local branch first, then remote
    if git show "release:$METADATA_FILE" >/dev/null 2>&1; then
        CURRENT_VERSION=$(git show "release:$METADATA_FILE" | \
            grep '<lsccip:version>' | \
            sed 's/.*<lsccip:version>\(.*\)<\/lsccip:version>.*/\1/' | \
            tr -d '[:space:]')
    elif git show "origin/release:$METADATA_FILE" >/dev/null 2>&1; then
        CURRENT_VERSION=$(git show "origin/release:$METADATA_FILE" | \
            grep '<lsccip:version>' | \
            sed 's/.*<lsccip:version>\(.*\)<\/lsccip:version>.*/\1/' | \
            tr -d '[:space:]')
    elif git show "public/release:$METADATA_FILE" >/dev/null 2>&1; then
        CURRENT_VERSION=$(git show "public/release:$METADATA_FILE" | \
            grep '<lsccip:version>' | \
            sed 's/.*<lsccip:version>\(.*\)<\/lsccip:version>.*/\1/' | \
            tr -d '[:space:]')
    else
        warning "Could not read metadata.xml from release branch"
        warning "Assuming first release (1.0.0)"
        CURRENT_VERSION="1.0.0"
    fi

    if [ -z "$CURRENT_VERSION" ]; then
        warning "Could not extract version from release branch"
        warning "Assuming first release (1.0.0)"
        CURRENT_VERSION="1.0.0"
    fi
else
    # No release branch exists - this is the first release
    info "No existing release branch found - this is the first release"
    CURRENT_VERSION="1.0.0"
fi

info "Current release version: $CURRENT_VERSION"

# Parse version components - X.Y.Z format only
if [[ $CURRENT_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    # Format: X.Y.Z
    MAJOR=${BASH_REMATCH[1]}
    MINOR=${BASH_REMATCH[2]}
    BUGFIX=${BASH_REMATCH[3]}
else
    error "Invalid version format: $CURRENT_VERSION"
    error "Expected format: X.Y.Z (e.g., 1.2.3)"
    exit 1
fi

# -----------------------------------------------------------------------------
# Calculate new version
# -----------------------------------------------------------------------------
# For first release (1.0.0), use it as-is
if [ "$CURRENT_VERSION" = "1.0.0" ] && [ "$RELEASE_BRANCH_EXISTS" = false ]; then
    info "First release - using version 1.0.0"
    MAJOR=1
    MINOR=0
    BUGFIX=0
    NEW_VERSION="1.0.0"
else
    # Subsequent releases - bump based on release type
    case "$RELEASE_TYPE" in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            BUGFIX=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            BUGFIX=0
            ;;
        bugfix)
            BUGFIX=$((BUGFIX + 1))
            ;;
    esac
    NEW_VERSION="${MAJOR}.${MINOR}.${BUGFIX}"
fi
TARGET_REMOTE="public"
RELEASE_TAG="v${NEW_VERSION}"

info "New version: $NEW_VERSION"
info "Release tag: $RELEASE_TAG"
info "Target remote: $TARGET_REMOTE"

# -----------------------------------------------------------------------------
# Tag selection/creation
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
echo "Tag Selection"
echo "========================================="
echo "Release Tag:    $RELEASE_TAG"
echo ""

# Check if tag already exists
if git rev-parse "$RELEASE_TAG" >/dev/null 2>&1; then
    warning "Tag $RELEASE_TAG already exists!"
    echo ""
    echo "Options:"
    echo "  1. Use existing tag: $RELEASE_TAG"
    echo "  2. Cancel and use a different version"
    echo ""
    read -p "Use existing tag? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Release cancelled. Tag $RELEASE_TAG already exists."
        exit 1
    fi
    SOURCE_TAG="$RELEASE_TAG"
    info "Using existing tag: $SOURCE_TAG"
else
    # Tag doesn't exist - ask user to select commit to tag
    echo "Tag $RELEASE_TAG does not exist. Select commit to tag:"
    echo ""
    echo "Recent commits on main:"
    git log --oneline -10 main | nl -v 1 -w 2 -s '. '
    echo ""
    echo "Options:"
    echo "  [1-10]  - Tag the commit shown above"
    echo "  HEAD    - Tag current commit (HEAD)"
    echo "  <sha>   - Tag specific commit SHA"
    echo "  <tag>   - Use existing tag"
    echo ""
    read -p "Select commit to tag (or existing tag): " TAG_SELECTION

    if [ -z "$TAG_SELECTION" ]; then
        error "No selection provided"
        exit 1
    fi

    # Determine the commit to tag
    if [[ "$TAG_SELECTION" =~ ^[0-9]+$ ]] && [ "$TAG_SELECTION" -ge 1 ] && [ "$TAG_SELECTION" -le 10 ]; then
        # User selected a number from the list
        COMMIT_SHA=$(git log --oneline -10 main | sed -n "${TAG_SELECTION}p" | awk '{print $1}')
        info "Selected commit: $COMMIT_SHA"
    elif [ "$TAG_SELECTION" = "HEAD" ]; then
        COMMIT_SHA=$(git rev-parse HEAD)
        info "Selected current commit (HEAD): $COMMIT_SHA"
    elif git rev-parse "$TAG_SELECTION" >/dev/null 2>&1; then
        # Check if it's an existing tag
        if git rev-parse "$TAG_SELECTION^{tag}" >/dev/null 2>&1; then
            SOURCE_TAG="$TAG_SELECTION"
            info "Using existing tag: $SOURCE_TAG"
        else
            # It's a commit SHA
            COMMIT_SHA="$TAG_SELECTION"
            info "Selected commit: $COMMIT_SHA"
        fi
    else
        error "Invalid selection: $TAG_SELECTION"
        exit 1
    fi

    # Create tag if needed
    if [ -z "$SOURCE_TAG" ]; then
        # Verify commit exists
        if ! git cat-file -e "$COMMIT_SHA" 2>/dev/null; then
            error "Commit $COMMIT_SHA does not exist"
            exit 1
        fi

        # Show commit info
        echo ""
        info "Commit to tag:"
        git log -1 --oneline "$COMMIT_SHA"
        echo ""

        read -p "Create tag $RELEASE_TAG at this commit? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Release cancelled"
            exit 1
        fi

        # Create tag
        info "Creating tag $RELEASE_TAG at commit $COMMIT_SHA..."
        git tag -a "$RELEASE_TAG" -m "$RELEASE_MESSAGE" "$COMMIT_SHA"
        success "Tag $RELEASE_TAG created"
        SOURCE_TAG="$RELEASE_TAG"
    fi
fi

# -----------------------------------------------------------------------------
# Confirmation
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
echo "Release Summary"
echo "========================================="
echo "Type:           $RELEASE_TYPE"
echo "Current Release: $CURRENT_VERSION"
echo "New Version:    $NEW_VERSION"
echo "Release Tag:    $RELEASE_TAG"
echo "Source Tag:     $SOURCE_TAG"
echo "Target Remote:  $TARGET_REMOTE"
echo "Release Branch: $RELEASE_BRANCH"
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
# Create or update release branch from tag
# -----------------------------------------------------------------------------
RELEASE_NOTES_TEMP=""  # Initialize variable for IP Release Notes.md handling
if [ "$RELEASE_BRANCH_EXISTS" = true ]; then
    # Release branch exists - checkout and update it
    info "Updating existing release branch: $RELEASE_BRANCH from tag $SOURCE_TAG"

    # Try to checkout local branch first
    if git show-ref --verify --quiet refs/heads/release 2>/dev/null; then
        git checkout release
        RELEASE_BRANCH_REF="release"
    elif git show-ref --verify --quiet refs/remotes/origin/release 2>/dev/null; then
        git checkout -b release origin/release
        RELEASE_BRANCH_REF="origin/release"
    elif git show-ref --verify --quiet refs/remotes/public/release 2>/dev/null; then
        git checkout -b release public/release
        RELEASE_BRANCH_REF="public/release"
    else
        error "Release branch exists but cannot be checked out"
        exit 1
    fi

    # Save IP Release Notes.md from release branch before removing files
    if git show "${RELEASE_BRANCH_REF}:IP Release Notes.md" >/dev/null 2>&1; then
        RELEASE_NOTES_TEMP=$(mktemp)
        git show "${RELEASE_BRANCH_REF}:IP Release Notes.md" > "$RELEASE_NOTES_TEMP" 2>/dev/null
        info "  Saved IP Release Notes.md from release branch"
    fi

    # Remove all files to start fresh from tag
    git rm -rf . > /dev/null 2>&1 || true
else
    # No release branch exists - create new orphan branch
    info "Creating new release branch: $RELEASE_BRANCH from tag $SOURCE_TAG"
    git checkout --orphan "$RELEASE_BRANCH"

    # Remove everything
    git rm -rf . > /dev/null 2>&1 || true
fi

# -----------------------------------------------------------------------------
# Copy public files/directories from tagged commit
# -----------------------------------------------------------------------------
info "Copying public files from tag $SOURCE_TAG..."

# Copy directories
for dir in "${PUBLIC_DIRS[@]}"; do
    if git cat-file -e "$SOURCE_TAG:$dir" 2>/dev/null; then
        info "  Copying directory: $dir"
        git checkout "$SOURCE_TAG" -- "$dir" 2>/dev/null || warning "Failed to copy $dir"
    else
        warning "  Directory not found in tag: $dir (skipping)"
    fi
done

# Copy individual files (may not exist yet)
for file in "${PUBLIC_FILES[@]}"; do
    # Special handling for IP Release Notes.md: use saved copy from release branch if it exists
    if [ "$file" = "IP Release Notes.md" ] && [ -n "$RELEASE_NOTES_TEMP" ] && [ -f "$RELEASE_NOTES_TEMP" ]; then
        # Restore IP Release Notes.md from release branch to preserve previous release history
        info "  Restoring file from release branch: $file"
        cp "$RELEASE_NOTES_TEMP" "$file"
        rm -f "$RELEASE_NOTES_TEMP"
    else
        # For all other files (or IP Release Notes.md if no release branch), copy from tag
        if git cat-file -e "$SOURCE_TAG:$file" 2>/dev/null; then
            info "  Copying file: $file"
            git checkout "$SOURCE_TAG" -- "$file" 2>/dev/null || true
        else
            warning "  File not found in tag: $file (will be included when created)"
        fi
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
# Update metadata.xml version in release branch
# -----------------------------------------------------------------------------
info "Updating metadata.xml version in release branch to $NEW_VERSION..."
if [ -f "$METADATA_FILE" ]; then
    sed -i.bak "s|<lsccip:version>.*</lsccip:version>|<lsccip:version>${NEW_VERSION}</lsccip:version>|g" "$METADATA_FILE"
    rm -f "${METADATA_FILE}.bak"
    success "metadata.xml version updated to $NEW_VERSION"
else
    warning "metadata.xml not found in release branch"
fi

# -----------------------------------------------------------------------------
# Update IP Release Notes.md
# -----------------------------------------------------------------------------
if [ -n "$REVISION_DESCRIPTION" ] && [ -n "$SOFTWARE_VERSION" ]; then
    update_release_notes "${MAJOR}.${MINOR}.${BUGFIX}" "$SOFTWARE_VERSION" "$REVISION_DESCRIPTION"
fi

# -----------------------------------------------------------------------------
# Create license.txt file if not present
# -----------------------------------------------------------------------------
if [ ! -f "license.txt" ]; then
    info "Creating license.txt file..."
    cat > license.txt << 'EOF'
Copyright (c) 2024 Lattice Semiconductor Corporation

This HyperRAM Memory Controller IP is provided under the Lattice Reference
Design License Agreement.

For license terms, please refer to the Lattice Semiconductor website or
contact Lattice Semiconductor directly.
EOF
    git add license.txt
    success "license.txt file created"
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
    # Only delete release branch if it was just created (orphan)
    if [ "$RELEASE_BRANCH_EXISTS" = false ]; then
        git branch -D "$RELEASE_BRANCH" 2>/dev/null || true
    fi
    # Revert metadata.xml version update
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

# Note: Tag $RELEASE_TAG was already created in main branch earlier

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

echo "RELEASE (major/minor/bugfix)"
echo "----------------------------"
echo ""
echo "1. Review the release branch:"
echo "   git log --oneline --graph $RELEASE_BRANCH"
echo ""
echo "2. Review files in release:"
echo "   git ls-tree -r --name-only $RELEASE_BRANCH"
echo ""
echo "3. Push to PUBLIC remote (release branch):"
echo "   git push public $RELEASE_BRANCH --force"
echo "   git push public $RELEASE_TAG"
echo ""
echo "4. Push to ORIGIN (development) remote:"
echo "   git checkout main"
echo "   git push origin main"
echo "   git push origin $RELEASE_TAG"

echo ""
echo "To return to main branch:"
echo "   git checkout main"
echo ""
echo "========================================="

exit 0

