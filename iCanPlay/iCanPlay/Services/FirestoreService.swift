//
//  FirestoreService.swift
//  iCanPlay
//
//  Created by Cynthia Wang on 10/25/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    /// Saves the latest FCM token under users/{uid}.fcmToken
    /// - Note: Async so call from Task { await ... } or Task { ... }.
    func saveFCMToken(_ token: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("FirestoreService.saveFCMToken: no authenticated user")
            return
        }
        let data: [String: Any] = [
            "fcmToken": token,
            "fcmTokenUpdatedAt": FieldValue.serverTimestamp()
        ]
        do {
            try await db.collection("users").document(uid).setData(data, merge: true)
            print("Saved FCM token for uid: \(uid)")
        } catch {
            print("Failed to save FCM token:", error)
        }
    }

    // Minimal helper to create a match document (keeps parity with starter project).
    func createMatch(_ matchDict: [String: Any], id: String) async throws {
        try await db.collection("matches").document(id).setData(matchDict)
    }

    // Add other Firestore helpers here as needed...
}