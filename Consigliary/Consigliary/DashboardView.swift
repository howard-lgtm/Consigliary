import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "bell.fill")
                }
                .tag(1)
            
            MonetizationView()
                .tabItem {
                    Label("Revenue", systemImage: "dollarsign.circle.fill")
                }
                .tag(2)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "32D74B"))
    }
}
