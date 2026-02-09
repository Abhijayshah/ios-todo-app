import Foundation
import LocalAuthentication
import Combine

class BiometricAuthService: ObservableObject {
    static let shared = BiometricAuthService()
    
    @Published var isUnlocked = false
    @Published var isBiometryAvailable = false
    
    private init() {
        checkBiometryAvailability()
    }
    
    func checkBiometryAvailability() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometryAvailable = true
        } else {
            isBiometryAvailable = false
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your tasks"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // Fallback or error handling
                        print("Authentication failed")
                    }
                }
            }
        } else {
            // No biometrics, just unlock (or ask for passcode)
            self.isUnlocked = true
        }
    }
    
    func lock() {
        isUnlocked = false
    }
}

