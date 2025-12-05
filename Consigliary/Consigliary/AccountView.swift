import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color(hex: "32D74B"))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("HD")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Howard Duffy")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("howard@htdstudio.net")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color(hex: "1C1C1E"))
                
                Section("Settings") {
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.fill")
                    }
                    
                    NavigationLink(destination: NotificationsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink(destination: PrivacySecurityView()) {
                        Label("Privacy & Security", systemImage: "lock.fill")
                    }
                }
                .listRowBackground(Color(hex: "1C1C1E"))
                
                Section("Subscription") {
                    HStack {
                        Label("Plan", systemImage: "star.fill")
                        Spacer()
                        Text("Pro")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink(destination: BillingView()) {
                        Label("Billing", systemImage: "creditcard.fill")
                    }
                }
                .listRowBackground(Color(hex: "1C1C1E"))
                
                Section("Support") {
                    NavigationLink(destination: Text("Help Center")) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: Text("Contact Us")) {
                        Label("Contact Us", systemImage: "envelope.fill")
                    }
                }
                .listRowBackground(Color(hex: "1C1C1E"))
                
                Section("About") {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                    
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0 (Build 1)")
                            .foregroundColor(.gray)
                    }
                }
                .listRowBackground(Color(hex: "1C1C1E"))
                
                Section {
                    Button(action: {
                        appState.hasCompletedOnboarding = false
                    }) {
                        HStack {
                            Label("Sign Out", systemImage: "arrow.right.square.fill")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color(hex: "1C1C1E"))
            }
            .background(Color.black)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
