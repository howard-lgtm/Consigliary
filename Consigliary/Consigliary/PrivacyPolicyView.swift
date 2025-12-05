import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Effective Date: December 5, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Introduction
                SectionView(
                    title: "Introduction",
                    content: "Consigliary, operated by HTDSTUDIO AB, is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application."
                )
                
                // Information We Collect
                SectionView(
                    title: "Information We Collect",
                    content: """
                    We may collect personal information that you voluntarily provide when you:
                    • Register for an account
                    • Use the App's features
                    • Upload contracts and documents
                    • Contact us for support
                    
                    This may include your name, email address, professional information, and documents you upload.
                    """
                )
                
                // How We Use Your Information
                SectionView(
                    title: "How We Use Your Information",
                    content: """
                    We use your information to:
                    • Process and analyze contracts using AI
                    • Generate split sheets and license agreements
                    • Track revenue and activity
                    • Provide customer support
                    • Improve the App and develop new features
                    """
                )
                
                // Data Security
                SectionView(
                    title: "Data Security",
                    content: """
                    We implement industry-standard security measures including:
                    • End-to-end encryption for sensitive data
                    • Secure HTTPS connections
                    • Regular security audits
                    • Access controls and authentication
                    • Encrypted data storage
                    """
                )
                
                // Your Privacy Rights
                SectionView(
                    title: "Your Privacy Rights",
                    content: """
                    You have the right to:
                    • Access and export your personal information
                    • Correct inaccurate information
                    • Request deletion of your data
                    • Opt-out of marketing communications
                    • Restrict how we use your information
                    """
                )
                
                // Third-Party Services
                SectionView(
                    title: "Third-Party Services",
                    content: """
                    We use third-party services for:
                    • AI-powered contract analysis (OpenAI)
                    • Payment processing (Apple Pay, Stripe)
                    • Cloud storage (AWS, iCloud)
                    • Analytics (anonymized data)
                    
                    These providers are contractually obligated to protect your data.
                    """
                )
                
                // Children's Privacy
                SectionView(
                    title: "Children's Privacy",
                    content: "Consigliary is not intended for users under 18 years of age. We do not knowingly collect information from children."
                )
                
                // Contact Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact Us")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("If you have questions about this Privacy Policy:")
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email: howard@htdstudio.net")
                        Text("HTDSTUDIO AB")
                        Text("Eskilsgatan 77")
                        Text("Eskilstuna, 633 56")
                        Text("SWEDEN")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                // Footer
                Text("© 2024 HTDSTUDIO AB. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
            .padding()
        }
        .background(Color.black)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
}
