#!/bin/bash

echo "🎨 Design System Setup Script"
echo "=============================="
echo ""

PROJECT_DIR="/Users/doruntinaramadani/Desktop/Spotted"
DESIGN_SYSTEM_DIR="$PROJECT_DIR/Spotted/Core/DesignSystem"

# Check if design system exists
if [ ! -d "$DESIGN_SYSTEM_DIR" ]; then
    echo "❌ Error: Design system directory not found at:"
    echo "   $DESIGN_SYSTEM_DIR"
    exit 1
fi

# List design system files
echo "✅ Found design system files:"
echo ""
find "$DESIGN_SYSTEM_DIR" -name "*.swift" -type f | while read file; do
    echo "   📄 $(basename "$file")"
done
echo ""

# Instructions
echo "📝 Next Steps:"
echo ""
echo "1. Open Xcode:"
echo "   cd '$PROJECT_DIR'"
echo "   open Spotted.xcodeproj"
echo ""
echo "2. In Xcode:"
echo "   • Right-click on 'Spotted' folder in Project Navigator"
echo "   • Select 'Add Files to Spotted...'"
echo "   • Navigate to: Spotted/Core/DesignSystem/"
echo "   • Select the DesignSystem folder"
echo "   • Make sure 'Create groups' is selected"
echo "   • Make sure your app target is checked"
echo "   • Click 'Add'"
echo ""
echo "3. Verify:"
echo "   • Press Cmd+B to build"
echo "   • Open any Component file (e.g., Buttons.swift)"
echo "   • Click the Preview button (▶️) to see components"
echo ""
echo "🚀 Ready to use the design system!"
