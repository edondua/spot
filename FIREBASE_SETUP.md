# Firebase Setup Guide for Spotted

This guide explains how to integrate Firebase into the Spotted app.

## Prerequisites

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Register your iOS app with bundle ID: `com.spotted.app` (or your actual bundle ID)
3. Download `GoogleService-Info.plist`

## Step 1: Add Firebase SDK

### Option A: Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies**
2. Add Firebase SDK:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Select these products:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseStorage`
   - `FirebaseMessaging`
   - `FirebaseAnalytics` (optional)
   - `FirebaseCrashlytics` (optional)

### Option B: CocoaPods

Add to `Podfile`:
```ruby
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
```

Then run:
```bash
pod install
```

## Step 2: Add GoogleService-Info.plist

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to the project root (same level as `Info.plist`)
3. Ensure it's added to the app target

## Step 3: Initialize Firebase

In `SpottedApp.swift` or `AppDelegate.swift`, add:

```swift
import Firebase

@main
struct SpottedApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Step 4: Configure Firestore Database

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
    }
    
    // Check-ins collection
    match /checkIns/{checkInId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isOwner(resource.data.userId);
    }
    
    // Matches collection
    match /matches/{matchId} {
      allow read: if isSignedIn() && 
        request.auth.uid in resource.data.users;
      allow create: if isSignedIn();
    }
    
    // Conversations collection
    match /conversations/{conversationId} {
      allow read, write: if isSignedIn() && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read: if isSignedIn() && 
          request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
        allow create: if isSignedIn() && 
          request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
      }
    }
  }
}
```

### Indexes

Create composite indexes for:
- `checkIns`: `(userId, timestamp)` descending
- `messages`: `(conversationId, timestamp)` descending
- `users`: `(location.geohash, lastActive)` for location queries

## Step 5: Configure Firebase Storage

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile photos
    match /users/{userId}/photos/{photoId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Stories
    match /stories/{storyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Voice memos
    match /voice/{voiceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 6: Enable Authentication Methods

In Firebase Console → Authentication → Sign-in method:

1. **Email/Password** - Enable
2. **Apple** - Enable and configure:
   - Add your App ID
   - Configure Sign in with Apple capability in Xcode
   - Add required entitlements

## Step 7: Set Up Cloud Messaging (Push Notifications)

1. **Upload APNs Certificate/Key**:
   - Go to Project Settings → Cloud Messaging
   - Upload your APNs Authentication Key or Certificate

2. **Add Capabilities in Xcode**:
   - Background Modes: Remote notifications
   - Push Notifications

3. **Update AppDelegate**:

```swift
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, 
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("FCM Token: \(fcmToken)")
        
        // Save to user profile in Firestore
        Task {
            try? await FirebaseService.shared.messaging.saveFCMToken(fcmToken, userId: currentUserId)
        }
    }
}
```

## Step 8: Implement Backend Services

### Update FirebaseService.swift

Uncomment all `// TODO:` sections in:
- `FirebaseAuthService`
- `FirebaseDatabaseService`
- `FirebaseStorageService`
- `FirebaseMessagingService`

### Key Implementations:

1. **Authentication**: Replace mock implementations with actual Firebase Auth calls
2. **Database**: Implement Firestore queries with real-time listeners
3. **Storage**: Implement file upload/download
4. **Messaging**: Implement FCM token management

## Step 9: Set Up Cloud Functions (Optional but Recommended)

Create Cloud Functions for:

### 1. Send Push Notifications

```javascript
exports.sendMatchNotification = functions.firestore
  .document('matches/{matchId}')
  .onCreate(async (snap, context) => {
    const match = snap.data();
    const [user1, user2] = match.users;
    
    // Get FCM tokens and send notifications
    // ...
  });
```

### 2. Clean Up Old Stories

```javascript
exports.cleanupOldStories = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const cutoff = Date.now() - (24 * 60 * 60 * 1000);
    // Delete stories older than 24 hours
  });
```

### 3. Update User Activity Status

```javascript
exports.updateLastActive = functions.firestore
  .document('checkIns/{checkInId}')
  .onWrite(async (change, context) => {
    // Update user's lastActive timestamp
  });
```

## Step 10: Update Analytics Integration

In `AnalyticsManager.swift`, uncomment Firebase Analytics calls:

```swift
import FirebaseAnalytics

func track(_ event: Event) {
    guard isEnabled else { return }
    
    let eventName = eventDescription(for: event)
    let properties = eventProperties(for: event)
    
    // Firebase Analytics
    Analytics.logEvent(eventName, parameters: properties)
    
    // OSLog for debugging
    logger.info("📊 Event: \(eventName)")
}
```

## Step 11: Testing

1. **Test Authentication**:
   - Sign up with email/password
   - Sign in with Apple
   - Password reset

2. **Test Database**:
   - Create user profile
   - Create check-in
   - Send messages
   - Real-time updates

3. **Test Storage**:
   - Upload profile photos
   - Upload stories
   - Upload voice memos

4. **Test Push Notifications**:
   - Match notifications
   - Message notifications
   - Check-in notifications

## Firestore Data Structure

```
users/{userId}
  - name: string
  - age: number
  - bio: string
  - photos: array
  - interests: array
  - currentCheckIn: object
  - fcmToken: string
  - lastActive: timestamp

checkIns/{checkInId}
  - userId: string
  - location: object
  - timestamp: timestamp
  - caption: string

matches/{matchId}
  - users: array[userId1, userId2]
  - timestamp: timestamp
  - location: object

conversations/{conversationId}
  - participants: array[userId1, userId2]
  - lastMessage: object
  - updatedAt: timestamp
  
  messages/{messageId}
    - senderId: string
    - text: string
    - timestamp: timestamp
    - type: string
    - status: string

friendRequests/{requestId}
  - fromUserId: string
  - toUserId: string
  - status: string
  - timestamp: timestamp
```

## Environment Variables

Consider using different Firebase projects for development and production:

1. Create `GoogleService-Info-Dev.plist`
2. Create `GoogleService-Info-Prod.plist`
3. Use build configurations to switch between them

## Cost Optimization

1. **Enable Firebase Emulator Suite** for local development
2. **Set up budget alerts** in Google Cloud Console
3. **Optimize queries** - use indexes and limit results
4. **Implement pagination** for large collections
5. **Cache frequently accessed data** locally
6. **Use Cloud Functions** for expensive operations

## Security Checklist

- [ ] Firestore security rules configured
- [ ] Storage security rules configured
- [ ] Email verification enabled
- [ ] Rate limiting on authentication
- [ ] Input validation on all writes
- [ ] Sensitive data encrypted
- [ ] User data can be deleted (GDPR compliance)
- [ ] Audit logging enabled

## Next Steps

1. Set up Firebase project
2. Install SDK dependencies
3. Add GoogleService-Info.plist
4. Initialize Firebase in app
5. Implement authentication first
6. Then database operations
7. Then storage
8. Finally push notifications

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/data-model)
- [Cloud Functions](https://firebase.google.com/docs/functions)
