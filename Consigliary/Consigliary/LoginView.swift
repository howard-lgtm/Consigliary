import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Consigliary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Music Rights Management")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                }
                .padding()
                
                Spacer()
                
                Text("Test Credentials:\nEmail: test@consigliary.com\nPassword: password123")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Login")
        }
    }
    
    func login() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let user = try await AuthService.shared.login(email: email, password: password)
                print("✅ Login successful: \(user.name)")
                await MainActor.run {
                    // Create UserProfile from login response
                    let userProfile = UserProfile(
                        id: user.id,
                        email: user.email,
                        name: user.name,
                        artistName: user.artistName,
                        subscriptionPlan: user.subscriptionPlan,
                        artistType: nil,
                        genre: nil,
                        profileImageData: nil
                    )
                    appState.setUser(userProfile)
                    appState.isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
                print("❌ Login failed: \(error)")
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    LoginView()
}
