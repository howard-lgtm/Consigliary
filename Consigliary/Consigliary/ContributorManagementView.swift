import SwiftUI

struct ContributorManagementView: View {
    let trackId: String
    let trackTitle: String
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var contributorService = ContributorService.shared
    
    @State private var contributors: [Contributor] = []
    @State private var splitSheet: SplitSheet?
    @State private var isLoading = false
    @State private var showingAddContributor = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            splitSummarySection
                            contributorsListSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Contributors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContributor = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "64D2FF"))
                    }
                }
            }
            .sheet(isPresented: $showingAddContributor) {
                AddContributorView(
                    trackId: trackId,
                    remainingSplit: splitSheet?.remainingSplitPercentage ?? 100.0,
                    onContributorAdded: {
                        Task {
                            await loadSplitSheet()
                        }
                    }
                )
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .task {
                await loadSplitSheet()
            }
        }
    }
    
    var splitSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(Color(hex: "64D2FF"))
                Text("Split Summary")
                    .font(.headline)
                Spacer()
            }
            
            if let splitSheet = splitSheet {
                VStack(spacing: 12) {
                    HStack {
                        Text("Track:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(splitSheet.track.title)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total Allocated:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(String(format: "%.1f", splitSheet.totalSplitPercentage))%")
                            .fontWeight(.semibold)
                            .foregroundColor(splitSheet.isComplete ? Color(hex: "32D74B") : .white)
                    }
                    
                    HStack {
                        Text("Remaining:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(String(format: "%.1f", splitSheet.remainingSplitPercentage))%")
                            .fontWeight(.semibold)
                            .foregroundColor(splitSheet.remainingSplitPercentage > 0 ? Color(hex: "FFD60A") : Color(hex: "32D74B"))
                    }
                    
                    if splitSheet.isComplete {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "32D74B"))
                            Text("Split sheet complete")
                                .font(.caption)
                                .foregroundColor(Color(hex: "32D74B"))
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(16)
    }
    
    var contributorsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(Color(hex: "64D2FF"))
                Text("Contributors")
                    .font(.headline)
                Spacer()
                Text("\(contributors.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if contributors.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No contributors yet")
                        .foregroundColor(.gray)
                    Text("Tap + to add contributors and define ownership splits")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(contributors) { contributor in
                    ContributorManagementRow(
                        contributor: contributor,
                        onDelete: {
                            deleteContributor(contributor)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(16)
    }
    
    func loadSplitSheet() async {
        isLoading = true
        do {
            let sheet = try await contributorService.getSplitSheet(trackId: trackId)
            splitSheet = sheet
            contributors = sheet.contributors
        } catch {
            errorMessage = "Failed to load contributors: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func deleteContributor(_ contributor: Contributor) {
        Task {
            do {
                try await contributorService.deleteContributor(id: contributor.id)
                await loadSplitSheet()
            } catch {
                errorMessage = "Failed to delete contributor: \(error.localizedDescription)"
            }
        }
    }
}

struct ContributorManagementRow: View {
    let contributor: Contributor
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(contributor.name)
                    .font(.headline)
                
                if let role = contributor.role, !role.isEmpty {
                    Text(role)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let email = contributor.email, !email.isEmpty {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(Color(hex: "64D2FF"))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(String(format: "%.1f", contributor.splitPercentage))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "32D74B"))
                
                if let pro = contributor.proAffiliation, !pro.isEmpty {
                    Text(pro)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(hex: "2C2C2E"))
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddContributorView: View {
    let trackId: String
    let remainingSplit: Double
    let onContributorAdded: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var contributorService = ContributorService.shared
    
    @State private var name = ""
    @State private var role = ""
    @State private var splitPercentage = ""
    @State private var email = ""
    @State private var proAffiliation = ""
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    let roleOptions = ["Producer", "Writer", "Composer", "Featured Artist", "Engineer", "Mixer", "Other"]
    let proOptions = ["ASCAP", "BMI", "SESAC", "GMR", "SOCAN", "PRS", "APRA", "Other", "None"]
    
    var isValid: Bool {
        !name.isEmpty && !splitPercentage.isEmpty && (Double(splitPercentage) ?? 0) > 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        infoSection
                        formSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Contributor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveContributor) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    var infoSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "64D2FF"))
                Text("Remaining Split: \(String(format: "%.1f", remainingSplit))%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            if remainingSplit <= 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "FF453A"))
                    Text("Split sheet is already complete at 100%")
                        .font(.caption)
                        .foregroundColor(Color(hex: "FF453A"))
                }
                .padding()
                .background(Color(hex: "FF453A").opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    var formSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Contributor Name *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("e.g., John Smith", text: $name)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Role")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Picker("Role", selection: $role) {
                    Text("Select Role").tag("")
                    ForEach(roleOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Split Percentage * (Max: \(String(format: "%.1f", remainingSplit))%)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("e.g., 25.0", text: $splitPercentage)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("contributor@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("PRO Affiliation")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Picker("PRO", selection: $proAffiliation) {
                    Text("Select PRO").tag("")
                    ForEach(proOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(12)
            }
        }
    }
    
    func saveContributor() {
        guard let split = Double(splitPercentage) else {
            errorMessage = "Invalid split percentage"
            return
        }
        
        if split > remainingSplit {
            errorMessage = "Split percentage exceeds remaining \(String(format: "%.1f", remainingSplit))%"
            return
        }
        
        isSaving = true
        
        Task {
            do {
                _ = try await contributorService.addContributor(
                    trackId: trackId,
                    name: name,
                    role: role.isEmpty ? nil : role,
                    splitPercentage: split,
                    email: email.isEmpty ? nil : email,
                    proAffiliation: proAffiliation.isEmpty ? nil : proAffiliation
                )
                
                await MainActor.run {
                    onContributorAdded()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to add contributor: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
}
