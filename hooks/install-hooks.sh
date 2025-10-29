#!/bin/bash
# Install Git hooks for the HyperRAM project
#
# Usage: ./hooks/install-hooks.sh

echo "Installing Git hooks..."

# Copy pre-commit hook
cp hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✓ Pre-commit hook installed"
echo ""
echo "The hook will now run automatically before each commit."
echo "To skip the hook, use: git commit --no-verify"

