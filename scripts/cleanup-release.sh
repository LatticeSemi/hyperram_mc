#!/bin/bash
# =============================================================================
# Release Branch Cleanup Script
# =============================================================================
# This script cleans up incorrect release branch commits and tags.
#
# Scenarios:
#   1. First Release (orphan branch):
#      - Delete the release branch (local and remote)
#      - Delete the tag from main corresponding to this release
#      - Return to main branch
#
#   2. Subsequent Release (release branch with history):
#      - Delete the latest release commit (the incorrect one)
#      - Rollback to the previous known good commit
#      - Delete the latest tag from main corresponding to the removed release commit
#      - Return to main branch
#
# Usage:
#   ./cleanup-release.sh
#
# Note: This script must be run from the main branch (where the script exists).
#       The script will automatically switch to main if run from another branch.
#       The cleanup script is NOT included in release branches, so it must be
#       executed from the main branch's working directory.
#
# =============================================================================

set -e  # Exit on error

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
RELEASE_BRANCH="release"
METADATA_FILE="metadata.xml"

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
# Check if we're in a git repository
# -----------------------------------------------------------------------------
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository"
    exit 1
fi

# -----------------------------------------------------------------------------
# Ensure we're on main branch
# -----------------------------------------------------------------------------
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    info "Switching to main branch..."
    git checkout main
    if [ $? -ne 0 ]; then
        error "Failed to checkout main branch"
        exit 1
    fi
    success "Switched to main branch"
fi

# -----------------------------------------------------------------------------
# Check if release branch exists (local or remote)
# -----------------------------------------------------------------------------
RELEASE_BRANCH_EXISTS=false
RELEASE_BRANCH_LOCAL=false
RELEASE_BRANCH_REMOTE=""

if git show-ref --verify --quiet refs/heads/release 2>/dev/null; then
    RELEASE_BRANCH_EXISTS=true
    RELEASE_BRANCH_LOCAL=true
    info "Found local release branch"
elif git show-ref --verify --quiet refs/remotes/origin/release 2>/dev/null; then
    RELEASE_BRANCH_EXISTS=true
    RELEASE_BRANCH_REMOTE="origin/release"
    info "Found remote release branch (origin/release)"
elif git show-ref --verify --quiet refs/remotes/public/release 2>/dev/null; then
    RELEASE_BRANCH_EXISTS=true
    RELEASE_BRANCH_REMOTE="public/release"
    info "Found remote release branch (public/release)"
fi

if [ "$RELEASE_BRANCH_EXISTS" = false ]; then
    warning "No release branch found. Nothing to clean up."
    exit 0
fi

# -----------------------------------------------------------------------------
# Determine if this is the first release (orphan branch) or subsequent release
# -----------------------------------------------------------------------------
IS_FIRST_RELEASE=false

if [ "$RELEASE_BRANCH_LOCAL" = true ]; then
    # Check if local branch is orphan (no parent commits)
    PARENT_COUNT=$(git rev-list --count --parents release ^main 2>/dev/null || echo "0")
    if [ "$PARENT_COUNT" = "0" ] || [ -z "$PARENT_COUNT" ]; then
        # Check if it's truly orphan by checking if it has any commits
        COMMIT_COUNT=$(git rev-list --count release 2>/dev/null || echo "0")
        if [ "$COMMIT_COUNT" = "1" ]; then
            # Single commit with no parent - likely orphan branch
            IS_FIRST_RELEASE=true
        fi
    else
        # Try another method: check if release branch has merge-base with main
        MERGE_BASE=$(git merge-base release main 2>/dev/null || echo "")
        if [ -z "$MERGE_BASE" ]; then
            IS_FIRST_RELEASE=true
        fi
    fi
else
    # Check remote branch
    if [ -n "$RELEASE_BRANCH_REMOTE" ]; then
        # Fetch the remote branch info
        git fetch --quiet origin release 2>/dev/null || git fetch --quiet public release 2>/dev/null || true

        # Check if remote branch has merge-base with main
        MERGE_BASE=$(git merge-base "$RELEASE_BRANCH_REMOTE" main 2>/dev/null || echo "")
        if [ -z "$MERGE_BASE" ]; then
            IS_FIRST_RELEASE=true
        fi
    fi
