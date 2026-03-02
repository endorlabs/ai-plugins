#!/bin/bash
# Build script to generate the endor-setup.skill file

set -e

echo "🔨 Building endor-setup skill..."
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 is required"
    exit 1
fi

# Create dist directory
mkdir -p dist

# Skill folder (updated path)
SKILL_DIR="skills/endor-setup"
SKILL_BASENAME=$(basename "$SKILL_DIR")

# Validate
echo "🔍 Validating skill..."
python3 scripts/quick_validate.py "$SKILL_DIR" || {
    echo "❌ Validation failed"
    exit 1
}

echo "✅ Validation passed!"
echo ""

# Package
echo "📦 Packaging skill..."
python3 scripts/package_skill.py "$SKILL_DIR" dist/ || {
    echo "❌ Packaging failed"
    exit 1
}

# Rename if needed (package name is based on folder basename)
if [ -f "dist/${SKILL_BASENAME}.skill" ]; then
    mv "dist/${SKILL_BASENAME}.skill" dist/endor-setup.skill
fi

echo ""
echo "✅ Build complete!"
echo ""
echo "📦 Output: dist/endor-setup.skill"
echo ""
echo "Next steps:"
echo "  1. Install: cp dist/endor-setup.skill ~/.claude/skills/"
echo "  2. Use: claude \"set up endorctl\""
echo ""
