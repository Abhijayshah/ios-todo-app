import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                HomeView()
            } else {
                AuthView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
