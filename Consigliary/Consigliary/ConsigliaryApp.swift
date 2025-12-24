import SwiftUI
import Combine

@main
struct ConsigliaryApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appData = AppData()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                } else {
                    if appState.isAuthenticated {
                        ContentView()
                            .environmentObject(appState)
                            .environmentObject(appData)
                            .preferredColorScheme(.dark)
                    } else {
                        LoginView()
                            .environmentObject(appState)
                            .preferredColorScheme(.dark)
                    }
                }
            }
            .onAppear {
                // Show splash for 2 seconds on every launch
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var isAuthenticated = false
    @Published var isDemoMode = false
    @Published var currentUser: UserProfile?
    
    private let defaults = UserDefaults.standard
    private let userKey = "currentUser"
    
    init() {
        loadUserData()
        checkAuthStatus()
    }
    
    func setUser(_ user: UserProfile) {
        self.currentUser = user
        saveUserData()
    }
    
    func updateUser(name: String? = nil, email: String? = nil, artistName: String? = nil, artistType: String? = nil, genre: String? = nil, profileImageData: Data? = nil) {
        guard var user = currentUser else { return }
        
        if let name = name { user.name = name }
        if let email = email { user.email = email }
        if let artistName = artistName { user.artistName = artistName }
        if let artistType = artistType { user.artistType = artistType }
        if let genre = genre { user.genre = genre }
        if let profileImageData = profileImageData { user.profileImageData = profileImageData }
        
        self.currentUser = user
        saveUserData()
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        defaults.removeObject(forKey: userKey)
        KeychainManager.shared.clearAll()
    }
    
    private func saveUserData() {
        guard let user = currentUser else { return }
        if let encoded = try? JSONEncoder().encode(user) {
            defaults.set(encoded, forKey: userKey)
        }
    }
    
    private func loadUserData() {
        if let data = defaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.currentUser = user
        }
    }
    
    private func checkAuthStatus() {
        isAuthenticated = KeychainManager.shared.getAccessToken() != nil && currentUser != nil
    }
}

struct UserProfile: Codable {
    let id: String
    var email: String
    var name: String
    var artistName: String
    var subscriptionPlan: String
    var artistType: String?
    var genre: String?
    var profileImageData: Data?
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
}
