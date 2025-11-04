#!/bin/bash
# =============================================================================
# Show Version Status Across All Remotes
# =============================================================================
# Displays current version status for developers, internal, and public releases
# =============================================================================

set -e

echo "=========================================="
echo "HyperRAM IP - Version Status Dashboard"
echo "=========================================="
echo ""

# Current local version
if [ -f "VERSION" ]; then
    CURRENT_VERSION=$(cat VERSION | tr -d '[:space:]')
    echo "📍 Current Development Version: $CURRENT_VERSION"
else
    echo "⚠️  VERSION file not found"
fi
echo ""

# Check remotes
echo "🔗 Configured Remotes:"
git remote -v | grep fetch
echo ""

# Latest tags on each remote
echo "📦 Latest Releases:"
echo ""

# Origin (development)
echo "  ORIGIN (Development):"
if git ls-remote origin &>/dev/null; then
    ORIGIN_LATEST=$(git ls-remote --tags origin | grep -v '\^{}' | tail -1 | sed 's/.*refs\/tags\///' || echo "No tags")
    echo "    Latest tag: $ORIGIN_LATEST"
else
    echo "    ⚠️  Remote not accessible"
fi
echo ""

# Staging (internal)
echo "  STAGING (Internal):"
if git ls-remote staging &>/dev/null; then
    STAGING_LATEST=$(git ls-remote --tags staging | grep -v '\^{}' | tail -1 | sed 's/.*refs\/tags\///' || echo "No tags")
    echo "    Latest tag: $STAGING_LATEST"
    STAGING_BRANCHES=$(git ls-remote --heads staging | grep staging/ | wc -l || echo "0")
    echo "    Active staging branches: $STAGING_BRANCHES"
else
    echo "    ⚠️  Remote not configured or not accessible"
fi
echo ""

# Public (external customers)
echo "  PUBLIC (External):"
if git ls-remote public &>/dev/null; then
    PUBLIC_LATEST=$(git ls-remote --tags public | grep -v '\^{}' | tail -1 | sed 's/.*refs\/tags\///' || echo "No tags")
    echo "    Latest tag: $PUBLIC_LATEST"
    PUBLIC_BRANCHES=$(git ls-remote --heads public | grep release/ | wc -l || echo "0")
    echo "    Active release branches: $PUBLIC_BRANCHES"
else
    echo "    ⚠️  Remote not configured or not accessible"
fi
echo ""

# Recent local tags
echo "📌 Recent Local Tags:"
git tag -l --sort=-version:refname | head -5
echo ""

echo "=========================================="
echo "For detailed history: git log --oneline --graph"
echo "=========================================="


