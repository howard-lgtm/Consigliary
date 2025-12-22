import SwiftUI

struct TrackDetailView: View {
    @Environment(\.dismiss) var dismiss
    let track: Track
    @State private var showingEditSheet = false
    @State private var showingContributors = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Album Art & Title
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "BF5AF2").opacity(0.3))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(Color(hex: "BF5AF2"))
                                .font(.system(size: 80))
                        )
                    
                    VStack(spacing: 8) {
                        Text(track.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Artist Name")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
                
                // Stats
                HStack(spacing: 16) {
                    StatCard(
                        icon: "waveform",
                        value: formatStreams(track.streams),
                        label: "Streams",
                        color: Color(hex: "32D74B")
                    )
                    
                    StatCard(
                        icon: "dollarsign.circle",
                        value: "$\(Int(track.revenue))",
                        label: "Revenue",
                        color: Color(hex: "FFD60A")
                    )
                }
                .padding(.horizontal)
                
                // Copyright & DRM Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Copyright & Rights")
                        .font(.headline)
                    
                    InfoSection(
                        icon: "c.circle",
                        title: "Copyright Owner",
                        value: "Artist Name",
                        color: Color(hex: "64D2FF")
                    )
                    
                    InfoSection(
                        icon: "calendar",
                        title: "Copyright Year",
                        value: "2024",
                        color: Color(hex: "64D2FF")
                    )
                    
                    InfoSection(
                        icon: "building.2",
                        title: "Publisher",
                        value: "Independent",
                        color: Color(hex: "64D2FF")
                    )
                    
                    InfoSection(
                        icon: "music.note.list",
                        title: "ISRC Code",
                        value: "USRC12345678",
                        color: Color(hex: "64D2FF")
                    )
                }
                .padding()
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // DRM & Protection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Digital Rights Management")
                        .font(.headline)
                    
                    InfoSection(
                        icon: "lock.shield",
                        title: "DRM Status",
                        value: "Protected",
                        color: Color(hex: "32D74B")
                    )
                    
                    InfoSection(
                        icon: "doc.text",
                        title: "License Type",
                        value: "All Rights Reserved",
                        color: Color(hex: "FFD60A")
                    )
                    
                    InfoSection(
                        icon: "globe",
                        title: "Territory",
                        value: "Worldwide",
                        color: Color(hex: "64D2FF")
                    )
                    
                    InfoSection(
                        icon: "checkmark.seal",
                        title: "Registered",
                        value: "US Copyright Office",
                        color: Color(hex: "32D74B")
                    )
                }
                .padding()
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // File Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("File Information")
                        .font(.headline)
                    
                    InfoSection(
                        icon: "waveform.circle",
                        title: "Audio Format",
                        value: "WAV (Lossless)",
                        color: Color(hex: "BF5AF2")
                    )
                    
                    InfoSection(
                        icon: "gauge.high",
                        title: "Sample Rate",
                        value: "48 kHz / 24-bit",
                        color: Color(hex: "BF5AF2")
                    )
                    
                    InfoSection(
                        icon: "clock",
                        title: "Duration",
                        value: "3:45",
                        color: Color(hex: "BF5AF2")
                    )
                    
                    InfoSection(
                        icon: "doc.badge.gearshape",
                        title: "Master File",
                        value: "Stored Securely",
                        color: Color(hex: "32D74B")
                    )
                }
                .padding()
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Track Information")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "64D2FF"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingContributors = true
                    }) {
                        HStack {
                            Image(systemName: "person.3.fill")
                            Text("Manage Contributors & Splits")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "32D74B"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("Download Master File")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("View Copyright Certificate")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color.black)
        .navigationTitle("Track Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            AddTrackView(editingTrack: track)
        }
        .sheet(isPresented: $showingContributors) {
            ContributorManagementView(trackId: track.id.uuidString, trackTitle: track.title)
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

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct InfoSection: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
    }
}
