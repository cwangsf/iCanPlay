//
//  AuthManager.swift
//  iCanPlay
//
//  Created by Cynthia Wang on 10/25/25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

// Concurrency-safe actor that performs auth operations and side-effects.
// Keeps Firebase calls isolated and prevents data races when multiple async tasks run.
actor AuthManager {
    static let shared = AuthManager()

    private init() {}

    // Sign in anonymously if needed. Returns the uid on success.
    func signInAnonymouslyIfNeeded() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid {
            return uid
        }

        // Firebase Auth provides async API in recent SDKs; adjust if using older SDK.
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    // Sign out. This will throw if signOut fails.
    func signOut() async throws {
        try Auth.auth().signOut()
        // If you persist FCM tokens server-side, clear them here (call FirestoreService from a non-actor context or via Task).
    }

    // Optionally: fetch user profile from Firestore or create a minimal user doc
    func ensureUserDocumentExists(uid: String, displayName: String? = nil) async {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        do {
            // create or merge a minimal doc
            try await userRef.setData(["displayName": displayName ?? NSNull(), "createdAt": FieldValue.serverTimestamp()], merge: true)
        } catch {
            print("Failed to ensure user doc:", error)
        }
    }
}
