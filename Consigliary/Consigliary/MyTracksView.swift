import SwiftUI

struct MyTracksView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var appData: AppData
    @State private var searchText = ""
    @State private var sortOption: SortOption = .recent
    @State private var showingAddTrack = false
    @State private var apiTracks: [TrackService.Track] = []
    @State private var isLoadingTracks = false
    @State private var loadError: String?
    
    enum SortOption: String, CaseIterable {
        case recent = "Recent"
        case name = "Name"
        case revenue = "Revenue"
    }
    
    var filteredTracks: [TrackService.Track] {
        var tracks = apiTracks
        
        if !searchText.isEmpty {
            tracks = tracks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch sortOption {
        case .recent:
            return tracks
        case .name:
            return tracks.sorted { $0.title < $1.title }
        case .revenue:
            return tracks.sorted { 
                let rev1 = Double($0.revenue ?? "0") ?? 0
                let rev2 = Double($1.revenue ?? "0") ?? 0
                return rev1 > rev2
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Stats
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        StatBox(
                            title: "Total Tracks",
                            value: "\(apiTracks.count)",
                            icon: "music.note",
                            color: Color(hex: "BF5AF2")
                        )
                        
                        StatBox(
                            title: "Total Streams",
                            value: formatStreams(apiTracks.reduce(0) { $0 + ($1.streams ?? 0) }),
                            icon: "waveform",
                            color: Color(hex: "32D74B")
                        )
                    }
                    
                    HStack(spacing: 16) {
                        StatBox(
                            title: "Total Revenue",
                            value: "$\(Int(apiTracks.reduce(0) { $0 + (Double($1.revenue ?? "0") ?? 0) }))",
                            icon: "dollarsign.circle",
                            color: Color(hex: "FFD60A")
                        )
                        
                        StatBox(
                            title: "Monitored",
                            value: "\(apiTracks.count)",
                            icon: "eye.fill",
                            color: Color(hex: "64D2FF")
                        )
                    }
                }
                .padding(.horizontal)
                
                // Search and Sort
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search tracks", text: $searchText)
                            .foregroundColor(.white)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(12)
                    
                    HStack {
                        Text("Sort by:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding(.horizontal)
                
                // Tracks List
                VStack(spacing: 12) {
                    if filteredTracks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text(searchText.isEmpty ? "No tracks yet" : "No tracks found")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            if searchText.isEmpty {
                                Text("Add tracks to start monitoring")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
                        ForEach(filteredTracks) { track in
                            HStack(spacing: 16) {
                                Image(systemName: "music.note")
                                    .font(.title2)
                                    .foregroundColor(Color(hex: "BF5AF2"))
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: "1C1C1E"))
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(track.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(track.artistName)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    if let streams = track.streams {
                                        Text("\(formatStreams(streams))")
                                            .font(.subheadline)
                                            .foregroundColor(Color(hex: "32D74B"))
                                    }
                                    
                                    if let revenue = track.revenue, let revValue = Double(revenue) {
                                        Text("$\(Int(revValue))")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "FFD60A"))
                                    }
                                }
                            }
                            .padding()
                            .background(Color(hex: "1C1C1E"))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .frame(maxWidth: horizontalSizeClass == .regular ? 1000 : .infinity)
        .frame(maxWidth: .infinity)
        .navigationTitle("My Tracks")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddTrack = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "32D74B"))
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingAddTrack) {
            AddTrackView()
                .environmentObject(appData)
        }
        .refreshable {
            loadTracks()
        }
        .onAppear {
            loadTracks()
        }
    }
    
    func loadTracks() {
        // Use demo data if enabled
        if ENABLE_DEMO_DATA {
            apiTracks = appData.tracks.map { track in
                TrackService.Track(
                    id: UUID().uuidString,
                    title: track.title,
                    artistName: "Howard Duffy",
                    duration: "3:45",
                    releaseDate: ISO8601DateFormatter().string(from: Date()),
                    isrcCode: "USRC17607839",
                    spotifyUrl: nil,
                    appleMusicUrl: nil,
                    soundcloudUrl: nil,
                    streams: track.streams,
                    revenue: String(format: "%.2f", track.revenue),
                    createdAt: ISO8601DateFormatter().string(from: Date()),
                    updatedAt: ISO8601DateFormatter().string(from: Date())
                )
            }
            isLoadingTracks = false
            print("✅ Loaded \(apiTracks.count) demo tracks")
            return
        }
        
        isLoadingTracks = true
        loadError = nil
        
        Task {
            do {
                let tracks = try await TrackService.shared.getTracks()
                await MainActor.run {
                    apiTracks = tracks
                    isLoadingTracks = false
                }
                print("✅ Loaded \(tracks.count) tracks from API")
            } catch {
                await MainActor.run {
                    loadError = error.localizedDescription
                    isLoadingTracks = false
                }
                print("❌ Failed to load tracks: \(error)")
            }
        }
    }
    
    func formatStreams(_ streams: Int) -> String {
        if streams >= 1_000_000 {
            return String(format: "%.1fM", Double(streams) / 1_000_000)
        } else if streams >= 1000 {
            return String(format: "%.1fK", Double(streams) / 1000)
        }
        return "\(streams)"
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct TrackRow: View {
    let track: Track
    
    var body: some View {
        HStack(spacing: 16) {
            // Album Art Placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "BF5AF2").opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "music.note")
                        .foregroundColor(Color(hex: "BF5AF2"))
                        .font(.title2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.caption)
                        Text("\(formatStreams(track.streams))")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.caption)
                        Text("$\(Int(track.revenue))")
                            .font(.caption)
                    }
                    .foregroundColor(Color(hex: "32D74B"))
                }
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
    
    func formatStreams(_ streams: Int) -> String {
        if streams >= 1_000_000 {
            return String(format: "%.1fM", Double(streams) / 1_000_000)
        } else if streams >= 1000 {
            return String(format: "%.1fK", Double(streams) / 1000)
        }
        return "\(streams)"
    }
}
