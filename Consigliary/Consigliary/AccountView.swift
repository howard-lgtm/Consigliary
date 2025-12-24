import SwiftUI

struct AccountView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var appState: AppState
    
    private var user: UserProfile? {
        appState.currentUser
    }
    
    var body: some View {
        List {
                Section {
                    HStack(spacing: 16) {
                        if let profileImageData = user?.profileImageData,
                           let uiImage = UIImage(data: profileImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color(hex: "32D74B"))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(user?.initials ?? "?")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user?.name ?? "User")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(user?.email ?? "No email")
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
                        Text(user?.subscriptionPlan.capitalized ?? "Free")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink(destination: BillingView()) {
                        Label("Billing", systemImage: "creditcard.fill")
                    }
                }
                .listRowBackground(Color(hex: "1C1C1E"))
                
                Section("Support") {
                    NavigationLink(destination: HelpCenterView()) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: ContactUsView()) {
                        Label("Contact Us", systemImage: "envelope.fill")
                    }
                }
                .listRowBackground(Color(hex: "1C1C1E"))
                
                Section("About") {
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
                        appState.logout()
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
            .frame(maxWidth: horizontalSizeClass == .regular ? 800 : .infinity)
            .frame(maxWidth: .infinity)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
    }
}
