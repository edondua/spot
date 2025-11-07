# Spotted Design System

**Version:** 1.0
**Last Updated:** November 2025
**Status:** ✅ Complete

---

## Overview

The Spotted Design System is a comprehensive UI/UX framework built for SwiftUI that ensures consistency, accessibility, and professional polish across the entire app. It follows iOS Human Interface Guidelines and implements industry best practices.

### Key Features

- ✅ **8pt Grid System** - Mathematical spacing scale for visual harmony
- ✅ **Typography System** - 25+ semantic text styles
- ✅ **Component Library** - 50+ reusable UI components
- ✅ **Accessibility First** - VoiceOver, Dynamic Type, WCAG AA compliance
- ✅ **Design Tokens** - Centralized design values
- ✅ **Dark Mode Ready** - Automatic theme support
- ✅ **Haptic Feedback** - Tactile user interactions

---

## Table of Contents

1. [Design Tokens](#design-tokens)
2. [Typography](#typography)
3. [Components](#components)
4. [Accessibility](#accessibility)
5. [Usage Guidelines](#usage-guidelines)
6. [Best Practices](#best-practices)

---

## Design Tokens

**Location:** `Core/DesignSystem/DesignTokens.swift`

### Spacing (8pt Grid)

```swift
DesignTokens.Spacing.xxxs  // 4pt
DesignTokens.Spacing.xxs   // 8pt
DesignTokens.Spacing.xs    // 12pt
DesignTokens.Spacing.sm    // 16pt
DesignTokens.Spacing.md    // 20pt
DesignTokens.Spacing.lg    // 24pt
DesignTokens.Spacing.xl    // 32pt
DesignTokens.Spacing.xxl   // 40pt
DesignTokens.Spacing.xxxl  // 48pt
DesignTokens.Spacing.huge  // 64pt
```

**Usage:**
```swift
VStack(spacing: DesignTokens.Spacing.md) {
    Text("Title")
    Text("Subtitle")
}
.paddingLG() // View extension
```

### Corner Radius

```swift
DesignTokens.CornerRadius.xs    // 4pt - Minimal
DesignTokens.CornerRadius.sm    // 8pt - Buttons, tags
DesignTokens.CornerRadius.md    // 12pt - Cards, inputs
DesignTokens.CornerRadius.lg    // 16pt - Modal sheets
DesignTokens.CornerRadius.xl    // 20pt - Pills, badges
DesignTokens.CornerRadius.xxl   // 24pt
DesignTokens.CornerRadius.circle // 999 - Circular
```

### Colors

**Brand Colors:**
```swift
DesignTokens.Colors.primary      // Pink (#FC6C85)
DesignTokens.Colors.secondary    // Orange (#FF9500)
```

**Semantic Colors:**
```swift
DesignTokens.Colors.success      // Green
DesignTokens.Colors.error        // Red
DesignTokens.Colors.warning      // Orange
DesignTokens.Colors.info         // Blue
```

**Text Colors:**
```swift
DesignTokens.Colors.textPrimary    // Primary label
DesignTokens.Colors.textSecondary  // Secondary label
DesignTokens.Colors.textTertiary   // Tertiary label
DesignTokens.Colors.textDisabled   // Disabled text
```

**Background Colors:**
```swift
DesignTokens.Colors.backgroundPrimary    // System background
DesignTokens.Colors.backgroundSecondary  // Cards, inputs
DesignTokens.Colors.backgroundTertiary   // Grouped lists
```

### Shadows

```swift
.shadowSmall()      // Subtle depth
.shadowMedium()     // Standard cards
.shadowLarge()      // Modals, FAB
.shadowExtraLarge() // Top-level overlays
```

### Animations

```swift
DesignTokens.Animations.quick    // 0.2s - Button taps
DesignTokens.Animations.standard // 0.3s - General UI
DesignTokens.Animations.smooth   // 0.4s - Page transitions
DesignTokens.Animations.gentle   // 0.5s - Smooth reveals
DesignTokens.Animations.bouncy   // 0.4s - Playful interactions
```

### Sizes

```swift
// Icons
DesignTokens.Size.Icon.tiny        // 12pt
DesignTokens.Size.Icon.small       // 16pt
DesignTokens.Size.Icon.medium      // 20pt
DesignTokens.Size.Icon.large       // 24pt

// Avatars
DesignTokens.Size.Avatar.small     // 32pt
DesignTokens.Size.Avatar.medium    // 40pt
DesignTokens.Size.Avatar.large     // 56pt

// Buttons
DesignTokens.Size.Button.small     // 32pt height
DesignTokens.Size.Button.medium    // 44pt height
DesignTokens.Size.Button.large     // 56pt height
```

---

## Typography

**Location:** `Core/DesignSystem/Typography.swift`

### Display Styles (Large Titles)

```swift
Text("Welcome")
    .displayLarge()    // 34pt, Bold - Hero text
    .displayMedium()   // 28pt, Bold - Section titles
    .displaySmall()    // 24pt, Bold - Subsection titles
```

### Headings

```swift
Text("Section")
    .heading1()  // 22pt, Bold - Major sections
    .heading2()  // 20pt, Semibold - Card titles
    .heading3()  // 18pt, Semibold - Subheadings
    .heading4()  // 16pt, Semibold - Small headings
```

### Body Text

```swift
Text("Content")
    .bodyLarge()              // 17pt - Primary body
    .bodyLargeEmphasized()    // 17pt, Semibold
    .bodyMedium()             // 15pt - Secondary body
    .bodyMediumEmphasized()   // 15pt, Semibold
    .bodySmall()              // 13pt - Tertiary content
```

### Labels

```swift
Text("LABEL")
    .labelLarge()   // 16pt, Semibold - Button text
    .labelMedium()  // 14pt, Semibold - Form labels
    .labelSmall()   // 12pt, Semibold - Tags
    .labelTiny()    // 10pt, Semibold - Timestamps
```

### Captions

```swift
Text("Caption")
    .captionLarge()   // 14pt - Image captions
    .captionMedium()  // 12pt - Timestamps
    .captionSmall()   // 11pt - Small text
```

---

## Components

### Buttons

**Location:** `Core/DesignSystem/Components/Buttons.swift`

#### SpottedButton

```swift
// Primary button (gradient)
SpottedButton(title: "Continue", style: .primary) {
    navigateNext()
}

// Secondary button (outlined)
SpottedButton(title: "Cancel", style: .secondary) {
    dismiss()
}

// Tertiary button (text only)
SpottedButton(title: "Skip", style: .tertiary) {
    skip()
}

// Destructive button
SpottedButton(title: "Delete", style: .destructive) {
    deleteAccount()
}
```

#### Icon Buttons

```swift
// Standard icon button
SpottedIconButton(icon: "heart.fill") {
    likeUser()
}

// Floating action button
FloatingActionButton(icon: "plus") {
    createNew()
}
```

#### Button Styles (for custom buttons)

```swift
Button("Custom") { action() }
    .primaryButtonStyle()
    .secondaryButtonStyle()
    .tertiaryButtonStyle()
    .destructiveButtonStyle()
```

---

### Cards

**Location:** `Core/DesignSystem/Components/Cards.swift`

#### Generic Cards

```swift
// Elevated card (with shadow)
SpottedCard(style: .elevated) {
    Text("Content")
}

// Flat card (no shadow)
SpottedCard(style: .flat) {
    Text("Content")
}

// Outlined card (border)
SpottedCard(style: .outlined) {
    Text("Content")
}
```

#### Specialized Cards

```swift
// User profile card
UserCard(
    userName: "Sarah",
    userAge: 27,
    userBio: "Coffee lover & hiker",
    profileImage: "avatar"
) {
    showProfile()
}

// Location card
LocationCard(
    locationName: "Zürich HB",
    locationAddress: "Bahnhofplatz",
    activeUsers: 24
) {
    showLocation()
}

// Info card (tips, warnings, errors)
InfoCard(
    type: .tip,
    title: "Pro Tip",
    message: "Add 6 photos to get more matches!"
)
```

#### Card Modifiers

```swift
VStack {
    Text("Content")
}
.elevatedCard()
.flatCard()
.outlinedCard()
```

---

### Text Fields

**Location:** `Core/DesignSystem/Components/TextFields.swift`

#### Standard Text Field

```swift
@State private var name = ""

SpottedTextField(
    label: "Name",
    placeholder: "Enter your name",
    text: $name,
    icon: "person.fill"
)
```

#### Text Field with Validation

```swift
@State private var email = ""

SpottedTextField(
    label: "Email",
    placeholder: "your@email.com",
    text: $email,
    icon: "envelope.fill",
    errorMessage: isValidEmail ? nil : "Invalid email format"
)
```

#### Text Field with Character Limit

```swift
@State private var bio = ""

SpottedTextField(
    label: "Bio",
    placeholder: "Tell us about yourself",
    text: $bio,
    icon: "text.alignleft",
    maxLength: 150
)
```

#### Secure Field (Password)

```swift
@State private var password = ""

SpottedSecureField(
    label: "Password",
    placeholder: "Enter password",
    text: $password
)
```

#### Text Editor (Multi-line)

```swift
@State private var aboutMe = ""

SpottedTextEditor(
    label: "About Me",
    placeholder: "Share your interests...",
    text: $aboutMe,
    maxLength: 500
)
```

#### Search Field

```swift
@State private var searchQuery = ""

SpottedSearchField(
    placeholder: "Search",
    text: $searchQuery,
    onSubmit: {
        performSearch()
    }
)
```

---

### Badges & Tags

**Location:** `Core/DesignSystem/Components/Badges.swift`

#### Standard Badges

```swift
// Filled badge
SpottedBadge("New", color: .primary, style: .filled)

// Outlined badge
SpottedBadge("Active", color: .success, style: .outlined)

// Subtle badge (light background)
SpottedBadge("Premium", color: .secondary, style: .subtle)

// Badge with icon
SpottedBadge(
    "Verified",
    color: .info,
    style: .subtle,
    icon: "checkmark.seal.fill"
)
```

#### Status Badges

```swift
// With text
StatusBadge(.online)
StatusBadge(.away)
StatusBadge(.busy)

// Dot only
StatusBadge(.online, showText: false)
```

#### Count Badges

```swift
ZStack(alignment: .topTrailing) {
    Image(systemName: "bell.fill")
        .font(.system(size: 24))

    CountBadge(count: 5)
        .offset(x: 4, y: -4)
}
```

#### Tags (Interactive)

```swift
@State private var selectedTags: Set<String> = []

SpottedTag("Music", isSelected: selectedTags.contains("Music")) {
    if selectedTags.contains("Music") {
        selectedTags.remove("Music")
    } else {
        selectedTags.insert("Music")
    }
}
```

#### Removable Tags

```swift
RemovableTag(text: "Coffee") {
    removeInterest("Coffee")
}
```

#### Special Badges

```swift
// Verification badge
VerificationBadge(size: 20)

// Premium badge
PremiumBadge()
```

---

### Dialogs & Alerts

**Location:** `Core/DesignSystem/Components/Dialogs.swift`

#### Alert Dialog

```swift
@State private var showAlert = false

.dialog(isPresented: $showAlert) {
    AlertDialog(
        type: .success,
        title: "Success!",
        message: "Your profile has been updated.",
        primaryButton: "OK"
    ) {
        showAlert = false
    }
}
```

#### Alert with Two Buttons

```swift
AlertDialog(
    type: .warning,
    title: "Delete Photo?",
    message: "This cannot be undone.",
    primaryButton: "Delete",
    secondaryButton: "Cancel",
    onPrimary: {
        deletePhoto()
        showAlert = false
    },
    onSecondary: {
        showAlert = false
    }
)
```

#### Confirmation Dialog

```swift
@State private var showConfirmation = false

.dialog(isPresented: $showConfirmation) {
    ConfirmationDialog(
        title: "Delete Account?",
        message: "This will permanently delete all your data.",
        confirmText: "Delete",
        isDestructive: true,
        onConfirm: {
            deleteAccount()
            showConfirmation = false
        },
        onCancel: {
            showConfirmation = false
        }
    )
}
```

#### Input Dialog

```swift
@State private var showInput = false
@State private var inputText = ""

.dialog(isPresented: $showInput) {
    InputDialog(
        title: "Report User",
        message: "Tell us why you're reporting.",
        placeholder: "Enter reason...",
        text: $inputText,
        onConfirm: {
            submitReport(inputText)
            showInput = false
        },
        onCancel: {
            showInput = false
        }
    )
}
```

#### Bottom Sheet

```swift
@State private var showSheet = false

BottomSheetDialog(isPresented: $showSheet) {
    VStack(spacing: 16) {
        Text("Share Profile")
            .heading2()

        // Share options
        Button("Copy Link") { copyLink() }
        Button("Share via Message") { shareMessage() }
    }
    .padding()
}
```

#### Loading Dialog

```swift
@State private var isLoading = false

ZStack {
    ContentView()

    if isLoading {
        Color.black.opacity(0.4)
            .ignoresSafeArea()

        LoadingDialog(message: "Uploading photos...")
    }
}
```

---

### Loading States

**Location:** `Core/DesignSystem/Components/LoadingStates.swift`

#### Loading Indicators

```swift
// Standard spinner
LoadingSpinner(size: 44)

// Pulsing dots
PulsingLoader()

// Animated loading bar
LoadingBar()

// Progress bar
@State private var progress: Double = 0.65
ProgressBar(progress: progress, showPercentage: true)
```

#### Loading Views

```swift
// Full-screen loading
if isLoading {
    LoadingView(message: "Loading your matches...")
}

// Inline loading (for lists)
if isLoadingMore {
    InlineLoadingView(message: "Loading more...")
}
```

#### Skeleton Loaders

```swift
if isLoading {
    ForEach(0..<5) { _ in
        SkeletonCard()
    }
} else {
    ForEach(users) { user in
        UserCard(user: user)
    }
}
```

#### Empty States

```swift
if users.isEmpty {
    EmptyStateView(
        icon: "person.2.slash",
        title: "No Matches Yet",
        message: "Start swiping to find your perfect match!",
        actionTitle: "Start Swiping",
        action: startSwiping
    )
}

// No search results
if searchResults.isEmpty {
    NoResultsView(
        searchQuery: searchText,
        onClearSearch: { searchText = "" }
    )
}
```

#### Error States

```swift
if let error = errorMessage {
    ErrorStateView(
        title: "Oops!",
        message: error,
        onRetry: loadData
    )
}

// Network error
if !hasConnection {
    NetworkErrorView(onRetry: retryConnection)
}
```

#### Async Content Wrapper

```swift
enum LoadState {
    case idle, loading, loaded, empty, error(Error)
}

@State private var state: LoadState = .loading

AsyncContentView(
    state: state,
    content: {
        List(items) { item in
            ItemRow(item: item)
        }
    },
    emptyView: {
        EmptyStateView(
            icon: "tray",
            title: "No Items",
            message: "You don't have any items yet."
        )
    },
    onRetry: {
        loadData()
    }
)
```

---

## Accessibility

**Location:** `Core/DesignSystem/Accessibility.swift`

### VoiceOver Labels

```swift
// Pre-defined labels
AccessibilityHelper.likeButton      // "Like user"
AccessibilityHelper.dislikeButton   // "Pass on user"
AccessibilityHelper.messageButton   // "Send message"
AccessibilityHelper.profileButton   // "View profile"

// Usage
Button("❤️") {
    likeUser()
}
.accessibleButton(
    AccessibilityHelper.likeButton,
    hint: AccessibilityHelper.likeHint
)
```

### Quick Accessibility Modifiers

```swift
// Button accessibility
Button("Like") { action() }
    .accessibleButton("Like user", hint: "Double tap to like")

// Image accessibility
Image("profile")
    .accessibleImage("Profile photo of Sarah at the beach")

// Decorative image (hidden from VoiceOver)
Image(systemName: "sparkles")
    .decorativeImage()

// Header
Text("Discover")
    .heading1()
    .accessibleHeader("Discover section")

// Grouped elements
HStack {
    Image(systemName: "person")
    Text("John, 28")
    Text("2km away")
}
.accessibilityGrouped() // Reads as one element
```

### Pre-built Accessibility Modifiers

```swift
// Like button with accessibility
Button("❤️") { likeUser() }
    .likeButtonAccessibility()

// Pass button with accessibility
Button("✕") { passUser() }
    .passButtonAccessibility()

// Message button
Button("💬") { sendMessage() }
    .messageButtonAccessibility()

// Profile button
Button("👤") { viewProfile() }
    .profileButtonAccessibility()
```

### Touch Targets

```swift
// Ensure minimum 44x44 touch target
Button("X") {
    close()
}
.touchTargetMinimum()
```

### Dynamic Type Support

```swift
// Enable dynamic type scaling
Text("Welcome")
    .displayLarge()
    .dynamicTypeSupport()

// Limit dynamic type range
Text("Button Text")
    .labelLarge()
    .limitDynamicType(min: .small, max: .xxLarge)
```

### Color Contrast Checker

```swift
let pink = UIColor(red: 252/255, green: 108/255, blue: 133/255, alpha: 1)
let white = UIColor.white

// Check WCAG AA compliance (4.5:1)
let meetsAA = ContrastChecker.meetsWCAG_AA(
    foreground: white,
    background: pink
)

// Check WCAG AAA compliance (7:1)
let meetsAAA = ContrastChecker.meetsWCAG_AAA(
    foreground: white,
    background: pink
)

// Get contrast ratio
let ratio = ContrastChecker.contrastRatio(
    foreground: white,
    background: pink
)
```

---

## Usage Guidelines

### Component Selection

#### When to use each button style:

- **Primary** - Main call-to-action (1 per screen max)
- **Secondary** - Alternative actions, Cancel buttons
- **Tertiary** - Subtle actions, "Skip" links
- **Ghost** - Minimal UI, text-only links
- **Destructive** - Delete, Remove, dangerous actions
- **Icon** - Toolbar actions, compact spaces
- **FAB** - Primary floating action (create, add)

#### When to use each card style:

- **Elevated** - Content cards, list items, default choice
- **Flat** - Grouped content, info boxes
- **Outlined** - Secondary content, selection states

#### When to use loading states:

- **LoadingSpinner** - General loading, unknown duration
- **PulsingLoader** - Playful loading, brand-aligned
- **LoadingBar** - Indeterminate progress
- **ProgressBar** - Known progress (uploads, downloads)
- **SkeletonCard** - List items loading
- **EmptyStateView** - No content available
- **ErrorStateView** - Failed operations

### Spacing Best Practices

```swift
// Vertical spacing hierarchy
VStack(spacing: DesignTokens.Spacing.xxxs) { ... } // Tightly grouped (4pt)
VStack(spacing: DesignTokens.Spacing.sm) { ... }   // Related items (16pt)
VStack(spacing: DesignTokens.Spacing.lg) { ... }   // Sections (24pt)
VStack(spacing: DesignTokens.Spacing.xl) { ... }   // Major sections (32pt)

// Padding hierarchy
.padding(DesignTokens.Spacing.sm)   // 16pt - Compact
.padding(DesignTokens.Spacing.md)   // 20pt - Standard
.padding(DesignTokens.Spacing.lg)   // 24pt - Comfortable
```

### Typography Hierarchy

```swift
// Page structure
VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
    // Page title
    Text("Welcome to Spotted")
        .displayLarge()

    // Section header
    Text("Discover People")
        .heading1()

    // Subsection header
    Text("Near You")
        .heading2()

    // Card title
    Text("Featured Profiles")
        .heading3()

    // Body content
    Text("Find your perfect match...")
        .bodyLarge()

    // Secondary info
    Text("Update your preferences anytime")
        .bodyMedium()
        .foregroundColor(DesignTokens.Colors.textSecondary)

    // Metadata
    Text("Last updated 2 hours ago")
        .captionMedium()
        .foregroundColor(DesignTokens.Colors.textTertiary)
}
```

---

## Best Practices

### 1. Always Use Design Tokens

❌ **Don't:**
```swift
.padding(16)
.foregroundColor(Color.pink)
.font(.system(size: 18))
```

✅ **Do:**
```swift
.paddingSM()
.foregroundColor(DesignTokens.Colors.primary)
.heading3()
```

### 2. Use Component Library

❌ **Don't:**
```swift
Button("Continue") {
    action()
}
.font(.system(size: 18, weight: .bold))
.foregroundColor(.white)
.frame(maxWidth: .infinity, height: 56)
.background(Color.pink)
.cornerRadius(16)
```

✅ **Do:**
```swift
SpottedButton(title: "Continue", style: .primary) {
    action()
}
```

### 3. Add Accessibility

❌ **Don't:**
```swift
Button {
    likeUser()
} label: {
    Image(systemName: "heart.fill")
}
```

✅ **Do:**
```swift
Button {
    likeUser()
} label: {
    Image(systemName: "heart.fill")
}
.likeButtonAccessibility()
```

### 4. Handle All States

❌ **Don't:**
```swift
List(users) { user in
    UserRow(user: user)
}
```

✅ **Do:**
```swift
if isLoading {
    ForEach(0..<5) { _ in
        SkeletonCard()
    }
} else if users.isEmpty {
    EmptyStateView(
        icon: "person.2.slash",
        title: "No Users",
        message: "Try adjusting your filters"
    )
} else {
    List(users) { user in
        UserRow(user: user)
    }
}
```

### 5. Provide Haptic Feedback

❌ **Don't:**
```swift
Button("Delete") {
    deleteItem()
}
```

✅ **Do:**
```swift
Button("Delete") {
    HapticFeedback.impact(.heavy)
    deleteItem()
}
// Or use SpottedButton which includes haptics
```

### 6. Use Semantic Colors

❌ **Don't:**
```swift
.foregroundColor(.red)
.foregroundColor(.green)
```

✅ **Do:**
```swift
.foregroundColor(DesignTokens.Colors.error)
.foregroundColor(DesignTokens.Colors.success)
```

### 7. Consistent Animations

❌ **Don't:**
```swift
withAnimation(.easeInOut(duration: 0.25)) {
    isExpanded.toggle()
}
```

✅ **Do:**
```swift
withAnimation(DesignTokens.Animations.smooth) {
    isExpanded.toggle()
}
```

---

## Component Checklist

### ✅ Complete Component Library

#### **Foundation**
- [x] Typography System (25+ styles)
- [x] Design Tokens (spacing, colors, shadows, animations)
- [x] Accessibility Helpers

#### **Input Components**
- [x] SpottedTextField
- [x] SpottedSecureField
- [x] SpottedTextEditor
- [x] SpottedSearchField

#### **Action Components**
- [x] SpottedButton (5 styles)
- [x] SpottedIconButton
- [x] FloatingActionButton

#### **Display Components**
- [x] SpottedCard (3 variants)
- [x] UserCard
- [x] LocationCard
- [x] InfoCard

#### **Feedback Components**
- [x] SpottedBadge
- [x] StatusBadge
- [x] CountBadge
- [x] SpottedTag
- [x] RemovableTag
- [x] VerificationBadge
- [x] PremiumBadge

#### **Dialog Components**
- [x] AlertDialog
- [x] ConfirmationDialog
- [x] BottomSheetDialog
- [x] LoadingDialog
- [x] InputDialog

#### **Loading Components**
- [x] LoadingSpinner
- [x] PulsingLoader
- [x] LoadingBar
- [x] ProgressBar
- [x] SkeletonCard
- [x] LoadingView
- [x] InlineLoadingView

#### **State Components**
- [x] EmptyStateView
- [x] NoResultsView
- [x] ErrorStateView
- [x] NetworkErrorView
- [x] AsyncContentView

---

## Migration Guide

### Updating Existing Views

1. **Replace hardcoded spacing:**
   ```swift
   // Before
   .padding(16)

   // After
   .paddingSM()
   // or
   .padding(DesignTokens.Spacing.sm)
   ```

2. **Update button styles:**
   ```swift
   // Before
   Button("Continue") { action() }
       .font(.system(size: 18, weight: .bold))
       .foregroundColor(.white)
       .background(Color.pink)

   // After
   SpottedButton(title: "Continue", style: .primary) {
       action()
   }
   ```

3. **Add accessibility:**
   ```swift
   // Before
   Button {
       likeUser()
   } label: {
       Image(systemName: "heart.fill")
   }

   // After
   Button {
       likeUser()
   } label: {
       Image(systemName: "heart.fill")
   }
   .likeButtonAccessibility()
   ```

4. **Use typography modifiers:**
   ```swift
   // Before
   Text("Title")
       .font(.system(size: 22, weight: .bold))

   // After
   Text("Title")
       .heading1()
   ```

---

## File Structure

```
Core/DesignSystem/
├── DesignTokens.swift         // Spacing, colors, shadows, animations
├── Typography.swift           // Text styles and modifiers
├── Accessibility.swift        // VoiceOver, Dynamic Type, WCAG
└── Components/
    ├── Buttons.swift          // Button components and styles
    ├── Cards.swift            // Card components
    ├── TextFields.swift       // Input components
    ├── Badges.swift           // Badges and tags
    ├── Dialogs.swift          // Alerts and dialogs
    └── LoadingStates.swift    // Loading, empty, error states
```

---

## Resources

### Related Documentation
- [UX/UI Audit Report](UX_UI_AUDIT_REPORT.md)
- [Architecture Guide](ARCHITECTURE.md)
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

### Design System Principles
1. **Consistency** - Use the same patterns everywhere
2. **Accessibility** - Design for everyone
3. **Performance** - Keep components lightweight
4. **Flexibility** - Allow customization when needed
5. **Documentation** - Make it easy to use correctly

---

## Support

For questions about the design system:
1. Check this documentation first
2. Review component preview files (`#Preview` blocks)
3. See usage examples in each component file
4. Refer to the UX/UI Audit Report for context

---

**Version History:**
- **1.0** (Nov 2025) - Initial design system release
  - Typography system
  - Design tokens
  - 50+ UI components
  - Accessibility framework
  - Comprehensive documentation
