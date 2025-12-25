import SwiftUI

struct LicenseAgreementView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var trackTitle = ""
    @State private var licenseeType = "Sync License"
    @State private var licenseeName = ""
    @State private var licenseFee = "250"
    @State private var territory = "Worldwide"
    @State private var duration = "Perpetual"
    @State private var exclusivity = false
    @State private var showingPreview = false
    @State private var showingPDFPreview = false
    @State private var pdfURL: URL?
    
    let licenseTypes = ["Sync License", "Master License", "Mechanical License", "Performance License"]
    let territories = ["Worldwide", "North America", "United States", "Europe", "Asia", "Custom"]
    let durations = ["Perpetual", "1 Year", "2 Years", "5 Years", "Custom"]
    
    var isValid: Bool {
        !trackTitle.isEmpty && !licenseeName.isEmpty && !licenseFee.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("License Agreement")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Generate professional license agreements for your music")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // License Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("License Type")
                        .font(.headline)
                    
                    Menu {
                        ForEach(licenseTypes, id: \.self) { type in
                            Button(type) {
                                licenseeType = type
                            }
                        }
                    } label: {
                        HStack {
                            Text(licenseeType)
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
                
                // Track Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Track Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Track Title")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("Enter track name", text: $trackTitle)
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(8)
                    }
                }
                
                // Licensee Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Licensee Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Licensee Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("Company or individual name", text: $licenseeName)
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(8)
                    }
                }
                
                // License Terms
                VStack(alignment: .leading, spacing: 16) {
                    Text("License Terms")
                        .font(.headline)
                    
                    // License Fee
                    VStack(alignment: .leading, spacing: 8) {
                        Text("License Fee (USD)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("Amount", text: $licenseFee)
                                .keyboardType(.numberPad)
                        }
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(8)
                    }
                    
                    // Territory
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Territory")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(territories, id: \.self) { territoryOption in
                                Button(territoryOption) {
                                    territory = territoryOption
                                }
                            }
                        } label: {
                            HStack {
                                Text(territory)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(durations, id: \.self) { durationOption in
                                Button(durationOption) {
                                    duration = durationOption
                                }
                            }
                        } label: {
                            HStack {
                                Text(duration)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Exclusivity Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exclusive License")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Grant exclusive rights to licensee")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $exclusivity)
                            .labelsHidden()
                            .tint(Color(hex: "32D74B"))
                    }
                    .padding()
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(8)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        generateLicense()
                    }) {
                        Text("Generate License Agreement")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? Color(hex: "32D74B") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isValid)
                    
                    Button(action: {
                        showingPreview = true
                    }) {
                        Text("Preview Template")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "64D2FF").opacity(0.2))
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPDFPreview) {
            if let url = pdfURL {
                GeneratedLicensePDFView(pdfURL: url)
            }
        }
        .sheet(isPresented: $showingPreview) {
            LicensePreviewView(
                licenseeType: licenseeType,
                trackTitle: trackTitle.isEmpty ? "Your Track" : trackTitle,
                licenseeName: licenseeName.isEmpty ? "Licensee Name" : licenseeName,
                licenseFee: licenseFee.isEmpty ? "0" : licenseFee,
                territory: territory,
                duration: duration,
                exclusivity: exclusivity
            )
        }
    }
    
    func generateLicense() {
        guard let fee = Double(licenseFee) else { return }
        
        let licenseData = LicenseAgreementData(
            trackName: trackTitle,
            platform: licenseeType,
            userName: licenseeName,
            licenseFee: fee,
            artistName: "Howard Duffy",
            date: Date()
        )
        
        if let url = LicenseAgreementPDFGenerator.generatePDF(for: licenseData) {
            pdfURL = url
            showingPDFPreview = true
        }
    }
}

struct LicensePreviewView: View {
    @Environment(\.dismiss) var dismiss
    let licenseeType: String
    let trackTitle: String
    let licenseeName: String
    let licenseFee: String
    let territory: String
    let duration: String
    let exclusivity: Bool
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MUSIC LICENSE AGREEMENT")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Preview")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Agreement Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "License Type", value: licenseeType)
                        DetailRow(label: "Track", value: trackTitle)
                        DetailRow(label: "Licensee", value: licenseeName)
                        DetailRow(label: "License Fee", value: "$\(licenseFee)")
                        DetailRow(label: "Territory", value: territory)
                        DetailRow(label: "Duration", value: duration)
                        DetailRow(label: "Exclusivity", value: exclusivity ? "Exclusive" : "Non-Exclusive")
                    }
                    
                    Divider()
                    
                    // Sample Terms
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Grant of Rights")
                            .font(.headline)
                        
                        Text("The Artist hereby grants the Licensee a \(exclusivity ? "exclusive" : "non-exclusive"), \(territory.lowercased()) license to use the musical composition \"\(trackTitle)\" for the duration of \(duration.lowercased()).")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment Terms")
                            .font(.headline)
                        
                        Text("The Licensee agrees to pay the Artist a one-time license fee of $\(licenseFee) USD. Payment is due within 30 days of this agreement.")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("License Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(8)
    }
}
