# Design System Implementation Guide

**Purpose:** Step-by-step guide to apply the new design system to existing Spotted app views.

**Prerequisites:**
1. ✅ Design system files created in `Core/DesignSystem/`
2. ⚠️ Fix Xcode project references (see `REORGANIZATION_GUIDE.md`)
3. ✅ Build succeeds with no errors

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Priority Views to Update](#priority-views-to-update)
3. [Step-by-Step Refactoring](#step-by-step-refactoring)
4. [Common Patterns](#common-patterns)
5. [Testing Checklist](#testing-checklist)

---

## Quick Start

### Before You Begin

1. **Fix Xcode Project References**
   - Follow `REORGANIZATION_GUIDE.md` to fix file references
   - Ensure project builds successfully
   - All design system files should be accessible

2. **Import Design System**
   ```swift
   // No imports needed! Design system is part of the same module.
   // All components and tokens are immediately available.
   ```

3. **Test Individual Components**
   ```swift
   // In Xcode, open any component file and use Live Preview
   // Example: Open Buttons.swift and click Preview button
   #Preview("Buttons") {
       // Preview content here
   }
   ```

---

## Priority Views to Update

Based on user traffic and visibility, update in this order:

### Phase 1: High Priority (Week 1)
1. **DiscoverView** - Main swipe interface
2. **MapView** - Location discovery
3. **MatchesView** - Chat/matches list
4. **ProfileView** - User profile display
5. **OnboardingView** - First-time user experience

### Phase 2: Medium Priority (Week 2)
6. **EditProfileView** - Profile editing
7. **SettingsView** - App settings
8. **ChatView** - Individual chat
9. **FilterView** - Filter options
10. **LocationDetailView** - Location details

### Phase 3: Low Priority (Week 3)
11. **NotificationsView**
12. **HelpView**
13. **PrivacyView**
14. Other secondary screens

---

## Step-by-Step Refactoring

### Example: Updating DiscoverView

#### Step 1: Identify Current Patterns

**Before (DiscoverView.swift):**
```swift
// Current hardcoded values
VStack(spacing: 16) {
    Text("Discover")
        .font(.system(size: 28, weight: .bold))
        .foregroundColor(.pink)

    Button("Like") {
        likeUser()
    }
    .font(.system(size: 18, weight: .bold))
    .foregroundColor(.white)
    .padding()
    .background(Color.pink)
    .cornerRadius(12)
}
```

#### Step 2: Replace with Design System

**After:**
```swift
VStack(spacing: DesignTokens.Spacing.sm) {
    Text("Discover")
        .displayMedium()
        .foregroundColor(DesignTokens.Colors.primary)

    SpottedButton(title: "Like", style: .primary) {
        likeUser()
    }
}
```

#### Step 3: Add Accessibility

```swift
VStack(spacing: DesignTokens.Spacing.sm) {
    Text("Discover")
        .displayMedium()
        .foregroundColor(DesignTokens.Colors.primary)
        .accessibleHeader("Discover section")

    SpottedButton(title: "Like", style: .primary) {
        likeUser()
    }
    // SpottedButton already includes haptics and accessibility!
}
```

---

### Example: Updating MapView

#### Current Issues in MapView
1. Hardcoded colors
2. No loading states
3. Missing accessibility labels
4. Inconsistent spacing

#### Refactoring MapView

**1. Replace Filter Button:**

Before:
```swift
Button(action: { showFilters = true }) {
    Image(systemName: "line.3.horizontal.decrease.circle.fill")
        .font(.system(size: 32))
        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
}
```

After:
```swift
SpottedIconButton(icon: "line.3.horizontal.decrease.circle.fill", size: 48) {
    showFilters = true
}
.accessibleButton("Open filters", hint: "Double tap to filter locations")
```

**2. Add Loading State:**

```swift
if isLoadingLocations {
    LoadingView(message: "Loading nearby locations...")
} else if locations.isEmpty {
    EmptyStateView(
        icon: "mappin.slash",
        title: "No Locations Nearby",
        message: "Try adjusting your search radius or explore a different area.",
        actionTitle: "Adjust Filters",
        action: { showFilters = true }
    )
} else {
    // Map content
}
```

**3. Update Location Cards:**

Before:
```swift
VStack(alignment: .leading) {
    Text(location.name)
        .font(.system(size: 18, weight: .semibold))
    Text(location.address)
        .font(.system(size: 14))
        .foregroundColor(.gray)
}
.padding()
.background(Color.white)
.cornerRadius(12)
```

After:
```swift
LocationCard(
    locationName: location.name,
    locationAddress: location.address,
    activeUsers: location.activeUsers
) {
    selectedLocation = location
    showLocationDetail = true
}
```

---

### Example: Updating ProfileView

#### Replace Profile Header

Before:
```swift
VStack(spacing: 8) {
    Circle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 100, height: 100)

    Text(user.name)
        .font(.system(size: 24, weight: .bold))

    Text("\(user.age) years old")
        .font(.system(size: 16))
        .foregroundColor(.gray)
}
```

After:
```swift
VStack(spacing: DesignTokens.Spacing.sm) {
    Circle()
        .fill(DesignTokens.Colors.backgroundSecondary)
        .frame(
            width: DesignTokens.Size.Avatar.huge,
            height: DesignTokens.Size.Avatar.huge
        )
        .accessibleImage("Profile photo of \(user.name)")

    Text(user.name)
        .displaySmall()
        .foregroundColor(DesignTokens.Colors.textPrimary)

    Text("\(user.age) years old")
        .bodyMedium()
        .foregroundColor(DesignTokens.Colors.textSecondary)
}
.accessibilityGrouped()
```

#### Replace Interest Tags

Before:
```swift
ForEach(user.interests, id: \.self) { interest in
    Text(interest)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.pink.opacity(0.2))
        .cornerRadius(16)
}
```

After:
```swift
FlowLayout(spacing: DesignTokens.Spacing.xxs) {
    ForEach(user.interests, id: \.self) { interest in
        SpottedTag(interest, isSelected: false)
    }
}
```

#### Add Edit Button

Before:
```swift
Button("Edit Profile") {
    showEditProfile = true
}
.font(.system(size: 16, weight: .semibold))
.padding()
.background(Color.pink)
.foregroundColor(.white)
.cornerRadius(12)
```

After:
```swift
SpottedButton(title: "Edit Profile", style: .primary) {
    showEditProfile = true
}
.accessibleButton(
    "Edit profile",
    hint: "Double tap to edit your profile information"
)
```

---

### Example: Updating EditProfileView

#### Replace Text Fields

Before:
```swift
VStack(alignment: .leading) {
    Text("Name")
        .font(.system(size: 14, weight: .medium))

    TextField("Enter your name", text: $name)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
}
```

After:
```swift
SpottedTextField(
    label: "Name",
    placeholder: "Enter your name",
    text: $name,
    icon: "person.fill",
    maxLength: 50
)
```

#### Add Validation

```swift
SpottedTextField(
    label: "Age",
    placeholder: "18-99",
    text: $age,
    icon: "calendar",
    errorMessage: isValidAge ? nil : "Must be 18 or older"
)
```

#### Replace Bio Editor

Before:
```swift
TextEditor(text: $bio)
    .frame(height: 120)
    .padding()
    .background(Color.gray.opacity(0.1))
    .cornerRadius(8)
```

After:
```swift
SpottedTextEditor(
    label: "About Me",
    placeholder: "Tell us about yourself...",
    text: $bio,
    maxLength: 500,
    minHeight: 120
)
```

---

### Example: Updating MatchesView

#### Replace User List Items

Before:
```swift
HStack {
    Circle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 60, height: 60)

    VStack(alignment: .leading) {
        Text(match.name)
            .font(.system(size: 16, weight: .semibold))
        Text(match.lastMessage)
            .font(.system(size: 14))
            .foregroundColor(.gray)
    }
}
.padding()
```

After:
```swift
UserCard(
    userName: match.name,
    userAge: match.age,
    userBio: match.lastMessage,
    profileImage: match.profileImage
) {
    selectedMatch = match
    showChat = true
}
```

#### Add Empty State

```swift
if matches.isEmpty {
    EmptyStateView(
        icon: "heart.slash",
        title: "No Matches Yet",
        message: "Keep swiping to find your perfect match!",
        actionTitle: "Start Swiping",
        action: {
            selectedTab = .discover
        }
    )
}
```

#### Add Loading State

```swift
if isLoadingMatches {
    VStack(spacing: DesignTokens.Spacing.sm) {
        ForEach(0..<5) { _ in
            SkeletonCard()
        }
    }
} else if matches.isEmpty {
    EmptyStateView(...)
} else {
    List(matches) { match in
        UserCard(...)
    }
}
```

---

## Common Patterns

### Pattern 1: Replace All Button Styles

**Find & Replace Strategy:**

1. **Primary Buttons** (main CTAs):
   ```swift
   // Find:
   Button("Continue") { action() }
       .font(.system(size: 18, weight: .bold))
       .foregroundColor(.white)
       .background(Color.pink)

   // Replace with:
   SpottedButton(title: "Continue", style: .primary) {
       action()
   }
   ```

2. **Secondary Buttons** (cancel, back):
   ```swift
   SpottedButton(title: "Cancel", style: .secondary) {
       dismiss()
   }
   ```

3. **Icon Buttons**:
   ```swift
   SpottedIconButton(icon: "heart.fill") {
       likeUser()
   }
   ```

### Pattern 2: Replace All Spacing

**Find:**
- `.padding(16)` → `.paddingSM()`
- `.padding(24)` → `.paddingLG()`
- `spacing: 16` → `spacing: DesignTokens.Spacing.sm`
- `spacing: 24` → `spacing: DesignTokens.Spacing.lg`

**Replace:**
```swift
// Before
VStack(spacing: 16) {
    content
}
.padding(24)

// After
VStack(spacing: DesignTokens.Spacing.sm) {
    content
}
.paddingLG()
```

### Pattern 3: Replace All Colors

**Find:**
- `Color.pink` → `DesignTokens.Colors.primary`
- `Color.orange` → `DesignTokens.Colors.secondary`
- `Color.gray` → `DesignTokens.Colors.textSecondary`
- `Color.white` → `DesignTokens.Colors.backgroundPrimary`

**Replace:**
```swift
// Before
Text("Error")
    .foregroundColor(.red)

// After
Text("Error")
    .foregroundColor(DesignTokens.Colors.error)
```

### Pattern 4: Replace All Typography

**Find & Replace:**
```swift
// Before
.font(.system(size: 34, weight: .bold))  → .displayLarge()
.font(.system(size: 28, weight: .bold))  → .displayMedium()
.font(.system(size: 22, weight: .bold))  → .heading1()
.font(.system(size: 20, weight: .semibold)) → .heading2()
.font(.system(size: 18, weight: .semibold)) → .heading3()
.font(.system(size: 17))                 → .bodyLarge()
.font(.system(size: 15))                 → .bodyMedium()
.font(.system(size: 14, weight: .semibold)) → .labelMedium()
.font(.system(size: 12))                 → .captionMedium()
```

### Pattern 5: Add Loading States

**Template:**
```swift
@State private var loadingState: LoadState = .idle

enum LoadState {
    case idle, loading, loaded, empty, error(Error)
}

var body: some View {
    switch loadingState {
    case .idle:
        Color.clear.onAppear { loadData() }

    case .loading:
        LoadingView(message: "Loading...")

    case .loaded:
        // Content

    case .empty:
        EmptyStateView(
            icon: "tray",
            title: "No Items",
            message: "Nothing to show yet."
        )

    case .error(let error):
        ErrorStateView(
            message: error.localizedDescription,
            onRetry: loadData
        )
    }
}
```

### Pattern 6: Add Accessibility

**For All Buttons:**
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
// or
.accessibleButton(
    "Like user",
    hint: "Double tap to like this profile"
)
```

**For All Images:**
```swift
// Meaningful images
Image("profile")
    .accessibleImage("Profile photo of Sarah at the beach")

// Decorative images
Image(systemName: "sparkles")
    .decorativeImage()
```

**For Headers:**
```swift
Text("Discover")
    .heading1()
    .accessibleHeader("Discover section")
```

**For Grouped Info:**
```swift
HStack {
    Image(systemName: "person")
    Text("John, 28")
    Text("2km away")
}
.accessibilityGrouped()
```

---

## Testing Checklist

### After Updating Each View

- [ ] **Build succeeds** with no errors or warnings
- [ ] **Visual appearance** matches design system
- [ ] **Spacing** follows 8pt grid
- [ ] **Typography** uses design system styles
- [ ] **Colors** use design tokens
- [ ] **Buttons** have proper styles and haptic feedback
- [ ] **Loading states** display correctly
- [ ] **Empty states** display when no content
- [ ] **Error states** display and allow retry
- [ ] **Dark mode** works correctly (automatic with design tokens)
- [ ] **VoiceOver** reads all elements properly
- [ ] **Dynamic Type** scales text appropriately
- [ ] **Touch targets** are at least 44x44 points

### Accessibility Testing

1. **Enable VoiceOver** (Settings → Accessibility → VoiceOver)
   - Navigate through the view
   - Ensure all buttons have labels
   - Verify hints are helpful
   - Check grouped elements read correctly

2. **Test Dynamic Type**
   - Settings → Display & Brightness → Text Size
   - Drag slider to largest size
   - Verify text scales appropriately
   - Ensure layout doesn't break

3. **Test Dark Mode**
   - Toggle Appearance (Settings → Display & Brightness)
   - Verify all colors adapt correctly
   - Check contrast ratios are maintained

4. **Test Reduced Motion**
   - Settings → Accessibility → Motion → Reduce Motion
   - Verify animations are simpler
   - Ensure functionality still works

### Performance Testing

- [ ] Scrolling is smooth (60fps)
- [ ] No memory leaks (check Instruments)
- [ ] Images load efficiently
- [ ] Animations don't cause lag

---

## Migration Tracking

### Create a Checklist

```markdown
## Design System Migration Progress

### Phase 1: High Priority
- [ ] DiscoverView
  - [ ] Replace buttons
  - [ ] Add loading states
  - [ ] Add accessibility
  - [ ] Test VoiceOver
- [ ] MapView
  - [ ] Replace buttons
  - [ ] Add empty states
  - [ ] Add accessibility
  - [ ] Test VoiceOver
- [ ] MatchesView
  - [ ] Replace user cards
  - [ ] Add loading states
  - [ ] Add empty states
  - [ ] Test VoiceOver
- [ ] ProfileView
  - [ ] Update layout
  - [ ] Replace tags
  - [ ] Add accessibility
- [ ] OnboardingView
  - [ ] Replace text fields
  - [ ] Update buttons
  - [ ] Add accessibility

### Phase 2: Medium Priority
- [ ] EditProfileView
- [ ] SettingsView
- [ ] ChatView
- [ ] FilterView
- [ ] LocationDetailView

### Phase 3: Low Priority
- [ ] NotificationsView
- [ ] HelpView
- [ ] PrivacyView
```

---

## Common Issues & Solutions

### Issue 1: Xcode Can't Find Design System Components

**Solution:**
1. Ensure all files are added to Xcode project
2. Check file references in Project Navigator
3. Clean build folder (Cmd+Shift+K)
4. Rebuild (Cmd+B)

### Issue 2: Design Tokens Not Available

**Solution:**
```swift
// Make sure DesignTokens.swift is in the same target
// Check Target Membership in File Inspector
```

### Issue 3: Preview Not Working

**Solution:**
```swift
// Ensure preview provider is correct
#Preview("ViewName") {
    ViewName()
        .environmentObject(AppViewModel())
}
```

### Issue 4: Colors Look Wrong

**Solution:**
```swift
// Use semantic colors, not system colors
// Before:
.foregroundColor(Color.primary) // This is system primary!

// After:
.foregroundColor(DesignTokens.Colors.textPrimary)
```

---

## Next Steps

1. **Fix Xcode References** (see `REORGANIZATION_GUIDE.md`)
2. **Start with Phase 1 views** (highest priority)
3. **Update one view at a time** (test thoroughly)
4. **Track progress** using the checklist above
5. **Test accessibility** for each updated view
6. **Iterate and improve** based on findings

---

## Support

- **Design System Documentation:** `DESIGN_SYSTEM.md`
- **UX/UI Audit:** `UX_UI_AUDIT_REPORT.md`
- **Architecture Guide:** `ARCHITECTURE.md`
- **Reorganization Guide:** `REORGANIZATION_GUIDE.md`

---

**Good luck with the implementation! The design system will significantly improve the app's consistency, accessibility, and user experience.** 🎨✨
