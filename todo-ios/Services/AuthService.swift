// To enable Supabase, add https://github.com/supabase-community/supabase-swift as a Swift Package and remove the fallback.
import Foundation
import Combine
#if canImport(Supabase)
import Supabase
#endif

#if canImport(Supabase)
class AuthService: ObservableObject {
    static let shared = AuthService()
    private let client = SupabaseManager.shared.client
    
    @Published var session: Session?
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private init() {
        // Check for existing session
        Task {
            await checkSession()
        }
        
        // Listen for auth changes
        Task {
            for await _ in client.auth.authStateChanges {
                await checkSession()
            }
        }
    }
    
    @MainActor
    func checkSession() async {
        do {
            self.session = try await client.auth.session
            self.currentUser = session?.user
            self.isAuthenticated = (session != nil)
        } catch {
            self.session = nil
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }
    
    func signInWithMagicLink(email: String) async throws {
        try await client.auth.signInWithOTP(email: email)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // Helper to get current user ID
    var currentUserId: UUID? {
        currentUser?.id
    }
}
#endif
#if !canImport(Supabase)
import Combine
import SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    @Published var session: Any?
    @Published var currentUser: (id: UUID, email: String)?
    @Published var isAuthenticated = false

    private init() {}

    @MainActor
    func checkSession() async { }
    func signUp(email: String, password: String) async throws { throw NSError(domain: "AuthUnavailable", code: 1) }
    func signIn(email: String, password: String) async throws { throw NSError(domain: "AuthUnavailable", code: 1) }
    func signInWithMagicLink(email: String) async throws { throw NSError(domain: "AuthUnavailable", code: 1) }
    func signOut() async throws { }
    var currentUserId: UUID? { currentUser?.id }
}
#endif


