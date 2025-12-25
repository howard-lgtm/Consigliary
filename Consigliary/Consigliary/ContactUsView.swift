import SwiftUI

struct ContactUsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTopic = "General Inquiry"
    @State private var name = "Jordan Davis"
    @State private var email = "jordan@example.com"
    @State private var subject = ""
    @State private var message = ""
    @State private var showingSuccessAlert = false
    
    let topics = [
        "General Inquiry",
        "Technical Support",
        "Billing Question",
        "Feature Request",
        "Bug Report",
        "Partnership Inquiry",
        "Other"
    ]
    
    var isValid: Bool {
        !subject.isEmpty && !message.isEmpty && message.count >= 10
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Get in Touch")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("We typically respond within 24 hours")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Quick Contact Options
                    VStack(spacing: 12) {
                        ContactOptionCard(
                            icon: "envelope.fill",
                            title: "Email",
                            subtitle: "info@htdstudio.net",
                            color: Color(hex: "64D2FF")
                        )
                        
                        ContactOptionCard(
                            icon: "message.fill",
                            title: "Live Chat",
                            subtitle: "Available Mon-Fri, 9am-5pm EST",
                            color: Color(hex: "32D74B")
                        )
                        
                        ContactOptionCard(
                            icon: "book.fill",
                            title: "Help Center",
                            subtitle: "Browse articles and guides",
                            color: Color(hex: "FFD60A")
                        )
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Contact Form
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Send us a message")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // Topic Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Topic")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(topics, id: \.self) { topic in
                                    Button(topic) {
                                        selectedTopic = topic
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedTopic)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(hex: "1C1C1E"))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Your name", text: $name)
                                .padding()
                                .background(Color(hex: "1C1C1E"))
                                .cornerRadius(12)
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("your@email.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(hex: "1C1C1E"))
                                .cornerRadius(12)
                        }
                        
                        // Subject
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subject")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Brief description of your inquiry", text: $subject)
                                .padding()
                                .background(Color(hex: "1C1C1E"))
                                .cornerRadius(12)
                        }
                        
                        // Message
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Message")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .topLeading) {
                                if message.isEmpty {
                                    Text("Tell us more about your inquiry...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                                
                                TextEditor(text: $message)
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(Color.clear)
                            }
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                            
                            Text("\(message.count) characters")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Submit Button
                        Button(action: {
                            let notification = UINotificationFeedbackGenerator()
                            notification.notificationOccurred(.success)
                            showingSuccessAlert = true
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Message")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? Color(hex: "32D74B") : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!isValid)
                    }
                    
                    // Additional Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Other Ways to Reach Us")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "building.2.fill", text: "HTDSTUDIO AB, Stockholm, Sweden")
                            InfoRow(icon: "clock.fill", text: "Mon-Fri: 9:00 AM - 5:00 PM EST")
                            InfoRow(icon: "globe", text: "www.consigliary.com")
                        }
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Message Sent!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for contacting us! We'll respond to your inquiry within 24 hours at \(email).")
            }
    }
}

struct ContactOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "64D2FF"))
                .font(.caption)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
