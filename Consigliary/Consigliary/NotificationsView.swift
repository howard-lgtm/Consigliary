import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var pushNotifications = true
    @State private var emailAlerts = true
    @State private var threatDetection = true
    @State private var dealOpportunities = true
    @State private var revenueUpdates = false
    @State private var weeklyReports = true
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Push Notifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Push Notifications")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        ToggleRow(
                            icon: "bell.fill",
                            title: "Enable Push Notifications",
                            subtitle: "Receive alerts on your device",
                            isOn: $pushNotifications,
                            color: Color(hex: "32D74B")
                        )
                        
                        if pushNotifications {
                            VStack(spacing: 12) {
                                ToggleRow(
                                    icon: "shield.fill",
                                    title: "Threat Detection",
                                    subtitle: "Unauthorized use alerts",
                                    isOn: $threatDetection,
                                    color: Color(hex: "FF453A")
                                )
                                
                                ToggleRow(
                                    icon: "star.fill",
                                    title: "Deal Opportunities",
                                    subtitle: "New licensing opportunities",
                                    isOn: $dealOpportunities,
                                    color: Color(hex: "FFD60A")
                                )
                                
                                ToggleRow(
                                    icon: "dollarsign.circle.fill",
                                    title: "Revenue Updates",
                                    subtitle: "New revenue events",
                                    isOn: $revenueUpdates,
                                    color: Color(hex: "32D74B")
                                )
                            }
                            .padding(.leading, 20)
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Email Alerts Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Email Alerts")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        ToggleRow(
                            icon: "envelope.fill",
                            title: "Enable Email Alerts",
                            subtitle: "Receive updates via email",
                            isOn: $emailAlerts,
                            color: Color(hex: "64D2FF")
                        )
                        
                        if emailAlerts {
                            ToggleRow(
                                icon: "chart.bar.fill",
                                title: "Weekly Reports",
                                subtitle: "Summary of activity and revenue",
                                isOn: $weeklyReports,
                                color: Color(hex: "FFD60A")
                            )
                            .padding(.leading, 20)
                        }
                    }
                    
                    // Save Button
                    Button(action: {
                        let notification = UINotificationFeedbackGenerator()
                        notification.notificationOccurred(.success)
                        showingSaveAlert = true
                    }) {
                        Text("Save Preferences")
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
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Preferences Saved", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your notification preferences have been updated.")
            }
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "32D74B"))
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}
