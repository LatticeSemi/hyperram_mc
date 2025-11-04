#!/bin/bash
# Install Git hooks for the HyperRAM project
#
# Usage: ./hooks/install-hooks.sh

echo "Installing Git hooks..."

# Copy pre-commit hook
cp hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo "✓ Pre-commit hook installed"

# Copy pre-push hook
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
echo "✓ Pre-push hook installed"

echo ""
echo "================================================"
echo "Git hooks installed successfully!"
echo "================================================"
echo ""
echo "🛡️  Protection enabled:"
echo "  - Blocks direct commits to main branch"
echo "  - Blocks direct pushes to main branch"
echo "  - Code quality checks on every commit"
echo ""
echo "📋 Proper workflow:"
echo "  1. git checkout -b feature/your-feature"
echo "  2. Make changes and commit to feature branch"
echo "  3. git push origin feature/your-feature"
echo "  4. Create Pull Request on GitHub"
echo ""
echo "ℹ️  To bypass hooks (NOT RECOMMENDED):"
echo "  git commit --no-verify"
echo "  git push --no-verify"
echo ""

