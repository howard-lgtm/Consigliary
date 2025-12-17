import Foundation

struct SplitSheet: Codable {
    let track: TrackInfo
    let contributors: [Contributor]
    let totalSplitPercentage: Double
    let remainingSplitPercentage: Double
    let isComplete: Bool
    
    struct TrackInfo: Codable {
        let userId: String
        let title: String
        let artistName: String
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case title
            case artistName = "artist_name"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case track
        case contributors
        case totalSplitPercentage = "total_split_percentage"
        case remainingSplitPercentage = "remaining_split_percentage"
        case isComplete = "is_complete"
    }
}
