import Foundation
import SwiftUI
import Combine

// MARK: - Main Data Store
class AppData: ObservableObject {
    // MARK: - Published Properties
    @Published var tracks: [Track] = Track.mockData
    @Published var activities: [Activity] = Activity.mockData
    @Published var deals: [Deal] = Deal.mockData
    @Published var revenueEvents: [RevenueEvent] = RevenueEvent.mockData
    @Published var contractAnalyses: [ContractAnalysis] = []
    @Published var splitSheets: [SplitSheet] = []
    
    // MARK: - Computed Properties
    var threatsNeutralized: Int {
        // Count of activities that have been handled (takedown or licensed)
        let totalActivities = Activity.mockData.count
        let remainingActivities = activities.count
        return totalActivities - remainingActivities
    }
    
    var tracksScanned: String {
        // Calculate based on total activities processed + current activities
        let totalScanned = Activity.mockData.count + (threatsNeutralized * 100) // Estimate: each threat represents ~100 scans
        if totalScanned >= 1_000_000 {
            return String(format: "%.1fM+", Double(totalScanned) / 1_000_000.0)
        } else if totalScanned >= 1_000 {
            return String(format: "%.1fK+", Double(totalScanned) / 1_000.0)
        } else {
            return "\(totalScanned)+"
        }
    }
    
    var averageResponseTime: String {
        "< 2min"
    }
    
    var manualReviewCount: Int {
        activities.filter { $0.requiresManualReview }.count
    }
    
    var totalRevenue: Double {
        revenueEvents.reduce(0) { $0 + $1.amount }
    }
    
    var streamingRevenue: Double {
        revenueEvents.filter { $0.source == .streaming }.reduce(0) { $0 + $1.amount }
    }
    
    var syncRevenue: Double {
        revenueEvents.filter { $0.source == .syncLicense }.reduce(0) { $0 + $1.amount }
    }
    
    var performanceRevenue: Double {
        revenueEvents.filter { $0.source == .performanceRights }.reduce(0) { $0 + $1.amount }
    }
    
    var topTracks: [Track] {
        tracks.sorted { $0.revenue > $1.revenue }.prefix(3).map { $0 }
    }
    
    var activeDealCount: Int {
        deals.filter { $0.status == .new || $0.status == .pending }.count
    }
    
    // MARK: - Actions
    func handleTakedown(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        // In a real app, this would trigger API call to send DMCA notice
    }
    
    func generateLicensePDF(_ activity: Activity, amount: Double) -> URL? {
        // Generate PDF without removing activity yet
        let licenseData = LicenseAgreementData(
            trackName: activity.track,
            platform: activity.platform,
            userName: activity.artist,
            licenseFee: amount,
            artistName: "Howard Duffy", // TODO: Get from user profile
            date: Date()
        )
        
        return LicenseAgreementPDFGenerator.generatePDF(for: licenseData)
    }
    
    func completeLicense(_ activity: Activity, amount: Double) {
        // Remove activity and update revenue after PDF is shared
        activities.removeAll { $0.id == activity.id }
        
        // Create revenue event
        let revenueEvent = RevenueEvent(
            source: .syncLicense,
            amount: amount,
            trackTitle: activity.track,
            date: Date(),
            description: "License agreement with \(activity.artist) on \(activity.platform)"
        )
        revenueEvents.append(revenueEvent)
        
        // Update track revenue if it exists
        if let trackIndex = tracks.firstIndex(where: { $0.title == activity.track }) {
            tracks[trackIndex].revenue += amount
        }
    }
    
    func handleIgnore(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
    }
    
    func acceptDeal(_ deal: Deal) {
        if let index = deals.firstIndex(where: { $0.id == deal.id }) {
            deals[index].status = .accepted
            
            // Add revenue event if deal has monetary value
            if let value = deal.monetaryValue {
                let revenueEvent = RevenueEvent(
                    source: .syncLicense,
                    amount: value,
                    trackTitle: deal.relatedTrack ?? "Various",
                    date: Date(),
                    description: deal.title
                )
                revenueEvents.append(revenueEvent)
            }
        }
    }
    
