//
//  AuthViewModel.swift
//  iCanPlay
//
//  Created by Cynthia Wang on 10/25/25.
//


import Foundation
import Combine
import FirebaseAuth

// UI-facing view model for SwiftUI. Use @MainActor so @Published updates happen on the main thread.
@MainActor
final class AuthViewModel: ObservableObject {
    // Shared singleton for simple access across the app (optional)
    static let shared = AuthViewModel()

    @Published private(set) var isSignedIn: Bool = false
    @Published private(set) var uid: String?

    private var task: Task<Void, Never>? = nil

    private init() {
        // Optionally observe existing auth state when created
        if let currentUid = Auth.auth().currentUser?.uid {
            self.uid = currentUid
            self.isSignedIn = true
        }
    }

    deinit {
        task?.cancel()
    }

    // Public API for views to call
    func signInAnonymouslyIfNeeded() {
        // Launch an async task from the main actor
        task = Task { [weak self] in
            do {
                let uid = try await AuthManager.shared.signInAnonymouslyIfNeeded()
                // update UI state on main actor
                await MainActor.run {
                    self?.uid = uid
                    self?.isSignedIn = true
                }
                // Optionally ensure a user document exists (background)
                await AuthManager.shared.ensureUserDocumentExists(uid: uid)
            } catch {
                // Handle / surface error to UI as needed
                print("Auth sign-in failed:", error)
                await MainActor.run {
                    self?.isSignedIn = false
                }
            }
        }
    }

    func signOut() {
        task = Task { [weak self] in
            do {
                try await AuthManager.shared.signOut()
                await MainActor.run {
                    self?.uid = nil
                    self?.isSignedIn = false
                }
            } catch {
                print("Sign out failed:", error)
                // optionally surface error
            }
        }
    }
}
