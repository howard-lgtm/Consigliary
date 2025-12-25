import Foundation

// MARK: - Demo Data for Screenshots
// IMPORTANT: Set ENABLE_DEMO_DATA to false before archiving for TestFlight

let ENABLE_DEMO_DATA = false // ⚠️ SET TO FALSE BEFORE ARCHIVE

struct DemoData {
    static let tracks: [Track] = [
        Track(
            title: "Midnight Drive",
            streams: 125000,
            revenue: 3847.50,
            contributors: []
        ),
        Track(
            title: "Ocean Waves",
            streams: 87500,
            revenue: 2156.75,
            contributors: []
        ),
        Track(
            title: "City Lights",
            streams: 156000,
            revenue: 4523.25,
            contributors: []
        ),
        Track(
            title: "Sunrise Session",
            streams: 62000,
            revenue: 1892.00,
            contributors: []
        ),
        Track(
            title: "Neon Dreams",
            streams: 198000,
            revenue: 5234.50,
            contributors: []
        )
    ]
    
    static let revenueEvents: [RevenueEvent] = [
        RevenueEvent(
            source: .streaming,
            amount: 1247.50,
            trackTitle: "Midnight Drive",
            date: Date().addingTimeInterval(-7 * 24 * 60 * 60),
            description: "Spotify Q4 2024"
        ),
        RevenueEvent(
            source: .streaming,
            amount: 892.25,
            trackTitle: "Ocean Waves",
            date: Date().addingTimeInterval(-7 * 24 * 60 * 60),
            description: "Apple Music Q4 2024"
        ),
        RevenueEvent(
            source: .syncLicense,
            amount: 2500.00,
            trackTitle: "City Lights",
            date: Date().addingTimeInterval(-14 * 24 * 60 * 60),
            description: "YouTube Creator License"
        ),
        RevenueEvent(
            source: .syncLicense,
            amount: 1800.00,
            trackTitle: "Neon Dreams",
            date: Date().addingTimeInterval(-21 * 24 * 60 * 60),
            description: "Instagram Influencer License"
        ),
        RevenueEvent(
            source: .performanceRights,
            amount: 456.75,
            trackTitle: "Sunrise Session",
            date: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            description: "BMI Performance Royalties"
        ),
        RevenueEvent(
            source: .streaming,
            amount: 1567.80,
            trackTitle: "Neon Dreams",
            date: Date().addingTimeInterval(-3 * 24 * 60 * 60),
            description: "YouTube Music Q4 2024"
        ),
        RevenueEvent(
            source: .syncLicense,
            amount: 3200.00,
            trackTitle: "Midnight Drive",
            date: Date().addingTimeInterval(-45 * 24 * 60 * 60),
            description: "TikTok Creator License"
        ),
        RevenueEvent(
            source: .streaming,
            amount: 734.50,
            trackTitle: "City Lights",
            date: Date().addingTimeInterval(-10 * 24 * 60 * 60),
            description: "Amazon Music Q4 2024"
        ),
        RevenueEvent(
            source: .performanceRights,
            amount: 623.40,
            trackTitle: "Ocean Waves",
            date: Date().addingTimeInterval(-60 * 24 * 60 * 60),
            description: "ASCAP Performance Royalties"
        ),
        RevenueEvent(
            source: .syncLicense,
            amount: 1500.00,
            trackTitle: "Sunrise Session",
            date: Date().addingTimeInterval(-5 * 24 * 60 * 60),
            description: "Podcast Background Music License"
        )
    ]
    
    static let activities: [Activity] = [
        Activity(
            platform: "YouTube",
            track: "Midnight Drive",
            artist: "DJ Remix Master",
            thumbnail: "https://i.ytimg.com/vi/placeholder/default.jpg",
            timestamp: "2 days ago",
            requiresManualReview: false
        ),
        Activity(
            platform: "TikTok",
            track: "City Lights",
            artist: "Sarah Chen",
            thumbnail: "https://i.ytimg.com/vi/placeholder/default.jpg",
            timestamp: "1 day ago",
            requiresManualReview: false
        ),
        Activity(
            platform: "Instagram",
            track: "Neon Dreams",
            artist: "Fitness Motivation",
            thumbnail: "https://i.ytimg.com/vi/placeholder/default.jpg",
            timestamp: "3 days ago",
            requiresManualReview: true
        ),
        Activity(
            platform: "YouTube",
            track: "Ocean Waves",
            artist: "Meditation Channel",
            thumbnail: "https://i.ytimg.com/vi/placeholder/default.jpg",
            timestamp: "4 days ago",
            requiresManualReview: false
        )
    ]
    
    static let deals: [Deal] = [
        Deal(
            title: "Sync License - Netflix Series",
            description: "Background music for upcoming drama series",
            value: "$15,000",
            status: .pending,
            monetaryValue: 15000,
            relatedTrack: "Midnight Drive"
        ),
        Deal(
            title: "Exclusive Streaming Rights",
            description: "Spotify Originals playlist feature",
            value: "$8,500",
            status: .new,
            monetaryValue: 8500,
            relatedTrack: "City Lights"
        ),
        Deal(
            title: "Commercial License - Nike Ad",
            description: "30-second TV commercial campaign",
            value: "$25,000",
            status: .pending,
            monetaryValue: 25000,
            relatedTrack: "Neon Dreams"
        )
    ]
}
