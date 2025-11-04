#!/bin/bash
# =============================================================================
# Generate Release Notes from Git Commits
# =============================================================================
# This script generates release notes between two versions
#
# Usage:
#   ./generate-release-notes.sh <from-version> <to-version>
#
# Example:
#   ./generate-release-notes.sh v1.0.0 v1.1.0
# =============================================================================

set -e

FROM_VERSION=$1
TO_VERSION=$2

if [ -z "$FROM_VERSION" ] || [ -z "$TO_VERSION" ]; then
    echo "Usage: $0 <from-version> <to-version>"
    echo "Example: $0 v1.0.0 v1.1.0"
    exit 1
fi

echo "# Release Notes: $TO_VERSION"
echo ""
echo "Changes since $FROM_VERSION:"
echo ""

# Get commits between versions
echo "## Features"
git log $FROM_VERSION..$TO_VERSION --pretty=format:"- %s" --grep="feat:" --grep="feature:" -i
echo ""
echo ""

echo "## Bug Fixes"
git log $FROM_VERSION..$TO_VERSION --pretty=format:"- %s" --grep="fix:" --grep="bugfix:" -i
echo ""
echo ""

echo "## Other Changes"
git log $FROM_VERSION..$TO_VERSION --pretty=format:"- %s" --invert-grep --grep="feat:" --grep="fix:" --grep="Merge" -i
echo ""
echo ""

echo "## Contributors"
git log $FROM_VERSION..$TO_VERSION --pretty=format:"%an" | sort -u
echo ""


