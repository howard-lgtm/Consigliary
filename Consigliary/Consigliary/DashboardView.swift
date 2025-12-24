import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                SummaryView()
                    .tabItem {
                        Label("Summary", systemImage: "chart.bar.fill")
                    }
                    .tag(0)
                
                MonetizationView()
                    .tabItem {
                        Label("Revenue", systemImage: "dollarsign.circle.fill")
                    }
                    .tag(1)
                
                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person.fill")
                    }
                    .tag(2)
            }
            .accentColor(Color(hex: "32D74B"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
