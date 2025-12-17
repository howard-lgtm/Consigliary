import Foundation
import Combine

struct Verification: Codable, Identifiable {
    let id: String
    let userId: String
    let trackId: String?
    let platform: String
    let videoUrl: String
    let videoId: String?
    let matchFound: Bool
    let confidenceScore: Double?
    let matchedTrackTitle: String?
    let matchedArtist: String?
    let videoTitle: String?
    let channelName: String?
    let channelUrl: String?
    let viewCount: Int?
    let uploadDate: String?
    let audioSampleUrl: String?
    let status: String
    let reviewedAt: String?
    let createdAt: String
    let trackTitle: String?
    let artistName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case trackId = "track_id"
        case platform
        case videoUrl = "video_url"
        case videoId = "video_id"
        case matchFound = "match_found"
        case confidenceScore = "confidence_score"
        case matchedTrackTitle = "matched_track_title"
        case matchedArtist = "matched_artist"
        case videoTitle = "video_title"
        case channelName = "channel_name"
        case channelUrl = "channel_url"
        case viewCount = "view_count"
        case uploadDate = "upload_date"
        case audioSampleUrl = "audio_sample_url"
        case status
        case reviewedAt = "reviewed_at"
        case createdAt = "created_at"
        case trackTitle = "track_title"
        case artistName = "artist_name"
    }
}

struct VerificationResponse: Codable {
    let success: Bool
    let data: Verification
    let message: String?
}

struct VerificationsResponse: Codable {
    let success: Bool
    let data: [Verification]
}

struct VerificationDeleteResponse: Codable {
    let success: Bool
    let message: String
}

struct CreateVerificationRequest: Encodable {
    let videoUrl: String
    let trackId: String?
}

struct UpdateVerificationStatusRequest: Encodable {
    let status: String
}

@MainActor
class VerificationService: ObservableObject {
    static let shared = VerificationService()
    
    private init() {}
    
    func createVerification(videoUrl: String, trackId: String?) async throws -> Verification {
        let request = CreateVerificationRequest(
            videoUrl: videoUrl,
            trackId: trackId
        )
        
        let response: VerificationResponse = try await NetworkManager.shared.request(
            endpoint: "/verifications",
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.data
    }
    
    func getVerifications() async throws -> [Verification] {
        let response: VerificationsResponse = try await NetworkManager.shared.request(
            endpoint: "/verifications",
            method: .get,
            requiresAuth: true
        )
        return response.data
    }
    
    func getVerification(id: String) async throws -> Verification {
        let response: VerificationResponse = try await NetworkManager.shared.request(
            endpoint: "/verifications/\(id)",
            method: .get,
            requiresAuth: true
        )
        return response.data
    }
    
    func getTrackVerifications(trackId: String) async throws -> [Verification] {
        let response: VerificationsResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks/\(trackId)/verifications",
            method: .get,
            requiresAuth: true
        )
        return response.data
    }
    
    func updateVerificationStatus(id: String, status: String) async throws -> Verification {
        let request = UpdateVerificationStatusRequest(status: status)
        
        let response: VerificationResponse = try await NetworkManager.shared.request(
            endpoint: "/verifications/\(id)/status",
            method: .put,
            body: request,
            requiresAuth: true
        )
        return response.data
    }
    
    func deleteVerification(id: String) async throws {
        let _: VerificationDeleteResponse = try await NetworkManager.shared.request(
            endpoint: "/verifications/\(id)",
            method: .delete,
            requiresAuth: true
        )
    }
}
