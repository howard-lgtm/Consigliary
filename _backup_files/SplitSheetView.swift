import SwiftUI

struct SplitSheetView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) var dismiss
    
    @State private var trackTitle = ""
    @State private var contributors: [Contributor] = [
        Contributor(name: "Howard Duffy", role: "Producer", percentage: 50),
        Contributor(name: "", role: "Writer", percentage: 50)
    ]
    @State private var showingAddContributor = false
    @State private var showingSuccessAlert = false
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    
    var totalPercentage: Int {
        contributors.reduce(0) { $0 + $1.percentage }
    }
    
    var isValid: Bool {
        totalPercentage == 100 && !trackTitle.isEmpty && contributors.allSatisfy { !$0.name.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Split Sheet Creator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Define ownership percentages for your track")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Track Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Track Title")
                        .font(.headline)
                    
                    TextField("Enter track name", text: $trackTitle)
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(8)
                }
                
                // Contributors
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Contributors")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            contributors.append(Contributor(name: "", role: "Contributor", percentage: 0))
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "32D74B"))
                                .font(.title2)
                        }
                    }
                    
                    ForEach($contributors) { $contributor in
                        ContributorRow(contributor: $contributor, onDelete: {
                            if contributors.count > 1 {
                                contributors.removeAll { $0.id == contributor.id }
                            }
                        })
                    }
                }
                
                // Total Percentage
                HStack {
                    Text("Total")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(totalPercentage)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(totalPercentage == 100 ? Color(hex: "32D74B") : Color(hex: "FF453A"))
                }
                .padding()
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(8)
                
                if totalPercentage != 100 {
                    Text("Total must equal 100%")
                        .font(.caption)
                        .foregroundColor(Color(hex: "FF453A"))
                }
                
                // Generate Button
                Button(action: {
                    let splitSheet = appData.createSplitSheet(trackTitle: trackTitle, contributors: contributors)
                    
                    // Generate PDF
                    if let url = appData.generateSplitSheetPDF(for: splitSheet) {
                        pdfURL = url
                        showingShareSheet = true
                    } else {
                        showingSuccessAlert = true
                    }
                }) {
                    Text("Generate Split Sheet")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color(hex: "32D74B") : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!isValid)
            }
            .padding()
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Split Sheet Created!", isPresented: $showingSuccessAlert) {
            Button("Done") {
                dismiss()
            }
            Button("Create Another") {
                trackTitle = ""
                contributors = [
                    Contributor(name: "Howard Duffy", role: "Producer", percentage: 50),
                    Contributor(name: "", role: "Writer", percentage: 50)
                ]
            }
        } message: {
            Text("Split sheet for \"\(trackTitle)\" has been saved to your track database.")
        }
    }
}

struct ContributorRow: View {
    @Binding var contributor: Contributor
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Name", text: $contributor.name)
                    .textFieldStyle(.plain)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(Color(hex: "FF453A"))
                }
            }
            
            HStack {
                TextField("Role", text: $contributor.role)
                    .textFieldStyle(.plain)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        if contributor.percentage > 0 {
                            contributor.percentage -= 5
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(Color(hex: "64D2FF"))
                    }
                    
                    Text("\(contributor.percentage)%")
                        .font(.headline)
                        .frame(width: 60)
                    
                    Button(action: {
                        if contributor.percentage < 100 {
                            contributor.percentage += 5
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "32D74B"))
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(8)
    }
}

struct Contributor: Identifiable {
    let id = UUID()
    var name: String
    var role: String
    var percentage: Int
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = UIViewController()
        
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            // For iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = hostingController.view
                popover.sourceRect = CGRect(x: hostingController.view.bounds.midX, 
                                           y: hostingController.view.bounds.midY, 
                                           width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            hostingController.present(activityVC, animated: true)
        }
        
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update needed
    }
}
