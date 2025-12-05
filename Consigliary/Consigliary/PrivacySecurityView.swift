import SwiftUI

struct PrivacySecurityView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var twoFactorEnabled = false
    @State private var biometricEnabled = true
    @State private var showingPasswordChange = false
    @State private var showingDataExport = false
    @State private var showingDeleteAccount = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Security Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Security")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // Change Password
                        Button(action: {
                            showingPasswordChange = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(hex: "64D2FF"))
                                    .font(.title3)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Change Password")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Update your password")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                        
                        // Two-Factor Authentication
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                                .font(.title3)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Two-Factor Authentication")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("Add extra security layer")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $twoFactorEnabled)
                                .labelsHidden()
                                .tint(Color(hex: "32D74B"))
                        }
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                        
                        // Biometric Login
                        HStack(spacing: 12) {
                            Image(systemName: "faceid")
                                .foregroundColor(Color(hex: "32D74B"))
                                .font(.title3)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Face ID / Touch ID")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("Use biometrics to sign in")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $biometricEnabled)
                                .labelsHidden()
                                .tint(Color(hex: "32D74B"))
                        }
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Privacy Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // Data Export
                        Button(action: {
                            showingDataExport = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.down.doc.fill")
                                    .foregroundColor(Color(hex: "64D2FF"))
                                    .font(.title3)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Export Your Data")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Download all your data")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                        
                        // Privacy Policy
                        Button(action: {
                            // Open privacy policy
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Privacy Policy")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Read our privacy policy")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Danger Zone
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Danger Zone")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "FF453A"))
                        
                        Button(action: {
                            showingDeleteAccount = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(Color(hex: "FF453A"))
                                    .font(.title3)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Delete Account")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "FF453A"))
                                    
                                    Text("Permanently delete your account")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Privacy & Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPasswordChange) {
                PasswordChangeView()
            }
            .alert("Export Data", isPresented: $showingDataExport) {
                Button("Cancel", role: .cancel) { }
                Button("Export") {
                    // Export data logic
                }
            } message: {
                Text("Your data will be exported as a ZIP file and sent to your email address.")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccount) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Delete account logic
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
            }
        }
    }
}

struct PasswordChangeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        SecureField("Enter current password", text: $currentPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        SecureField("Enter new password", text: $newPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm New Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        SecureField("Confirm new password", text: $confirmPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    Button(action: {
                        let notification = UINotificationFeedbackGenerator()
                        notification.notificationOccurred(.success)
                        showingSuccess = true
                    }) {
                        Text("Update Password")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "32D74B"))
                            .cornerRadius(12)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Password Updated", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your password has been successfully updated.")
            }
        }
    }
}
