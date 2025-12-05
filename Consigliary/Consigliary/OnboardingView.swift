import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            icon: "shield.fill",
            title: "You're Always in Control",
            description: "AI handles the work, but you approve every action. Supervised autonomy means you're never locked out of decisions.",
            color: Color(hex: "32D74B")
        ),
        OnboardingPage(
            icon: "eye.fill",
            title: "24/7 Rights Monitoring",
            description: "We scan 2.3M+ tracks daily across TikTok, Instagram, YouTube, and more. Unauthorized use? We catch it instantly.",
            color: Color(hex: "64D2FF")
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "AI-Powered Intelligence",
            description: "Contract analysis, deal scouting, and rights protection—all powered by AI that gets smarter with every case.",
            color: Color(hex: "FFD60A")
        ),
        OnboardingPage(
            icon: "dollarsign.circle.fill",
            title: "Revenue Opportunities",
            description: "Turn unauthorized use into licensing deals. Our AI finds monetization opportunities you'd never spot manually.",
            color: Color(hex: "32D74B")
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        appState.hasCompletedOnboarding = true
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "32D74B"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text(page.description)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