    func declineDeal(_ deal: Deal) {
        if let index = deals.firstIndex(where: { $0.id == deal.id }) {
            deals[index].status = .declined
        }
    }
    
    func createSplitSheet(trackTitle: String, contributors: [Contributor]) -> SplitSheet {
        let splitSheet = SplitSheet(
            trackTitle: trackTitle,
            contributors: contributors,
            createdDate: Date()
        )
        splitSheets.append(splitSheet)
        
        // Create or update track
        if let trackIndex = tracks.firstIndex(where: { $0.title == trackTitle }) {
            tracks[trackIndex].contributors = contributors
        } else {
            let newTrack = Track(
                title: trackTitle,
                streams: 0,
                revenue: 0,
                contributors: contributors
            )
            tracks.append(newTrack)
        }
        
        return splitSheet
    }
    
    func generateSplitSheetPDF(for splitSheet: SplitSheet) -> URL? {
        return SplitSheetPDFGenerator.generatePDF(for: splitSheet)
    }
    
    func saveContractAnalysis(_ analysis: ContractAnalysis) {
        contractAnalyses.append(analysis)
    }
}

// MARK: - Track Model
struct Track: Identifiable {
    let id = UUID()
    var title: String
    var streams: Int
    var revenue: Double
    var contributors: [Contributor]
    
    static let mockData: [Track] = [
        Track(title: "Starlight Symphony", streams: 125000, revenue: 450, contributors: []),
        Track(title: "Midnight Dreams", streams: 98000, revenue: 312, contributors: []),
        Track(title: "City Lights", streams: 76000, revenue: 285, contributors: []),
        Track(title: "Summer Vibes", streams: 45000, revenue: 180, contributors: []),
        Track(title: "Neon Nights", streams: 38000, revenue: 150, contributors: []),
        Track(title: "Ocean Waves", streams: 29000, revenue: 115, contributors: [])
    ]
}

// MARK: - Activity Model
struct Activity: Identifiable {
    let id = UUID()
    let platform: String
    let track: String
    let artist: String
    let thumbnail: String
    let timestamp: String
    var requiresManualReview: Bool = false
    
    static let mockData: [Activity] = [
        Activity(platform: "TikTok", track: "Midnight Dreams", artist: "@musiclover23", thumbnail: "🎵", timestamp: "2 min ago", requiresManualReview: true),
        Activity(platform: "Instagram", track: "Summer Vibes", artist: "@beachparty", thumbnail: "📸", timestamp: "15 min ago"),
        Activity(platform: "YouTube", track: "City Lights", artist: "VlogDaily", thumbnail: "🎬", timestamp: "1 hour ago", requiresManualReview: true),
        Activity(platform: "TikTok", track: "Neon Nights", artist: "@danceking", thumbnail: "🎵", timestamp: "3 hours ago", requiresManualReview: true),
        Activity(platform: "Instagram", track: "Ocean Waves", artist: "@travelblog", thumbnail: "📸", timestamp: "5 hours ago")
    ]
}

// MARK: - Deal Model
struct Deal: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let value: String
    var status: DealStatus
    var monetaryValue: Double?
    var relatedTrack: String?
    
    static let mockData: [Deal] = [
        Deal(title: "Sync License Opportunity", description: "Netflix series looking for indie tracks", value: "$2,500", status: .new, monetaryValue: 2500, relatedTrack: "Starlight Symphony"),
        Deal(title: "Brand Partnership", description: "Sustainable fashion brand campaign", value: "$1,200", status: .pending, monetaryValue: 1200, relatedTrack: "Summer Vibes"),
        Deal(title: "Playlist Placement", description: "Spotify Editorial - Indie Vibes", value: "Exposure", status: .accepted, monetaryValue: nil, relatedTrack: "Midnight Dreams")
    ]
}

enum DealStatus {
    case new
    case pending
    case accepted
    case declined
}

