import SwiftUI

struct AddTrackView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appData: AppData
    
    var editingTrack: Track?
    
    @State private var trackTitle = ""
    @State private var artistName = ""
    @State private var copyrightOwner = ""
    @State private var copyrightYear = ""
    @State private var publisher = ""
    @State private var isrcCode = ""
    @State private var upcCode = ""
    @State private var proAffiliation = "ASCAP"
    @State private var drmStatus = "Protected"
    @State private var licenseType = "All Rights Reserved"
    @State private var territory = "Worldwide"
    @State private var registeredWith = "US Copyright Office"
    @State private var copyrightRegNumber = ""
    @State private var duration = ""
    @State private var releaseDate = ""
    @State private var spotifyLink = ""
    @State private var appleMusicLink = ""
    @State private var soundcloudLink = ""
    @State private var masterFileLocation = "Cloud Storage"
    @State private var showingDocumentPicker = false
    @State private var uploadedCertificate = ""
    @State private var showingSaveAlert = false
    @State private var quickImportURL = ""
    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var importErrorMessage = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var savedTrackId: String?
    @State private var showingAudioUpload = false
    @State private var selectedAudioURL: URL?
    @State private var isUploadingAudio = false
    @State private var uploadProgress: Double = 0.0
    @State private var showingAudioPicker = false
    @State private var audioUploadedSuccessfully = false
    
    let proOptions = ["ASCAP", "BMI", "SESAC", "GMR", "Not Registered"]
    let masterLocationOptions = ["Cloud Storage", "Personal Archive", "Studio Archive", "Distribution Platform"]
    
    let drmOptions = ["Protected", "Unprotected", "Watermarked"]
    let licenseOptions = ["All Rights Reserved", "Creative Commons", "Public Domain", "Custom License"]
    let territoryOptions = ["Worldwide", "North America", "Europe", "Asia", "Custom"]
    
    var isValid: Bool {
        let valid = !trackTitle.isEmpty && !artistName.isEmpty && !copyrightOwner.isEmpty
        print("🔍 Form validation: valid=\(valid), title='\(trackTitle)', artist='\(artistName)', owner='\(copyrightOwner)'")
        return valid
    }
    
    var audioFilePickerButton: some View {
        Button(action: {
            showingAudioPicker = true
        }) {
            HStack {
                let hasFile = selectedAudioURL != nil
                
                // Icon changes based on upload status
                if audioUploadedSuccessfully {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(hex: "32D74B"))
                        .font(.title3)
                } else if hasFile {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "32D74B"))
                        .font(.title3)
                } else {
                    Image(systemName: "music.note.list")
                        .foregroundColor(Color(hex: "64D2FF"))
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if audioUploadedSuccessfully {
                        Text("Audio Uploaded ✓")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "32D74B"))
                    } else {
                        Text(hasFile ? "Audio File Selected" : "Choose Audio File")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    if let audioURL = selectedAudioURL {
                        Text(audioURL.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("MP3, WAV, M4A, FLAC, AAC (Max 50MB)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if hasFile && !audioUploadedSuccessfully {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            selectedAudioURL = nil
                        }
                }
            }
            .padding()
            .background(audioUploadedSuccessfully ? Color(hex: "32D74B").opacity(0.1) : Color(hex: "1C1C1E"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(audioUploadedSuccessfully ? Color(hex: "32D74B").opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .disabled(audioUploadedSuccessfully)
    }
    
    var audioUploadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(Color(hex: "64D2FF"))
                Text("Audio File Upload")
                    .font(.headline)
                Spacer()
            }
            
            Text("Upload your audio file for fingerprinting and verification protection")
                .font(.caption)
                .foregroundColor(.gray)
            
            audioFilePickerButton
            
            if audioUploadedSuccessfully {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "32D74B"))
                    Text("Audio uploaded to secure cloud storage and ready for fingerprinting")
                        .font(.caption)
                        .foregroundColor(Color(hex: "32D74B"))
                }
                .padding()
                .background(Color(hex: "32D74B").opacity(0.1))
                .cornerRadius(8)
            } else if selectedAudioURL != nil {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color(hex: "64D2FF"))
                    Text("Audio will be uploaded to secure cloud storage and fingerprinted for protection")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(hex: "64D2FF").opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E").opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "64D2FF").opacity(0.3), lineWidth: 2)
        )
    }
    
    var quickImportSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(Color(hex: "FFD60A"))
                Text("Quick Import")
                    .font(.headline)
                Spacer()
            }
            
            Text("Paste an individual track URL (not album, playlist, or artist profile)")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "link")
                        .foregroundColor(Color(hex: "64D2FF"))
                        .font(.title3)
                    
                    TextField("e.g., spotify.com/track/...", text: $quickImportURL)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    if !quickImportURL.isEmpty {
                        Button(action: { quickImportURL = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(12)
                
                Button(action: importFromURL) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Import")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(quickImportURL.isEmpty ? Color.gray : Color(hex: "32D74B"))
                    .cornerRadius(12)
                }
                .disabled(quickImportURL.isEmpty)
            }
            
            if showingImportSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "32D74B"))
                    Text("Track details imported! Review and add copyright info below.")
                        .font(.caption)
                        .foregroundColor(Color(hex: "32D74B"))
                }
                .padding()
                .background(Color(hex: "32D74B").opacity(0.1))
                .cornerRadius(8)
            }
            
            if showingImportError {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "FF453A"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Invalid URL")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "FF453A"))
                        Text(importErrorMessage)
                            .font(.caption)
                            .foregroundColor(Color(hex: "FF453A"))
                    }
                }
                .padding()
                .background(Color(hex: "FF453A").opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E").opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "FFD60A").opacity(0.3), lineWidth: 2)
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    quickImportSection
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("Or enter manually")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    
                    // Basic Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Basic Information")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            FormField(
                                icon: "music.note",
                                placeholder: "Track Title",
                                text: $trackTitle
                            )
                            
                            FormField(
                                icon: "person",
                                placeholder: "Artist Name",
                                text: $artistName
                            )
                            
                            FormField(
                                icon: "clock",
                                placeholder: "Duration (e.g., 3:45)",
                                text: $duration
                            )
                            
                            FormField(
                                icon: "calendar",
                                placeholder: "Release Date (Optional)",
                                text: $releaseDate
                            )
                        }
                    }
                    
                    // Copyright Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Copyright Information")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            FormField(
                                icon: "c.circle",
                                placeholder: "Copyright Owner",
                                text: $copyrightOwner
                            )
                            
                            FormField(
                                icon: "calendar",
                                placeholder: "Copyright Year (e.g., 2024)",
                                text: $copyrightYear
                            )
                            
                            FormField(
                                icon: "building.2",
                                placeholder: "Publisher",
                                text: $publisher
                            )
                            
                            FormField(
                                icon: "music.note.list",
                                placeholder: "ISRC Code",
                                text: $isrcCode
                            )
                            
                            FormField(
                                icon: "barcode",
                                placeholder: "UPC/EAN Code (Optional)",
                                text: $upcCode
                            )
                            
                            FormField(
                                icon: "checkmark.seal",
                                placeholder: "Copyright Registration Number",
                                text: $copyrightRegNumber
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("PRO Affiliation", systemImage: "building.columns")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Picker("PRO", selection: $proAffiliation) {
                                    ForEach(proOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Digital Rights Management
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Digital Rights Management")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("DRM Status", systemImage: "lock.shield")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Picker("DRM Status", selection: $drmStatus) {
                                    ForEach(drmOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("License Type", systemImage: "doc.text")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Picker("License Type", selection: $licenseType) {
                                    ForEach(licenseOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Territory", systemImage: "globe")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Picker("Territory", selection: $territory) {
                                    ForEach(territoryOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Master File Location & Documentation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Master File & Documentation")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Master File Location", systemImage: "externaldrive")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Picker("Location", selection: $masterFileLocation) {
                                    ForEach(masterLocationOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                            
                            Button(action: {
                                showingDocumentPicker = true
                            }) {
                                HStack {
                                    Image(systemName: uploadedCertificate.isEmpty ? "doc.badge.plus" : "checkmark.circle.fill")
                                        .foregroundColor(uploadedCertificate.isEmpty ? Color(hex: "64D2FF") : Color(hex: "32D74B"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(uploadedCertificate.isEmpty ? "Upload Copyright Certificate" : "Certificate Uploaded")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("PDF of copyright registration (Optional)")
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
                    }
                    
                    // Audio File Upload
                    audioUploadSection
                    
                    // Save Button
                    Button(action: saveTrack) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                if selectedAudioURL != nil {
                                    Text("Uploading audio...")
                                } else {
                                    Text("Saving...")
                                }
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text(editingTrack == nil ? "Add Track" : "Save Changes")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color(hex: "32D74B") : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isValid || isSaving)
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle(editingTrack == nil ? "Add Track" : "Edit Track")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPickerView { url in
                    if let url = url {
                        uploadedCertificate = url.lastPathComponent
                    }
                }
            }
            .sheet(isPresented: $showingAudioPicker) {
                AudioPickerView(audioURL: $selectedAudioURL)
            }
            .onChange(of: selectedAudioURL) { newValue in
                if let audioURL = newValue {
                    // Reset upload success state when new file is selected
                    audioUploadedSuccessfully = false
                    
                    // Validate file size (50MB limit)
                    do {
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: audioURL.path)
                        if let fileSize = fileAttributes[.size] as? Int64 {
                            let maxSize: Int64 = 50 * 1024 * 1024 // 50MB
                            if fileSize > maxSize {
                                let sizeMB = Double(fileSize) / 1024.0 / 1024.0
                                saveError = "Audio file is too large (\(String(format: "%.1f", sizeMB))MB). Maximum size is 50MB."
                                selectedAudioURL = nil
                                return
                            }
                        }
                    } catch {
                        print("⚠️ Could not check file size: \(error)")
                    }
                    
                    extractAndPopulateMetadata(from: audioURL)
                }
            }
        }
    }
    
    func saveTrack() {
        print("🎯 saveTrack() called")
        print("   Title: '\(trackTitle)'")
        print("   Artist: '\(artistName)'")
        print("   Owner: '\(copyrightOwner)'")
        print("   Audio URL: \(selectedAudioURL?.lastPathComponent ?? "none")")
        
        isSaving = true
        saveError = nil
        
        Task {
            do {
                print("📝 Creating track via API...")
                // Step 1: Create track with metadata
                let track = try await TrackService.shared.createTrack(
                    title: trackTitle,
                    artistName: artistName,
                    duration: duration.isEmpty ? nil : duration,
                    releaseDate: releaseDate.isEmpty ? nil : releaseDate,
                    isrcCode: isrcCode.isEmpty ? nil : isrcCode,
                    upcCode: upcCode.isEmpty ? nil : upcCode,
                    copyrightOwner: copyrightOwner.isEmpty ? nil : copyrightOwner,
                    copyrightYear: copyrightYear.isEmpty ? nil : copyrightYear,
                    publisher: publisher.isEmpty ? nil : publisher,
                    copyrightRegNumber: copyrightRegNumber.isEmpty ? nil : copyrightRegNumber,
                    proAffiliation: proAffiliation,
                    spotifyUrl: spotifyLink.isEmpty ? nil : spotifyLink,
                    appleMusicUrl: appleMusicLink.isEmpty ? nil : appleMusicLink,
                    soundcloudUrl: soundcloudLink.isEmpty ? nil : soundcloudLink,
                    drmStatus: drmStatus,
                    licenseType: licenseType,
                    territory: territory,
                    masterFileLocation: masterFileLocation
                )
                
                print("✅ Track created successfully with ID: \(track.id)")
                
                // Step 2: Upload audio file if selected
                if let audioURL = selectedAudioURL {
                    print("📤 Uploading audio file...")
                    do {
                        let response = try await TrackService.shared.uploadAudio(trackId: track.id, audioFileURL: audioURL)
                        print("✅ Audio uploaded successfully")
                        print("   S3 URL: \(response.data.audioUrl)")
                        print("   Fingerprint: \(response.data.fingerprintGenerated ? "✅ Generated" : "❌ Failed")")
                        if let fpId = response.data.fingerprintId {
                            print("   Fingerprint ID: \(fpId)")
                        }
                    } catch {
                        let errorMsg = "\(error)"
                        print("⚠️ Audio upload failed (track saved without audio): \(errorMsg)")
                        // Show detailed error to user
                        await MainActor.run {
                            saveError = "Track saved but audio upload failed: \(errorMsg)"
                            showingSaveAlert = false // Don't show success alert
                        }
                        // Don't dismiss - let user see the error
                        await MainActor.run {
                            isSaving = false
                        }
                        return
                    }
                }
                
                // Step 3: Mark upload as successful and dismiss
                await MainActor.run {
                    if selectedAudioURL != nil {
                        audioUploadedSuccessfully = true
                    }
                    isSaving = false
                }
                
                // Brief delay to show success state before dismissing
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("❌ Failed to save track: \(error)")
                await MainActor.run {
                    saveError = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
    
    func uploadAudioFile() {
        guard let trackId = savedTrackId, let audioURL = selectedAudioURL else { return }
        
        isUploadingAudio = true
        
        Task {
            do {
                let response = try await TrackService.shared.uploadAudio(trackId: trackId, audioFileURL: audioURL)
                print("✅ Audio uploaded successfully")
                print("   S3 URL: \(response.data.audioUrl)")
                print("   Fingerprint: \(response.data.fingerprintGenerated ? "Generated" : "Failed")")
                
                await MainActor.run {
                    isUploadingAudio = false
                    showingAudioUpload = false
                    dismiss()
                }
            } catch {
                print("❌ Audio upload failed: \(error)")
                await MainActor.run {
                    isUploadingAudio = false
                    saveError = "Audio upload failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func extractAndPopulateMetadata(from url: URL) {
        print("🎵 Extracting metadata from audio file...")
        
        let metadata = AudioMetadataExtractor.extractMetadata(from: url)
        
        // Auto-populate fields if they're empty
        if trackTitle.isEmpty, let title = metadata.title {
            trackTitle = title
            print("✅ Auto-filled Track Title: \(title)")
        }
        
        if artistName.isEmpty, let artist = metadata.artist {
            artistName = artist
            print("✅ Auto-filled Artist Name: \(artist)")
        }
        
        if duration.isEmpty, let dur = metadata.duration {
            duration = dur
            print("✅ Auto-filled Duration: \(dur)")
        }
        
        if copyrightYear.isEmpty, let year = metadata.year {
            copyrightYear = year
            print("✅ Auto-filled Copyright Year: \(year)")
        }
        
        if copyrightOwner.isEmpty {
            // Use artist or composer as copyright owner if available
            if let artist = metadata.artist {
                copyrightOwner = artist
                print("✅ Auto-filled Copyright Owner: \(artist)")
            } else if let composer = metadata.composer {
                copyrightOwner = composer
                print("✅ Auto-filled Copyright Owner: \(composer)")
            }
        }
        
        if isrcCode.isEmpty, let isrc = metadata.isrc {
            isrcCode = isrc
            print("✅ Auto-filled ISRC: \(isrc)")
        }
        
        if publisher.isEmpty, let copyright = metadata.copyright {
            // Try to extract publisher from copyright string
            publisher = copyright
            print("✅ Auto-filled Publisher: \(copyright)")
        }
        
        print("✅ Metadata extraction and auto-fill complete!")
    }
    
    func importFromURL() {
        // Reset states
        showingImportSuccess = false
        showingImportError = false
        
        let url = quickImportURL.lowercased()
        
        // Check for Apple Music track (has ?i= parameter for track ID)
        let isAppleMusicTrack = url.contains("music.apple.com") && url.contains("?i=")
        
        // Validate URL type (but allow Apple Music tracks with album in path)
        if url.contains("album") && !url.contains("/track/") && !isAppleMusicTrack {
            showingImportError = true
            importErrorMessage = "This is an album URL. Please paste a link to an individual track instead."
            return
        }
        
        if url.contains("playlist") {
            showingImportError = true
            importErrorMessage = "This is a playlist URL. Please paste a link to an individual track instead."
            return
        }
        
        if url.contains("artist") && !url.contains("/track/") && !isAppleMusicTrack {
            showingImportError = true
            importErrorMessage = "This is an artist profile URL. Please paste a link to an individual track instead."
            return
        }
        
        // Check if it's a valid track URL
        let isSpotifyTrack = url.contains("spotify.com/track/") || url.contains("spotify.link/")
        let isValidTrack = isSpotifyTrack ||
                          isAppleMusicTrack ||
                          url.contains("soundcloud.com/") && !url.contains("/sets/")
        
        if !isValidTrack {
            showingImportError = true
            importErrorMessage = "Please paste a valid track URL from Spotify, Apple Music, or SoundCloud."
            return
        }
        
        // Valid track URL - proceed with import
        showingImportSuccess = true
        
        // Detect platform and set appropriate link
        if url.contains("spotify") {
            spotifyLink = quickImportURL
        } else if url.contains("apple") || url.contains("music.apple") {
            appleMusicLink = quickImportURL
        } else if url.contains("soundcloud") {
            soundcloudLink = quickImportURL
        }
        
        // Fetch metadata based on platform
        if isAppleMusicTrack {
            Task {
                await fetchAppleMusicMetadata(from: quickImportURL)
            }
        } else if isSpotifyTrack {
            Task {
                await fetchSpotifyMetadata(from: quickImportURL)
            }
        } else {
            // For other platforms, use placeholder for now
            trackTitle = "Imported Track"
            artistName = "Artist Name"
            duration = "3:45"
            releaseDate = "2024"
            
            copyrightOwner = artistName
            copyrightYear = "2024"
            publisher = "Independent"
        }
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showingImportSuccess = false
        }
    }
    
    func fetchSpotifyMetadata(from urlString: String) async {
        print("🎵 Fetching Spotify metadata from: \(urlString)")
        
        // Extract track ID from Spotify URL or use direct ID if provided
        var trackId = ""
        
        if let trackIdRange = urlString.range(of: "/track/([a-zA-Z0-9]+)", options: .regularExpression) {
            // Full URL format
            let trackIdString = String(urlString[trackIdRange])
            trackId = String(trackIdString.replacingOccurrences(of: "/track/", with: "").split(separator: "?").first ?? "")
        } else if urlString.range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) != nil {
            // Just the track ID
            trackId = urlString
        } else {
            print("❌ Could not extract track ID from: \(urlString)")
            return
        }
        
        print("🔑 Extracted track ID: \(trackId)")
        
        // Get Spotify access token first (using Client Credentials flow)
        print("🔐 Getting Spotify access token...")
        guard let accessToken = await getSpotifyAccessToken() else {
            print("❌ Failed to get Spotify access token")
            return
        }
        print("✅ Got access token: \(accessToken.prefix(20))...")
        
        // Fetch track metadata from Spotify API
        let apiURL = "https://api.spotify.com/v1/tracks/\(trackId)"
        print("🌐 Calling Spotify API: \(apiURL)")
        guard let url = URL(string: apiURL) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Spotify API response: \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Response data: \(responseString.prefix(200))...")
            }
            
            struct SpotifyTrack: Codable {
                let name: String
                let artists: [SpotifyArtist]
                let durationMs: Int
                let album: SpotifyAlbum
                let externalIds: SpotifyExternalIds?
                
                struct SpotifyArtist: Codable {
                    let name: String
                }
                
                struct SpotifyAlbum: Codable {
                    let releaseDate: String
                    let name: String
                    
                    enum CodingKeys: String, CodingKey {
                        case name
                        case releaseDate = "release_date"
                    }
                }
                
                struct SpotifyExternalIds: Codable {
                    let isrc: String?
                }
                
                enum CodingKeys: String, CodingKey {
                    case name, artists, album
                    case durationMs = "duration_ms"
                    case externalIds = "external_ids"
                }
            }
            
            let decoder = JSONDecoder()
            let track = try decoder.decode(SpotifyTrack.self, from: data)
            
            await MainActor.run {
                // Update UI with real metadata
                trackTitle = track.name
                artistName = track.artists.map { $0.name }.joined(separator: ", ")
                
                // Convert milliseconds to MM:SS format
                let seconds = track.durationMs / 1000
                let mins = seconds / 60
                let secs = seconds % 60
                duration = String(format: "%d:%02d", mins, secs)
                
                // Extract year from release date
                releaseDate = String(track.album.releaseDate.prefix(4))
                copyrightYear = String(track.album.releaseDate.prefix(4))
                
                // Set ISRC if available
                if let isrc = track.externalIds?.isrc {
                    isrcCode = isrc
                }
                
                copyrightOwner = artistName
                publisher = "Spotify"
                
                print("✅ Fetched Spotify metadata: \(trackTitle) by \(artistName)")
            }
        } catch {
            print("❌ Failed to fetch Spotify metadata: \(error)")
        }
    }
    
    func getSpotifyAccessToken() async -> String? {
        // Spotify API credentials
        let clientId = "b80e380a5278421dbea39468aaadf443"
        let clientSecret = "c5c3fe98402c45f69081f5c7f732c7b5"
        
        let credentials = "\(clientId):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else { return nil }
        let base64Credentials = credentialsData.base64EncodedString()
        
        let tokenURL = "https://accounts.spotify.com/api/token"
        guard let url = URL(string: tokenURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            struct TokenResponse: Codable {
                let accessToken: String
                
                enum CodingKeys: String, CodingKey {
                    case accessToken = "access_token"
                }
            }
            
            let response = try JSONDecoder().decode(TokenResponse.self, from: data)
            return response.accessToken
        } catch {
            print("❌ Failed to get Spotify token: \(error)")
            return nil
        }
    }
    
    func fetchAppleMusicMetadata(from urlString: String) async {
        // Extract track ID from Apple Music URL
        // Format: https://music.apple.com/us/album/song-name/albumId?i=trackId
        guard let trackIdRange = urlString.range(of: "\\?i=(\\d+)", options: .regularExpression),
              let trackId = urlString[trackIdRange].split(separator: "=").last else {
            print("Could not extract track ID from URL")
            return
        }
        
        // Use iTunes Search API to fetch metadata
        let apiURL = "https://itunes.apple.com/lookup?id=\(trackId)"
        
        guard let url = URL(string: apiURL) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            struct iTunesResponse: Codable {
                let results: [iTunesTrack]
            }
            
            struct iTunesTrack: Codable {
                let trackName: String?
                let artistName: String?
                let trackTimeMillis: Int?
                let releaseDate: String?
                let isrc: String?
                let copyright: String?
            }
            
            let response = try JSONDecoder().decode(iTunesResponse.self, from: data)
            
            if let track = response.results.first {
                await MainActor.run {
                    // Update UI with real metadata
                    trackTitle = track.trackName ?? "Unknown Track"
                    artistName = track.artistName ?? "Unknown Artist"
                    
                    // Convert milliseconds to MM:SS format
                    if let millis = track.trackTimeMillis {
                        let seconds = millis / 1000
                        let mins = seconds / 60
                        let secs = seconds % 60
                        duration = String(format: "%d:%02d", mins, secs)
                    }
                    
                    // Extract year from release date (format: YYYY-MM-DD)
                    if let release = track.releaseDate {
                        releaseDate = String(release.prefix(4))
                        copyrightYear = String(release.prefix(4))
                    }
                    
                    // Set ISRC if available
                    if let isrc = track.isrc {
                        isrcCode = isrc
                    }
                    
                    // Set copyright owner
                    if let copyright = track.copyright {
                        copyrightOwner = copyright
                    } else {
                        copyrightOwner = artistName
                    }
                    
                    publisher = "Apple Music"
                    
                    print("✅ Fetched Apple Music metadata: \(trackTitle) by \(artistName)")
                }
            }
        } catch {
            print("❌ Failed to fetch Apple Music metadata: \(error)")
            // Keep placeholder values if fetch fails
        }
    }
}

struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "64D2FF"))
                .font(.title3)
                .frame(width: 32)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}
