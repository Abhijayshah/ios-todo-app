import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var biometricService = BiometricAuthService.shared
    @StateObject private var calendarService = CalendarService.shared
    @StateObject private var storeKit = StoreKitManager.shared
    @State private var enableFaceID = false
    @State private var enableCalendar = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: PremiumView()) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text(storeKit.isPremium ? "Premium Active" : "Upgrade to Premium")
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Section(header: Text("Account")) {
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.circle")
                    }
                    
                    Button(role: .destructive) {
                        Task {
                            try? await AuthService.shared.signOut()
                            dismiss()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                Section(header: Text("General")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    
                    Toggle(isOn: $enableFaceID) {
                        Label("FaceID Lock", systemImage: "faceid")
                    }
                    .onChange(of: enableFaceID) { newValue in
                        if newValue {
                            biometricService.checkBiometryAvailability()
                        }
                    }
                    .disabled(!biometricService.isBiometryAvailable && !enableFaceID)
                    
                    Toggle(isOn: $enableCalendar) {
                        Label("Sync Calendar", systemImage: "calendar")
                    }
                    .onChange(of: enableCalendar) { newValue in
                        if newValue {
                            calendarService.requestAccess()
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                        .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                calendarService.checkAccess()
                enableCalendar = calendarService.isAccessGranted
            }
        }
    }
}

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if let avatarURL = authService.currentUser?.userMetadata["avatar_url"] as? String,
               let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                }
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(.top, 40)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.accentColor)
                    .padding(.top, 40)
            }
            
            VStack(spacing: 8) {
                Text(authService.currentUser?.email ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(authService.currentUser?.id.uuidString ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            List {
                Section(header: Text("Stats")) {
                    // In a real app, calculate these from TaskViewModel or TaskService
                    HStack {
                        Text("Tasks")
                        Spacer()
                        Text("Syncing...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Spacer()
        }
        .navigationTitle("Profile")
    }
}
