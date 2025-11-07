#!/bin/bash

echo "🔧 Fixing Xcode Project References"
echo "===================================="
echo ""

cd /Users/doruntinaramadani/Desktop/Spotted

# Close Xcode if running
osascript -e 'tell application "Xcode" to quit' 2>/dev/null
sleep 2

echo "✅ Closed Xcode"
echo ""

# List files that need to be added
echo "📄 Design System Files:"
find Spotted/Core/DesignSystem -name "*.swift" -type f | sed 's/^/   /'
echo ""
find Spotted -name "TestDesignSystemView.swift" -type f | sed 's/^/   /'
echo ""

echo "📝 Manual Steps Required:"
echo ""
echo "1. Open Xcode:"
echo "   open Spotted.xcodeproj"
echo ""
echo "2. In Project Navigator (left sidebar):"
echo "   • Look for 'Core' folder"
echo "   • If 'DesignSystem' is missing, add it:"
echo "     - Right-click 'Core'"
echo "     - Add Files → Select 'DesignSystem' folder"
echo ""
echo "3. Build project: Cmd+B"
echo ""
echo "4. Test preview:"
echo "   • Open TestDesignSystemView.swift"
echo "   • Click Preview Resume ▶️"
echo ""

# Reopen Xcode
echo "⏳ Opening Xcode..."
open Spotted.xcodeproj

echo ""
echo "✨ Ready! Follow the manual steps above."
