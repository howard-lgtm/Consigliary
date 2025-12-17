import SwiftUI

struct VerificationView: View {
    @StateObject private var verificationService = VerificationService.shared
    @State private var verifications: [Verification] = []
    @State private var isLoading = false
    @State private var showingAddVerification = false
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
                            headerSection
                            
                            if verifications.isEmpty {
                                emptyStateSection
                            } else {
                                verificationsListSection
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Verifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddVerification = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "64D2FF"))
                    }
                }
            }
            .sheet(isPresented: $showingAddVerification) {
                AddVerificationView(onVerificationAdded: {
                    Task {
                        await loadVerifications()
                    }
                })
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .task {
                await loadVerifications()
            }
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(Color(hex: "32D74B"))
                    .font(.system(size: 48))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Track Verification")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Monitor unauthorized use")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Text("Submit YouTube, TikTok, or Instagram URLs to check if your tracks are being used without permission")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(16)
    }
    
    var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Verifications Yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Start monitoring your tracks by submitting video URLs from social media platforms")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAddVerification = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Verification")
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .background(Color(hex: "64D2FF"))
                .cornerRadius(12)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    var verificationsListSection: some View {
        VStack(spacing: 12) {
            ForEach(verifications) { verification in
                VerificationCard(
                    verification: verification,
                    onDelete: {
                        deleteVerification(verification)
                    },
                    onStatusChange: { status in
                        updateStatus(verification, status: status)
                    }
                )
            }
        }
    }
    
    func loadVerifications() async {
        isLoading = true
        do {
            verifications = try await verificationService.getVerifications()
        } catch {
            errorMessage = "Failed to load verifications: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func deleteVerification(_ verification: Verification) {
        Task {
            do {
                try await verificationService.deleteVerification(id: verification.id)
                await loadVerifications()
            } catch {
                errorMessage = "Failed to delete verification: \(error.localizedDescription)"
            }
        }
    }
    
    func updateStatus(_ verification: Verification, status: String) {
        Task {
            do {
                _ = try await verificationService.updateVerificationStatus(id: verification.id, status: status)
                await loadVerifications()
            } catch {
                errorMessage = "Failed to update status: \(error.localizedDescription)"
            }
        }
    }
}

struct VerificationCard: View {
    let verification: Verification
    let onDelete: () -> Void
    let onStatusChange: (String) -> Void
    
    var statusColor: Color {
        switch verification.status {
        case "confirmed": return Color(hex: "FF453A")
        case "disputed": return Color(hex: "FFD60A")
        case "dismissed": return Color.gray
        default: return Color(hex: "64D2FF")
        }
    }
    
    var statusIcon: String {
        switch verification.status {
        case "confirmed": return "exclamationmark.triangle.fill"
        case "disputed": return "questionmark.circle.fill"
        case "dismissed": return "xmark.circle.fill"
        default: return "clock.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: platformIcon(verification.platform))
                    .foregroundColor(Color(hex: "64D2FF"))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(verification.platform)
                        .font(.headline)
                    
                    if let videoTitle = verification.videoTitle {
                        Text(videoTitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                    Text(verification.status.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                }
            }
            
            if let channelName = verification.channelName {
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.gray)
                    Text(channelName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if let trackTitle = verification.trackTitle {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(Color(hex: "BF5AF2"))
                    Text(trackTitle)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                Button(action: {
                    if let url = URL(string: verification.videoUrl) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                        Text("View Video")
                    }
                    .font(.caption)
                    .foregroundColor(Color(hex: "64D2FF"))
                }
                
                Spacer()
                
                Menu {
                    Button("Pending") {
                        onStatusChange("pending")
                    }
                    Button("Confirmed") {
                        onStatusChange("confirmed")
                    }
                    Button("Disputed") {
                        onStatusChange("disputed")
                    }
                    Button("Dismissed") {
                        onStatusChange("dismissed")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "ellipsis.circle")
                        Text("Status")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func platformIcon(_ platform: String) -> String {
        switch platform.lowercased() {
        case "youtube": return "play.rectangle.fill"
        case "tiktok": return "music.note"
        case "instagram": return "camera.fill"
        default: return "video.fill"
        }
    }
}

struct AddVerificationView: View {
    let onVerificationAdded: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var verificationService = VerificationService.shared
    @StateObject private var trackService = TrackService.shared
    
    @State private var videoUrl = ""
    @State private var selectedTrackId: String?
    @State private var tracks: [TrackService.Track] = []
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var isValid: Bool {
        !videoUrl.isEmpty && isValidUrl(videoUrl)
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
            .navigationTitle("Add Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: submitVerification) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Submit")
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
            .task {
                await loadTracks()
            }
        }
    }
    
    var infoSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "64D2FF"))
                Text("Supported Platforms")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                platformRow(icon: "play.rectangle.fill", name: "YouTube", example: "youtube.com/watch?v=...")
                platformRow(icon: "music.note", name: "TikTok", example: "tiktok.com/@user/video/...")
                platformRow(icon: "camera.fill", name: "Instagram", example: "instagram.com/p/...")
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(16)
    }
    
    func platformRow(icon: String, name: String, example: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "64D2FF"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(example)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    var formSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Video URL *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Paste YouTube, TikTok, or Instagram URL", text: $videoUrl)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Track to Verify Against (Optional)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Picker("Select Track", selection: $selectedTrackId) {
                    Text("Any of my tracks").tag(nil as String?)
                    ForEach(tracks) { track in
                        Text(track.title).tag(track.id)
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
    
    func loadTracks() async {
        do {
            tracks = try await trackService.getTracks()
        } catch {
            print("Failed to load tracks: \(error)")
        }
    }
    
    func submitVerification() {
        isSaving = true
        
        Task {
            do {
                _ = try await verificationService.createVerification(
                    videoUrl: videoUrl,
                    trackId: selectedTrackId
                )
                
                await MainActor.run {
                    onVerificationAdded()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to submit verification: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
    
    func isValidUrl(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return url.scheme != nil && url.host != nil
    }
}
