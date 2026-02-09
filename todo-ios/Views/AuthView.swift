import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

struct AuthView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(isSignUp ? .newPassword : .password)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: handleAuth) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            
            Button(action: { isSignUp.toggle() }) {
                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .foregroundColor(.accentColor)
            }
            
            Divider()
            
            Button(action: handleMagicLink) {
                Text("Sign in with Magic Link")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignUp {
                    try await authService.signUp(email: email, password: password)
                } else {
                    try await authService.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func handleMagicLink() {
        guard !email.isEmpty else {
            errorMessage = "Please enter email"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signInWithMagicLink(email: email)
                errorMessage = "Check your email for the magic link"
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
