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
}
