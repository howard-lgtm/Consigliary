import SwiftUI

struct BillingView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showingPaymentMethod = false
    @State private var showingUpgrade = false
    @State private var showingCancelSubscription = false
    
    let currentPlan = "Pro"
    let monthlyPrice = "$29"
    let nextBillingDate = "January 4, 2026"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Plan
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Plan")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(Color(hex: "FFD60A"))
                                        Text(currentPlan)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                    
                                    Text("\(monthlyPrice)/month")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showingUpgrade = true
                                }) {
                                    Text("Upgrade")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "32D74B"))
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12, corners: [.topLeft, .topRight])
                            
                            VStack(alignment: .leading, spacing: 12) {
                                FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited monitoring", color: Color(hex: "32D74B"))
                                FeatureRow(icon: "checkmark.circle.fill", text: "Automated takedowns", color: Color(hex: "32D74B"))
                                FeatureRow(icon: "checkmark.circle.fill", text: "AI contract analysis", color: Color(hex: "32D74B"))
                                FeatureRow(icon: "checkmark.circle.fill", text: "Priority support", color: Color(hex: "32D74B"))
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E").opacity(0.5))
                            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                        }
                    }
                    
                    // Billing Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Billing Information")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // Payment Method
                        Button(action: {
                            showingPaymentMethod = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "creditcard.fill")
                                    .foregroundColor(Color(hex: "64D2FF"))
                                    .font(.title3)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Payment Method")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("•••• •••• •••• 4242")
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
                        
                        // Next Billing Date
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.circle.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                                .font(.title3)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Next Billing Date")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(nextBillingDate)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                    }
                    
                    // Invoice History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Invoice History")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            InvoiceRow(date: "Dec 4, 2025", amount: "$29.00", status: "Paid")
                            InvoiceRow(date: "Nov 4, 2025", amount: "$29.00", status: "Paid")
                            InvoiceRow(date: "Oct 4, 2025", amount: "$29.00", status: "Paid")
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Cancel Subscription
                    Button(action: {
                        showingCancelSubscription = true
                    }) {
                        Text("Cancel Subscription")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "FF453A"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Billing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPaymentMethod) {
                PaymentMethodView()
            }
            .sheet(isPresented: $showingUpgrade) {
                UpgradePlanView()
            }
            .alert("Cancel Subscription", isPresented: $showingCancelSubscription) {
                Button("Keep Subscription", role: .cancel) { }
                Button("Cancel", role: .destructive) {
                    // Cancel subscription logic
                }
            } message: {
                Text("Are you sure you want to cancel your subscription? You'll lose access to Pro features at the end of your billing period.")
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

struct InvoiceRow: View {
    let date: String
    let amount: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(status)
                    .font(.caption)
                    .foregroundColor(Color(hex: "32D74B"))
            }
            
            Spacer()
            
            Text(amount)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct PaymentMethodView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Number")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("1234 5678 9012 3456", text: $cardNumber)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Expiry Date")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("MM/YY", text: $expiryDate)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CVV")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("123", text: $cvv)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    Button(action: {
                        let notification = UINotificationFeedbackGenerator()
                        notification.notificationOccurred(.success)
                        showingSuccess = true
                    }) {
                        Text("Update Payment Method")
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
            .navigationTitle("Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Payment Method Updated", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your payment method has been successfully updated.")
            }
        }
    }
}

struct UpgradePlanView: View {
    @Environment(\.dismiss) var dismiss
    
    let plans = [
        ("Basic", "$9", ["Basic monitoring", "Manual takedowns", "Email support"]),
        ("Pro", "$29", ["Unlimited monitoring", "Automated takedowns", "AI contract analysis", "Priority support"]),
        ("Enterprise", "$99", ["Everything in Pro", "Dedicated account manager", "Custom integrations", "White-label options"])
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(plans, id: \.0) { plan in
                        PlanCard(name: plan.0, price: plan.1, features: plan.2, isCurrent: plan.0 == "Pro")
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Upgrade Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlanCard: View {
    let name: String
    let price: String
    let features: [String]
    let isCurrent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(price)/month")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isCurrent {
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "32D74B"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "32D74B").opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "32D74B"))
                            .font(.caption)
                        
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if !isCurrent {
                Button(action: {
                    // Upgrade logic
                }) {
                    Text("Select Plan")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "32D74B"))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color(hex: "32D74B") : Color.clear, lineWidth: 2)
        )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
