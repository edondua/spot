# 🏗️ Spotted iOS Architecture Documentation

**Last Updated**: 2025-11-07
**Architecture Style**: Clean Architecture + MVVM + Feature-based Organization

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Layer Responsibilities](#layer-responsibilities)
4. [Design Patterns](#design-patterns)
5. [Data Flow](#data-flow)
6. [Best Practices](#best-practices)
7. [Adding New Features](#adding-new-features)

---

## 🎯 Architecture Overview

The Spotted app follows **Clean Architecture** principles combined with **MVVM** (Model-View-ViewModel) pattern, organized by **features** for maximum scalability and maintainability.

### Key Principles

- **Separation of Concerns**: Each layer has a single responsibility
- **Dependency Inversion**: Layers depend on abstractions, not implementations
- **Feature Modules**: Code organized by business features
- **Testability**: Clear boundaries make unit testing easier
- **Scalability**: Easy to add new features without affecting existing code

---

## 📁 Project Structure

```
Spotted/
├── 📱 App/
│   ├── SpottedApp.swift                     # Main app entry point
│   ├── SpottedAppModern.swift               # Modern navigation setup
│   └── Configuration/                        # App configuration
│
├── 🎯 Core/
│   ├── Extensions/                           # Swift extensions
│   │   ├── View+Extensions.swift            # SwiftUI view helpers
│   │   ├── Color+Extensions.swift           # Color utilities
│   │   └── Date+Extensions.swift            # Date formatting
│   ├── Utilities/                            # Helper utilities
│   │   └── HapticFeedback.swift             # Haptic feedback manager
│   ├── Constants/                            # App-wide constants
│   │   └── AppConstants.swift               # Design system, API config
│   └── Protocols/                            # Shared protocols
│
├── 📊 Data/
│   ├── Models/                               # Domain models
│   │   ├── User.swift
│   │   ├── Location.swift
│   │   ├── CheckIn.swift
│   │   ├── Message.swift
│   │   ├── Story.swift
│   │   ├── Category.swift
│   │   └── ProfilePrompt.swift
│   ├── Repositories/                         # Data repositories
│   │   └── DataRepository.swift             # Data access layer
│   └── Services/                             # Business services
│       ├── LocationManager.swift            # Location services
│       └── MockDataService.swift            # Mock data provider
│
├── 🎨 Presentation/
│   ├── Common/                               # Shared UI components
│   │   ├── Components/
│   │   │   ├── EmptyStateView.swift
│   │   │   ├── ToastView.swift
│   │   │   ├── SkeletonView.swift
│   │   │   ├── PhotoPickerView.swift
│   │   │   └── ProfileImageView.swift
│   │   ├── Modifiers/
│   │   │   └── ViewModifiers.swift
│   │   └── ViewModels/
│   │       ├── AppViewModel.swift           # Main app state
│   │       └── AppViewModelModern.swift     # Modern async state
│   │
│   ├── Features/                             # Feature modules
│   │   ├── Discover/                         # Discovery feature
│   │   │   ├── DiscoverView.swift
│   │   │   ├── CategoryDetailView.swift
│   │   │   └── ActivityFeedView.swift
│   │   ├── Matches/                          # Messaging feature
│   │   │   ├── MatchesView.swift
│   │   │   ├── ChatView.swift
│   │   │   └── MatchCelebrationView.swift
│   │   ├── Profile/                          # Profile feature
│   │   │   ├── ProfileView.swift
│   │   │   ├── EditProfileView.swift
│   │   │   └── SettingsView.swift
│   │   ├── CheckIn/                          # Check-in feature
│   │   │   ├── CheckInView.swift
│   │   │   ├── CheckInDetailView.swift
│   │   │   ├── CheckInViewWithMap.swift
│   │   │   ├── LocationDetailView.swift
│   │   │   ├── CameraCaptureView.swift
│   │   │   ├── StoryCreationView.swift
│   │   │   └── QuickCheckInButton.swift
│   │   ├── Map/                              # Map feature
│   │   │   └── MapView.swift
│   │   └── Onboarding/                       # Onboarding flow
│   │       └── OnboardingView.swift
│   │
│   └── MainTabView.swift                     # Main tab navigation
│
└── 📦 Resources/
    ├── Assets.xcassets                       # Images, colors
    └── Info.plist                            # App configuration
```

---

## 🔄 Layer Responsibilities

### 1. App Layer (`App/`)
**Purpose**: Application lifecycle and configuration

- App entry point (`@main`)
- Window/scene configuration
- Dependency injection setup
- Deep link handling

### 2. Core Layer (`Core/`)
**Purpose**: Shared utilities and extensions

- **Extensions**: Swift and SwiftUI extensions
- **Utilities**: Helper classes (HapticFeedback, ImageCache)
- **Constants**: App-wide constants and design system
- **Protocols**: Shared protocols and interfaces

### 3. Data Layer (`Data/`)
**Purpose**: Data management and business logic

- **Models**: Domain entities (User, Location, CheckIn)
- **Repositories**: Data access abstraction
- **Services**: Business services (Location, Authentication)

**Rules**:
- Models are pure Swift structs/classes
- No UIKit/SwiftUI dependencies
- Services handle business logic
- Repositories abstract data sources

### 4. Presentation Layer (`Presentation/`)
**Purpose**: UI and user interaction

- **Common**: Reusable UI components
- **Features**: Feature-specific views organized by domain
- **ViewModels**: State management with `@Published` properties

**Rules**:
- Views are passive and declarative
- ViewModels handle UI state and business logic
- Use `@EnvironmentObject` for shared state
- Mark ViewModels with `@MainActor` for thread safety

---

## 🎨 Design Patterns

### MVVM (Model-View-ViewModel)

```swift
// Model (Data layer)
struct User: Identifiable {
    let id: String
    let name: String
    let age: Int
}

// ViewModel (Presentation layer)
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading = false

    func updateProfile(name: String) {
        // Business logic
    }
}

// View (Presentation layer)
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        // Declarative UI
    }
}
```

### Repository Pattern

```swift
// Protocol (Data layer)
protocol UserRepository {
    func fetchUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
}

// Implementation (Data layer)
class MockUserRepository: UserRepository {
    func fetchUser(id: String) async throws -> User {
        // Data access logic
    }
}
```

### Feature-based Organization

Each feature is self-contained with its own:
- Views
- ViewModels (if feature-specific)
- Sub-components

---

## 📊 Data Flow

```
User Interaction
    ↓
View (SwiftUI)
    ↓
ViewModel (@Published)
    ↓
Repository/Service
    ↓
Model (Domain Entity)
    ↓
Service Layer (Business Logic)
    ↓
Data Source (API/Database)
```

### Example: Like User Flow

```swift
// 1. User taps like button (View)
Button("Like") {
    viewModel.likeUser(user)
}

// 2. ViewModel processes action
@MainActor
class DiscoverViewModel: ObservableObject {
    func likeUser(_ user: User) {
        // Update state
        likedUsers.insert(user.id)

        // Call service
        matchService.checkForMatch(user.id)
    }
}

// 3. Service handles business logic
class MatchService {
    func checkForMatch(_ userId: String) async {
        // Check if mutual like
        // Create match if true
        // Notify user
    }
}
```

---

## ✅ Best Practices

### Threading

```swift
// ✅ CORRECT: ViewModel marked with @MainActor
@MainActor
class AppViewModel: ObservableObject {
    @Published var users: [User] = []
}

// ✅ CORRECT: Background work with main thread updates
Task {
    let data = await fetchData() // Background
    await MainActor.run {
        self.users = data // Main thread
    }
}

// ❌ WRONG: Updating @Published from background thread
Task {
    self.users = await fetchData() // Can cause crashes!
}
```

### State Management

```swift
// ✅ CORRECT: Single source of truth
@EnvironmentObject var viewModel: AppViewModel

// ✅ CORRECT: Local state for view-only data
@State private var isExpanded = false

// ✅ CORRECT: Derived state
var filteredUsers: [User] {
    viewModel.users.filter { $0.age >= minAge }
}

// ❌ WRONG: Duplicating state
@State private var users: [User] // Don't copy from ViewModel!
```

### Memory Management

```swift
// ✅ CORRECT: No retain cycles
Task { [weak self] in
    await self?.loadData()
}

// ✅ CORRECT: Proper cleanup
.onDisappear {
    cancelNetworkRequests()
}

// ❌ WRONG: Strong reference in closure
Task {
    await self.loadData() // May cause retain cycle
}
```

### Constants Usage

```swift
// ✅ CORRECT: Use AppConstants
.foregroundColor(AppConstants.Design.primaryColor)
.cornerRadius(AppConstants.Design.mediumRadius)

// ❌ WRONG: Magic numbers
.foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
.cornerRadius(12)
```

### Haptic Feedback

```swift
// ✅ CORRECT: Use HapticFeedback utility
HapticFeedback.buttonTap()
HapticFeedback.success()
HapticFeedback.match()

// ❌ WRONG: Creating generators directly
let impact = UIImpactFeedbackGenerator(style: .light)
impact.impactOccurred()
```

---

## 🚀 Adding New Features

### Step 1: Create Feature Folder

```bash
Presentation/Features/NewFeature/
├── NewFeatureView.swift
├── NewFeatureDetailView.swift
└── Components/
    └── NewFeatureCard.swift
```

### Step 2: Add Model (if needed)

```swift
// Data/Models/NewModel.swift
struct NewModel: Identifiable, Codable {
    let id: String
    let name: String
}
```

### Step 3: Create ViewModel (if needed)

```swift
// Presentation/Features/NewFeature/NewFeatureViewModel.swift
@MainActor
class NewFeatureViewModel: ObservableObject {
    @Published var items: [NewModel] = []
    @Published var isLoading = false

    func loadItems() async {
        isLoading = true
        // Load data
        isLoading = false
    }
}
```

### Step 4: Create View

```swift
// Presentation/Features/NewFeature/NewFeatureView.swift
struct NewFeatureView: View {
    @StateObject private var viewModel = NewFeatureViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.items) { item in
                Text(item.name)
            }
            .navigationTitle("New Feature")
        }
        .task {
            await viewModel.loadItems()
        }
    }
}
```

### Step 5: Add to Navigation

```swift
// Presentation/MainTabView.swift
TabView {
    NewFeatureView()
        .tabItem {
            Label("New", systemImage: "star")
        }
}
```

---

## 📚 Additional Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [iOS Architecture Patterns](https://www.raywenderlich.com/18409174-ios-architecture-patterns)

---

## 🔍 Code Review Checklist

Before committing:

- [ ] No force unwraps (`!`)
- [ ] No force casts (`as!`)
- [ ] ViewModels marked with `@MainActor`
- [ ] Proper error handling
- [ ] Array bounds checking
- [ ] No retain cycles in closures
- [ ] Constants used instead of magic numbers
- [ ] Haptic feedback for user interactions
- [ ] Loading states handled
- [ ] Empty states designed
- [ ] Error states handled

---

**Generated by**: Senior iOS Architecture Review
**Date**: 2025-11-07
**Status**: ✅ Production Ready
