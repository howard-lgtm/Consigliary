import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Effective Date: December 5, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Acceptance of Terms
                TermsSectionView(
                    title: "Acceptance of Terms",
                    content: "By accessing or using Consigliary, you agree to be bound by these Terms of Service. If you do not agree, do not use the Service."
                )
                
                // Description of Service
                TermsSectionView(
                    title: "Description of Service",
                    content: """
                    Consigliary is an AI-powered platform designed to help musicians, producers, and music industry professionals:
                    • Analyze contracts and legal documents
                    • Generate split sheets and collaboration agreements
                    • Create license agreements
                    • Track revenue and activity
                    • Manage music business operations
                    
                    The Service is for informational purposes only and does not constitute legal, financial, or professional advice.
                    """
                )
                
                // User Accounts
                TermsSectionView(
                    title: "User Accounts",
                    content: """
                    To use certain features, you must create an account. You agree to:
                    • Provide accurate and complete information
                    • Maintain the security of your account credentials
                    • Notify us immediately of unauthorized access
                    • Be responsible for all activities under your account
                    """
                )
                
                // Subscription and Payments
                TermsSectionView(
                    title: "Subscription and Payments",
                    content: """
                    • Subscriptions are billed in advance on a recurring basis
                    • Fees are charged to your payment method on file
                    • Prices are subject to change with 30 days' notice
                    • All fees are non-refundable except as required by law
                    • You may cancel your subscription at any time
                    """
                )
                
                // AI and Automated Services
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI and Automated Services")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("IMPORTANT: The Service does NOT provide legal advice.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text("""
                    Our AI analysis is for informational purposes only and:
                    • May contain errors or inaccuracies
                    • Should be verified by qualified professionals
                    • Does not replace attorney review
                    
                    You are solely responsible for decisions made based on AI analysis.
                    """)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Acceptable Use
                TermsSectionView(
                    title: "Acceptable Use Policy",
                    content: """
                    You may NOT:
                    • Use the Service for illegal purposes
                    • Violate any laws or regulations
                    • Infringe on intellectual property rights
                    • Upload malicious code or viruses
                    • Attempt to hack or compromise our systems
                    • Harass, threaten, or harm other users
                    """
                )
                
                // Intellectual Property
                TermsSectionView(
                    title: "Intellectual Property",
                    content: """
                    The Service and all related content are owned by HTDSTUDIO AB and protected by copyright, trademark, patent, and trade secret laws.
                    
                    You retain ownership of all content you upload, but grant us a limited license to process your content to provide our services.
                    """
                )
                
                // Disclaimers
                VStack(alignment: .leading, spacing: 8) {
                    Text("Disclaimers")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("THE SERVICE IS PROVIDED \"AS IS\" WITHOUT WARRANTIES OF ANY KIND.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Text("""
                    We do not guarantee that:
                    • The Service will meet your requirements
                    • The Service will be uninterrupted or error-free
                    • Results will be accurate or reliable
                    • Defects will be corrected
                    """)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Limitation of Liability
                TermsSectionView(
                    title: "Limitation of Liability",
                    content: """
                    TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR:
                    • Indirect, incidental, or consequential damages
                    • Lost profits, revenue, or business opportunities
                    • Loss of data or information
                    • Damages exceeding the amount you paid us in the past 12 months
                    """
                )
                
                // Termination
                TermsSectionView(
                    title: "Termination",
                    content: """
                    We may suspend or terminate your access if you:
                    • Violate these Terms
                    • Engage in prohibited conduct
                    • Fail to pay required fees
                    • Pose a security or legal risk
                    
                    You may terminate your account at any time through the app settings.
                    """
                )
                
                // Contact Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact Us")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("For questions about these Terms:")
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email: info@htdstudio.net")
                        Text("Support: info@htdstudio.net")
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
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsSectionView: View {
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
        TermsOfServiceView()
    }
}
