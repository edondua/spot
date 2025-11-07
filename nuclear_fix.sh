#!/bin/bash

set -e  # Exit on any error

echo "🔧 NUCLEAR FIX: Xcode Project References"
echo "=========================================="
echo ""

PROJECT_DIR="/Users/doruntinaramadani/Desktop/Spotted"
cd "$PROJECT_DIR"

# Step 1: Close Xcode
echo "Step 1: Closing Xcode..."
osascript -e 'tell application "Xcode" to quit' 2>/dev/null || true
sleep 2
echo "✅ Xcode closed"
echo ""

# Step 2: Clean derived data
echo "Step 2: Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Spotted-* 2>/dev/null || true
echo "✅ Derived data cleaned"
echo ""

# Step 3: Restore clean project file
echo "Step 3: Restoring project file..."
if [ -f "Spotted.xcodeproj/project.pbxproj.backup" ]; then
    cp Spotted.xcodeproj/project.pbxproj.backup Spotted.xcodeproj/project.pbxproj
    echo "✅ Project file restored"
else
    echo "⚠️  No backup found, using current project file"
fi
echo ""

# Step 4: List all Swift files that need to be in project
echo "Step 4: Scanning project files..."
echo ""
echo "📄 Found these Swift files:"
find Spotted -name "*.swift" -type f | grep -v ".build" | sort | while read file; do
    echo "   $file"
done
echo ""

# Step 5: Show instructions
echo "=========================================="
echo "✅ READY FOR MANUAL FIX"
echo "=========================================="
echo ""
echo "Now do this in Xcode:"
echo ""
echo "1. Open project:"
echo "   open Spotted.xcodeproj"
echo ""
echo "2. In Project Navigator (left sidebar):"
echo "   • Delete ALL RED files (select → Delete → 'Remove Reference')"
echo "   • Keep deleting until no red files remain"
echo ""
echo "3. Re-add all files:"
echo "   • Right-click blue 'Spotted' folder"
echo "   • 'Add Files to Spotted...'"
echo "   • Navigate to and select the inner 'Spotted' folder"
echo "   • Options:"
echo "     ☐ Copy items (UNCHECK)"
echo "     ⦿ Create groups (SELECT)"
echo "     ☑ Spotted target (CHECK)"
echo "   • Click 'Add'"
echo ""
echo "4. Build: Cmd+B"
echo ""
echo "=========================================="
echo ""

# Open Xcode
echo "Opening Xcode now..."
open Spotted.xcodeproj
sleep 3

echo ""
echo "🎯 Xcode is open! Follow the steps above."
echo ""
