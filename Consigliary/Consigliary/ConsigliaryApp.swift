import SwiftUI
import Combine

@main
struct ConsigliaryApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
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
}

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var isAuthenticated = false
    @Published var isDemoMode = false
}
