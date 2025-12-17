import Foundation

struct Contributor: Codable, Identifiable {
    let id: String
    let trackId: String
    let name: String
    let role: String?
    let splitPercentage: Double
    let email: String?
    let proAffiliation: String?
    let signedAt: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case trackId = "track_id"
        case name
        case role
        case splitPercentage = "split_percentage"
        case email
        case proAffiliation = "pro_affiliation"
        case signedAt = "signed_at"
        case createdAt = "created_at"
    }
}
