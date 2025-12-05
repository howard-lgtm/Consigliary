import SwiftUI

@main
struct ConsigliaryApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appData)
                .preferredColorScheme(.dark)
        }
    }
}

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var isAuthenticated = false
}
