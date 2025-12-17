import SwiftUI

struct ActivityView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        ScrollView {
                VStack(spacing: 16) {
                    if appData.activities.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "32D74B"))
                            
                            Text("All Clear!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("No unauthorized use detected")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
                        ForEach(appData.activities) { activity in
                            ActivityCard(activity: activity)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black)
            .frame(maxWidth: horizontalSizeClass == .regular ? 1000 : .infinity)
            .frame(maxWidth: .infinity)
            .navigationTitle("Live Activity")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct ActivityCard: View {
    @EnvironmentObject var appData: AppData
    let activity: Activity
    
    @State private var showingTakedownAlert = false
    @State private var showingLicenseSheet = false
    @State private var licenseAmount = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(activity.platform)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "64D2FF"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "64D2FF").opacity(0.2))
                    .cornerRadius(6)
                
                Spacer()
                
                Text(activity.timestamp)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 12) {
                Text(activity.thumbnail)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unauthorized Use Detected")
                        .font(.headline)
                    
                    Text("Track: \"\(activity.track)\"")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Artist: \(activity.artist)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showingTakedownAlert = true
                }) {
                    Text("Takedown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "32D74B"))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    showingLicenseSheet = true
                }) {
                    Text("License")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "64D2FF"))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    withAnimation {
                        appData.handleIgnore(activity)
                    }
                }) {
                    Text("Ignore")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
        .alert("Takedown Initiated", isPresented: $showingTakedownAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
                withAnimation {
                    appData.handleTakedown(activity)
                }
            }
        } message: {
            Text("DMCA notice will be sent to \(activity.platform) for \"\(activity.track)\" by \(activity.artist)")
        }
        .sheet(isPresented: $showingLicenseSheet) {
            LicenseSheet(
                activity: activity,
                onLicense: { amount, pdfURL in
                    withAnimation {
                        // PDF generation is handled in the sheet
                    }
                }
            )
        }
    }
}

struct LicenseSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appData: AppData
    let activity: Activity
    let onLicense: (Double, URL?) -> Void
    
    @State private var licenseAmount = "250"
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    @State private var pendingAmount: Double?
    
    var body: some View {
        NavigationView {
            Form {
                Section("License Details") {
                    HStack {
                        Text("Track")
                        Spacer()
                        Text(activity.track)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Platform")
                        Spacer()
                        Text(activity.platform)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("User")
                        Spacer()
                        Text(activity.artist)
                            .foregroundColor(.gray)
                    }
                }
                
                Section("License Fee") {
                    HStack {
                        Text("$")
                        TextField("Amount", text: $licenseAmount)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section {
                    Button("Create License Agreement") {
                        if let amount = Double(licenseAmount) {
                            // Generate PDF without removing activity
                            if let url = appData.generateLicensePDF(activity, amount: amount) {
                                print("✅ PDF generated at: \(url)")
                                print("📄 File exists: \(FileManager.default.fileExists(atPath: url.path))")
                                pdfURL = url
                                pendingAmount = amount
                                showingShareSheet = true
                            } else {
                                print("❌ Failed to generate PDF")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(hex: "64D2FF"))
                }
            }
            .navigationTitle("License Agreement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("License Agreement Created!", isPresented: $showingShareSheet) {
                Button("Complete License") {
                    if let amount = pendingAmount {
                        appData.completeLicense(activity, amount: amount)
                        onLicense(amount, pdfURL)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    showingShareSheet = false
                }
            } message: {
                if let url = pdfURL {
                    Text("✅ License Agreement Generated!\n\nFile: \(url.lastPathComponent)\n\n📂 Access your PDF:\nFiles app → Browse → On My iPhone → Consigliary\n\nYou can now view, share, or AirDrop the license agreement.")
                }
            }
    }
}

// MARK: - Activity View Controller
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