fi

# -----------------------------------------------------------------------------
# Get the latest tag from main branch (corresponding to the release to remove)
# -----------------------------------------------------------------------------
LATEST_TAG=""
TAG_LIST=$(git tag --sort=-version:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' || true)

if [ -n "$TAG_LIST" ]; then
    LATEST_TAG=$(echo "$TAG_LIST" | head -n 1)
    info "Latest version tag found: $LATEST_TAG"
else
    warning "No version tags found (format: vX.Y.Z)"
fi

# -----------------------------------------------------------------------------
# Display information and confirm
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
echo "Release Cleanup Information"
echo "========================================="
echo ""
if [ "$IS_FIRST_RELEASE" = true ]; then
    echo "Release Type:  First Release (orphan branch)"
    echo "Action:        Delete release branch and tag"
else
    echo "Release Type:  Subsequent Release (with history)"
    echo "Action:        Rollback to previous commit and delete latest tag"
fi
echo ""
if [ "$RELEASE_BRANCH_LOCAL" = true ]; then
    echo "Release Branch: local (release)"
else
    echo "Release Branch: remote ($RELEASE_BRANCH_REMOTE)"
fi
if [ -n "$LATEST_TAG" ]; then
    echo "Tag to Remove:  $LATEST_TAG"
fi
echo ""
echo "========================================="
echo ""

read -p "Proceed with cleanup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Cleanup cancelled"
    exit 0
fi

# -----------------------------------------------------------------------------
# Perform cleanup based on release type
# -----------------------------------------------------------------------------
if [ "$IS_FIRST_RELEASE" = true ]; then
    # =====================================================================
    # First Release Cleanup
    # =====================================================================
    info "Cleaning up first release..."

    # Delete local release branch if it exists
    if [ "$RELEASE_BRANCH_LOCAL" = true ]; then
        info "Deleting local release branch..."
        git branch -D "$RELEASE_BRANCH" 2>/dev/null || warning "Local release branch already deleted or doesn't exist"
        success "Local release branch deleted"
    fi

    # Delete remote release branch if it exists
    if [ -n "$RELEASE_BRANCH_REMOTE" ]; then
        REMOTE_NAME=$(echo "$RELEASE_BRANCH_REMOTE" | cut -d'/' -f1)
        info "Deleting remote release branch from $REMOTE_NAME..."
        git push "$REMOTE_NAME" --delete "$RELEASE_BRANCH" 2>/dev/null || warning "Remote release branch already deleted or doesn't exist"
        success "Remote release branch deleted from $REMOTE_NAME"
    fi

    # Delete tag from main (local and remote)
    if [ -n "$LATEST_TAG" ]; then
        info "Deleting tag $LATEST_TAG from local repository..."
        git tag -d "$LATEST_TAG" 2>/dev/null || warning "Tag $LATEST_TAG not found locally"
        success "Local tag deleted"

        # Try to delete from origin
        info "Deleting tag $LATEST_TAG from origin..."
        git push origin --delete "$LATEST_TAG" 2>/dev/null || warning "Tag $LATEST_TAG not found on origin"

        # Try to delete from public
        info "Deleting tag $LATEST_TAG from public..."
        git push public --delete "$LATEST_TAG" 2>/dev/null || warning "Tag $LATEST_TAG not found on public"

        success "Tag deletion attempted on all remotes"
    fi

    success "First release cleanup completed"

else
    # =====================================================================
    # Subsequent Release Cleanup
    # =====================================================================
    info "Cleaning up subsequent release..."

    # Checkout release branch to work with it
    if [ "$RELEASE_BRANCH_LOCAL" = true ]; then
        info "Checking out local release branch..."
        git checkout "$RELEASE_BRANCH"
    else
        info "Checking out remote release branch..."
        git checkout -b "$RELEASE_BRANCH" "$RELEASE_BRANCH_REMOTE"
        RELEASE_BRANCH_LOCAL=true
    fi

    # Get commit history
    COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")

    if [ "$COMMIT_COUNT" -le "1" ]; then
        warning "Release branch has only one commit. Treating as first release..."
        git checkout main

        # Delete local release branch
        git branch -D "$RELEASE_BRANCH" 2>/dev/null || true

        # Delete remote release branch
        if [ -n "$RELEASE_BRANCH_REMOTE" ]; then
            REMOTE_NAME=$(echo "$RELEASE_BRANCH_REMOTE" | cut -d'/' -f1)
            git push "$REMOTE_NAME" --delete "$RELEASE_BRANCH" 2>/dev/null || true
        fi

        # Delete tag
        if [ -n "$LATEST_TAG" ]; then
            git tag -d "$LATEST_TAG" 2>/dev/null || true
            git push origin --delete "$LATEST_TAG" 2>/dev/null || true
            git push public --delete "$LATEST_TAG" 2>/dev/null || true
        fi

        success "Cleanup completed (treated as first release)"
        exit 0
    fi

    # Get the latest commit (the one to remove)
    LATEST_COMMIT=$(git rev-parse HEAD)
    LATEST_COMMIT_MSG=$(git log -1 --pretty=format:"%s" HEAD)

    info "Latest commit to remove: $LATEST_COMMIT"
    info "Commit message: $LATEST_COMMIT_MSG"

    # Get the previous commit (the one to rollback to)
    PREVIOUS_COMMIT=$(git rev-parse HEAD~1)
    PREVIOUS_COMMIT_MSG=$(git log -1 --pretty=format:"%s" HEAD~1)

    info "Rolling back to: $PREVIOUS_COMMIT"
    info "Previous commit message: $PREVIOUS_COMMIT_MSG"

    # Reset to previous commit (hard reset to remove latest commit)
    info "Resetting release branch to previous commit..."
    git reset --hard HEAD~1
    success "Release branch rolled back to previous commit"

    # Force push to update remote release branch
    if [ -n "$RELEASE_BRANCH_REMOTE" ]; then
        REMOTE_NAME=$(echo "$RELEASE_BRANCH_REMOTE" | cut -d'/' -f1)
        info "Force pushing updated release branch to $REMOTE_NAME..."
        git push "$REMOTE_NAME" "$RELEASE_BRANCH" --force
        success "Remote release branch updated"
    fi

    # Delete tag from main (local and remote)
    if [ -n "$LATEST_TAG" ]; then
        info "Deleting tag $LATEST_TAG from local repository..."
        git tag -d "$LATEST_TAG" 2>/dev/null || warning "Tag $LATEST_TAG not found locally"
        success "Local tag deleted"

        # Try to delete from origin
        info "Deleting tag $LATEST_TAG from origin..."
        git push origin --delete "$LATEST_TAG" 2>/dev/null || warning "Tag $LATEST_TAG not found on origin"

        # Try to delete from public
        info "Deleting tag $LATEST_TAG from public..."
        git push public --delete "$LATEST_TAG" 2>/dev/null || warning "Tag $LATEST_TAG not found on public"

        success "Tag deletion attempted on all remotes"
    fi

    success "Subsequent release cleanup completed"
fi

# -----------------------------------------------------------------------------
# Return to main branch
# -----------------------------------------------------------------------------
info "Returning to main branch..."
git checkout main
success "Back on main branch"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
success "Cleanup completed successfully!"
echo "========================================="
echo ""
if [ "$IS_FIRST_RELEASE" = true ]; then
    echo "Actions performed:"
    echo "  ✓ Deleted release branch (local and remote)"
    echo "  ✓ Deleted tag $LATEST_TAG (if found)"
else
    echo "Actions performed:"
    echo "  ✓ Rolled back release branch to previous commit"
    echo "  ✓ Updated remote release branch"
    echo "  ✓ Deleted tag $LATEST_TAG (if found)"
fi
echo "  ✓ Returned to main branch"
echo ""
echo "You can now redo the release with the corrected script."
echo ""

