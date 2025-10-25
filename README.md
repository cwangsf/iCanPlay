```markdown
# RallyDoubles — SwiftUI Starter (Firebase + FCM wiring)

What this starter contains
- SwiftUI app skeleton (iOS 16+) using async/await and Combine-friendly patterns.
- AppDelegate-based FCM wiring: requests notification permissions, registers APNs token, obtains FCM token, persists token to Firestore.
- FirestoreService with async functions to persist FCM token and simple match creation / listener stubs.
- Minimal UI screens: Onboarding, Home, New Match, Match Detail.
- Cloud Function example to send push notifications when a match becomes confirmed.

Requirements
- Xcode 15+
- iOS target: iOS 16.0+ (recommended)
- A Firebase project with Firestore and Cloud Messaging enabled.
- APNs Auth Key (p8) uploaded to Firebase console.
- A real iOS device for push testing (push notifications do not work on Simulator).

Setup steps (quick)
1. Create a Firebase project at https://console.firebase.google.com/.
2. Add an iOS app to Firebase and download `GoogleService-Info.plist`. Place it into the Xcode app target (Add to project and ensure target membership).
3. Upload your APNs Auth Key (.p8) to Firebase Console → Project Settings → Cloud Messaging.
   - Save the Key ID and Team ID for your records.
4. Add Firebase SDK packages to Xcode via Swift Package Manager:
   - File → Add Packages... → https://github.com/firebase/firebase-ios-sdk
   - Select at least: FirebaseAuth, FirebaseCore, FirebaseFirestore, FirebaseMessaging
5. In Xcode target:
   - Set Bundle Identifier matching the Firebase iOS app entry.
   - Enable "Push Notifications" capability.
   - Optionally enable "Background Modes" → Remote notifications (if you plan to use silent notifications).
6. Run the app on a physical device. Accept notification permission when prompted.
7. Use Firebase Console or the included Cloud Function to send test notifications.

Notes and TODOs
- Current Auth uses anonymous sign-in for easy startup. Replace with Sign in with Apple for production:
  - Implement Apple authentication flow and link to Firebase Auth using OAuth provider.
- Contact picker and MapKit-based court selection are stubbed: implement CNContactPickerViewController and MapKit views where marked.
- The Firestore rules should be hardened before production. Start with developer rules for testing, then add security rules that allow only authenticated users to write their own fcmToken.
- Cloud Functions example included (functions/index.js). Deploy it under `functions` in your Firebase project.

Testing pushes
- Use Firebase Console → Cloud Messaging to send test notifications to a token.
- The app prints FCM token on successful registration — use that token to send test messages.
- Always test on a real device; Simulator cannot receive APNs push.

Cloud Function example
- See `functions/onMatchConfirmed/index.js` for a sample Firestore-triggered function that sends notifications to participant tokens when a match goes from awaiting -> confirmed.

If you'd like, next I can:
- Replace the anonymous auth with Sign in with Apple implementation and demo linking to Firebase Auth,
- Flesh out contact picking + MapKit screens,
- Add unit tests for the confirmation logic and Firestore security rules,
- Create a TestFlight-ready build checklist.

```
