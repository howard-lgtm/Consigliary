import SwiftUI

struct MonetizationView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var streamingPercentage: Int {
        guard appData.totalRevenue > 0 else { return 0 }
        return Int((appData.streamingRevenue / appData.totalRevenue) * 100)
    }
    
    var syncPercentage: Int {
        guard appData.totalRevenue > 0 else { return 0 }
        return Int((appData.syncRevenue / appData.totalRevenue) * 100)
    }
    
    var performancePercentage: Int {
        guard appData.totalRevenue > 0 else { return 0 }
        return Int((appData.performanceRevenue / appData.totalRevenue) * 100)
    }
    
    func formatStreams(_ streams: Int) -> String {
        if streams >= 1000 {
            return "\(streams / 1000)K"
        }
        return "\(streams)"
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Total Revenue
                    VStack(spacing: 8) {
                        Text("Total Revenue")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("$\(Int(appData.totalRevenue))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "32D74B"))
                        
                        Text("This Month")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(12)
                    
                    // Revenue Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Revenue Breakdown")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        RevenueItem(
                            icon: "music.note",
                            title: "Streaming Royalties",
                            amount: "$\(Int(appData.streamingRevenue))",
                            percentage: streamingPercentage,
                            color: Color(hex: "32D74B")
                        )
                        
                        RevenueItem(
                            icon: "film.fill",
                            title: "Sync Licenses",
                            amount: "$\(Int(appData.syncRevenue))",
                            percentage: syncPercentage,
                            color: Color(hex: "64D2FF")
                        )
                        
                        RevenueItem(
                            icon: "person.3.fill",
                            title: "Performance Rights",
                            amount: "$\(Int(appData.performanceRevenue))",
                            percentage: performancePercentage,
                            color: Color(hex: "FFD60A")
                        )
                    }
                    
                    // Top Tracks
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Top Performing Tracks")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(appData.topTracks) { track in
                            TrackItem(
                                title: track.title,
                                streams: formatStreams(track.streams),
                                revenue: "$\(Int(track.revenue))"
                            )
                        }
                    }
                    
                    // Recent Revenue Events
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Revenue")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(appData.revenueEvents.count) events")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        ForEach(appData.revenueEvents.prefix(5)) { event in
                            RevenueEventRow(event: event)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black)
            .frame(maxWidth: horizontalSizeClass == .regular ? 1000 : .infinity)
            .frame(maxWidth: .infinity)
            .navigationTitle("Monetization")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct RevenueEventRow: View {
    let event: RevenueEvent
    
    var sourceIcon: String {
        switch event.source {
        case .streaming: return "music.note"
        case .syncLicense: return "film.fill"
        case .performanceRights: return "person.3.fill"
        }
    }
    
    var sourceColor: Color {
        switch event.source {
        case .streaming: return Color(hex: "32D74B")
        case .syncLicense: return Color(hex: "64D2FF")
        case .performanceRights: return Color(hex: "FFD60A")
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: sourceIcon)
                .foregroundColor(sourceColor)
                .font(.title3)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.trackTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("+$\(Int(event.amount))")
                .font(.headline)
                .foregroundColor(sourceColor)
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct RevenueItem: View {
    let icon: String
    let title: String
    let amount: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text("\(percentage)% of total")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(amount)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}

struct TrackItem: View {
    let title: String
    let streams: String
    let revenue: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text("\(streams) streams")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(revenue)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "32D74B"))
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
    }
}