// MARK: - Revenue Event Model
struct RevenueEvent: Identifiable {
    let id = UUID()
    let source: RevenueSource
    let amount: Double
    let trackTitle: String
    let date: Date
    let description: String
    
    static let mockData: [RevenueEvent] = [
        // Streaming revenue
        RevenueEvent(source: .streaming, amount: 450, trackTitle: "Starlight Symphony", date: Date(), description: "Spotify, Apple Music, etc."),
        RevenueEvent(source: .streaming, amount: 312, trackTitle: "Midnight Dreams", date: Date(), description: "Spotify, Apple Music, etc."),
        RevenueEvent(source: .streaming, amount: 285, trackTitle: "City Lights", date: Date(), description: "Spotify, Apple Music, etc."),
        
        // Sync licenses
        RevenueEvent(source: .syncLicense, amount: 250, trackTitle: "Starlight Symphony", date: Date(), description: "TV commercial license"),
        
        // Performance rights
        RevenueEvent(source: .performanceRights, amount: 150, trackTitle: "Various", date: Date(), description: "BMI/ASCAP royalties")
    ]
}

enum RevenueSource {
    case streaming
    case syncLicense
    case performanceRights
    
    var displayName: String {
        switch self {
        case .streaming: return "Streaming Royalties"
        case .syncLicense: return "Sync Licenses"
        case .performanceRights: return "Performance Rights"
        }
    }
    
    var icon: String {
        switch self {
        case .streaming: return "music.note"
        case .syncLicense: return "film.fill"
        case .performanceRights: return "person.3.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .streaming: return Color(hex: "32D74B")
        case .syncLicense: return Color(hex: "64D2FF")
        case .performanceRights: return Color(hex: "FFD60A")
        }
    }
}

// MARK: - Split Sheet Model
struct SplitSheet: Identifiable {
    let id = UUID()
    let trackTitle: String
    let contributors: [Contributor]
    let createdDate: Date
}

// MARK: - Contract Analysis Model
struct ContractAnalysis: Identifiable {
    let id = UUID()
    let contractName: String
    let contractType: String
    let fairnessScore: Double
    let scoreCategory: String // "Excellent", "Good", "Fair", "Poor", "Predatory"
    let redFlags: [RedFlag]
    let greenFlags: [String]
    let recommendations: [String]
    let keyTerms: [ContractTerm]
    let analyzedDate: Date
    
