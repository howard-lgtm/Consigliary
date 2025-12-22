import Foundation

class RevenueService {
    static let shared = RevenueService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Models
    
    struct RevenueEvent: Codable, Identifiable {
        let id: String
        let userId: String
        let trackId: String?
        let licenseId: String?
        let source: String
        let amount: String
        let currency: String
        let date: Date
        let description: String?
        let platform: String?
        let paymentStatus: String
        let createdAt: Date
    }
    
    struct RevenueSummary: Codable {
        let totalRevenue: String
        let totalStreams: Int
        let totalLicenses: Int
        let revenueBySource: [String: String]
        let recentEvents: [RevenueEvent]
    }
    
    struct RevenueResponse: Decodable {
        let success: Bool
        let data: RevenueData
        
        struct RevenueData: Decodable {
            let events: [RevenueEvent]
        }
    }
    
    struct RevenueSummaryResponse: Decodable {
        let success: Bool
        let data: RevenueSummary
    }
    
    // MARK: - API Methods
    
    func getRevenueEvents() async throws -> [RevenueEvent] {
        let response: RevenueResponse = try await networkManager.request(
            endpoint: "/revenue",
            method: .get,
            requiresAuth: true
        )
        
        return response.data.events
    }
    
    func getRevenueSummary() async throws -> RevenueSummary {
        let response: RevenueSummaryResponse = try await networkManager.request(
            endpoint: "/revenue/summary",
            method: .get,
            requiresAuth: true
        )
        
        return response.data
    }
    
    func getRevenueByTrack(trackId: String) async throws -> [RevenueEvent] {
        let response: RevenueResponse = try await networkManager.request(
            endpoint: "/revenue?trackId=\(trackId)",
            method: .get,
            requiresAuth: true
        )
        
        return response.data.events
    }
}