    static let demoScenarios: [ContractAnalysis] = [
        // Scenario 1: Excellent Contract
        ContractAnalysis(
            contractName: "Indie Label Distribution Deal",
            contractType: "Distribution Agreement",
            fairnessScore: 8.5,
            scoreCategory: "Excellent",
            redFlags: [],
            greenFlags: [
                "Artist retains 100% master ownership",
                "Transparent royalty accounting",
                "Reasonable 2-year term with option to renew",
                "No hidden fees or recoupment clauses",
                "Clear termination rights"
            ],
            recommendations: [
                "This is a fair and artist-friendly agreement",
                "Consider negotiating for quarterly instead of semi-annual payments",
                "Request audit rights to be added to Section 7",
                "Excellent deal overall - recommended to proceed"
            ],
            keyTerms: [
                ContractTerm(term: "Royalty Rate", value: "85% to artist", status: .good),
                ContractTerm(term: "Contract Length", value: "2 years", status: .good),
                ContractTerm(term: "Territory", value: "Worldwide", status: .neutral),
                ContractTerm(term: "Master Ownership", value: "Artist retains", status: .good),
                ContractTerm(term: "Advance", value: "$5,000 non-recoupable", status: .good)
            ],
            analyzedDate: Date()
        ),
        
        // Scenario 2: Problematic 360 Deal
        ContractAnalysis(
            contractName: "Major Label 360 Deal",
            contractType: "360 Recording Agreement",
            fairnessScore: 3.2,
            scoreCategory: "Poor",
            redFlags: [
                RedFlag(
                    issue: "360 Deal Structure",
                    severity: .high,
                    description: "Label takes percentage of ALL income including touring, merch, and endorsements"
                ),
                RedFlag(
                    issue: "Perpetual Rights",
                    severity: .critical,
                    description: "Label owns masters in perpetuity with no reversion clause"
                ),
                RedFlag(
                    issue: "Recoupment Terms",
                    severity: .high,
                    description: "100% recoupment on marketing costs before any royalty payments"
                ),
                RedFlag(
                    issue: "Option Periods",
                    severity: .medium,
                    description: "Label has 5 unilateral option periods - you could be locked in for 10+ years"
                )
            ],
            greenFlags: [
                "Substantial marketing budget committed"
            ],
            recommendations: [
                "⚠️ DO NOT SIGN without major revisions",
                "Negotiate to remove 360 provisions or reduce percentages to 10-15%",
                "Request master ownership reversion after 7-10 years",
                "Limit option periods to 2 maximum",
                "Add sunset clause for recoupment (5 years max)",
                "Consult with entertainment attorney before proceeding"
            ],
            keyTerms: [
                ContractTerm(term: "Royalty Rate", value: "18% (after recoupment)", status: .bad),
                ContractTerm(term: "Contract Length", value: "Initial + 5 options", status: .bad),
                ContractTerm(term: "360 Provisions", value: "20% of all income", status: .bad),
                ContractTerm(term: "Master Ownership", value: "Label owns perpetually", status: .bad),
                ContractTerm(term: "Advance", value: "$50,000 fully recoupable", status: .neutral)
            ],
            analyzedDate: Date()
        ),
        
        // Scenario 3: Standard Sync License
        ContractAnalysis(
            contractName: "TV Show Sync License",
            contractType: "Synchronization License",
            fairnessScore: 7.0,
            scoreCategory: "Good",
            redFlags: [
                RedFlag(
                    issue: "Broad Usage Rights",
                    severity: .medium,
                    description: "License includes streaming, reruns, and international distribution"
                ),
                RedFlag(
                    issue: "No Performance Royalties Mentioned",
                    severity: .low,
                    description: "Contract doesn't specify PRO performance royalties - ensure you're registered"
                )
            ],
            greenFlags: [
                "One-time payment upfront",
                "Limited to single episode use",
                "Artist retains all other rights",
                "Clear usage parameters"
            ],
            recommendations: [
                "Fair deal for a TV sync placement",
                "Negotiate for higher fee if show has major distribution",
                "Ensure your PRO (ASCAP/BMI) is notified for performance royalties",
                "Request approval rights for any promotional use",
                "Consider asking for backend if show becomes a hit"
            ],
            keyTerms: [
                ContractTerm(term: "License Fee", value: "$2,500", status: .good),
                ContractTerm(term: "Usage", value: "Single episode, all media", status: .neutral),
                ContractTerm(term: "Territory", value: "Worldwide", status: .neutral),
                ContractTerm(term: "Term", value: "Perpetual for this episode", status: .neutral),
                ContractTerm(term: "Rights Retained", value: "All other rights", status: .good)
            ],
            analyzedDate: Date()
        )
    ]
}

struct RedFlag: Identifiable {
    let id = UUID()
    let issue: String
    let severity: RedFlagSeverity
    let description: String
}

enum RedFlagSeverity {
    case low, medium, high, critical
    
    var color: Color {
        switch self {
        case .low: return Color(hex: "FFD60A")
        case .medium: return Color(hex: "FF9F0A")
        case .high: return Color(hex: "FF453A")
        case .critical: return Color(hex: "FF453A")
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "exclamationmark.triangle.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }
}

struct ContractTerm: Identifiable {
    let id = UUID()
    let term: String
    let value: String
    let status: TermStatus
}

enum TermStatus {
    case good, neutral, bad
    
    var color: Color {
        switch self {
        case .good: return Color(hex: "32D74B")
        case .neutral: return Color(hex: "FFD60A")
        case .bad: return Color(hex: "FF453A")
        }
    }
    
    var icon: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .neutral: return "minus.circle.fill"
        case .bad: return "xmark.circle.fill"
        }
    }
}
