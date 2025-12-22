import Foundation
import Combine

class TrackService: ObservableObject {
    static let shared = TrackService()
    
    private init() {}
    
    struct CreateTrackRequest: Encodable {
        let title: String
        let artistName: String
        let duration: String?
        let releaseDate: String?
        let isrcCode: String?
        let upcCode: String?
        let copyrightOwner: String?
        let copyrightYear: String?
        let publisher: String?
        let copyrightRegNumber: String?
        let proAffiliation: String?
        let spotifyUrl: String?
        let appleMusicUrl: String?
        let soundcloudUrl: String?
        let drmStatus: String?
        let licenseType: String?
        let territory: String?
        let masterFileLocation: String?
        let contributors: [ContributorRequest]?
        
        struct ContributorRequest: Encodable {
            let name: String
            let role: String?
            let splitPercentage: Double
            let email: String?
            let proAffiliation: String?
        }
    }
    
    struct TrackResponse: Decodable {
        let success: Bool
        let data: TrackData
        let message: String?
        
        struct TrackData: Decodable {
            let track: Track
        }
    }
    
    struct TracksResponse: Decodable {
        let success: Bool
        let data: TracksData
        
        struct TracksData: Decodable {
            let tracks: [Track]
        }
    }
    
    struct Track: Decodable, Identifiable {
        let id: String
        let title: String
        let artistName: String
        let duration: String?
        let releaseDate: String?
        let isrcCode: String?
        let spotifyUrl: String?
        let appleMusicUrl: String?
        let soundcloudUrl: String?
        let streams: Int?
        let revenue: String?  // Backend returns as string (DECIMAL type)
        let createdAt: String?
        let updatedAt: String?
        
        var revenueValue: Double? {
            guard let revenue = revenue else { return nil }
            return Double(revenue)
        }
    }
    
    @MainActor
    func createTrack(
        title: String,
        artistName: String,
        duration: String? = nil,
        releaseDate: String? = nil,
        isrcCode: String? = nil,
        upcCode: String? = nil,
        copyrightOwner: String? = nil,
        copyrightYear: String? = nil,
        publisher: String? = nil,
        copyrightRegNumber: String? = nil,
        proAffiliation: String? = nil,
        spotifyUrl: String? = nil,
        appleMusicUrl: String? = nil,
        soundcloudUrl: String? = nil,
        drmStatus: String? = nil,
        licenseType: String? = nil,
        territory: String? = nil,
        masterFileLocation: String? = nil,
        contributors: [CreateTrackRequest.ContributorRequest]? = nil
    ) async throws -> Track {
        let request = CreateTrackRequest(
            title: title,
            artistName: artistName,
            duration: duration,
            releaseDate: releaseDate,
            isrcCode: isrcCode,
            upcCode: upcCode,
            copyrightOwner: copyrightOwner,
            copyrightYear: copyrightYear,
            publisher: publisher,
            copyrightRegNumber: copyrightRegNumber,
            proAffiliation: proAffiliation,
            spotifyUrl: spotifyUrl,
            appleMusicUrl: appleMusicUrl,
            soundcloudUrl: soundcloudUrl,
            drmStatus: drmStatus,
            licenseType: licenseType,
            territory: territory,
            masterFileLocation: masterFileLocation,
            contributors: contributors
        )
        
        let response: TrackResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks",
            method: .post,
            body: request,
            requiresAuth: true
        )
        
        return response.data.track
    }
    
    @MainActor
    func getTracks() async throws -> [Track] {
        let response: TracksResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks",
            method: .get,
            requiresAuth: true
        )
        
        return response.data.tracks
    }
    
    @MainActor
    func getTrack(id: String) async throws -> Track {
        let response: TrackResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks/\(id)",
            method: .get,
            requiresAuth: true
        )
        
        return response.data.track
    }
    
    @MainActor
    func deleteTrack(id: String) async throws {
        struct DeleteResponse: Decodable {
            let success: Bool
            let message: String
        }
        
        let _: DeleteResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks/\(id)",
            method: .delete,
            requiresAuth: true
        )
    }
    
    @MainActor
    func uploadAudio(trackId: String, audioFileURL: URL) async throws -> AudioUploadResponse {
        print("🔍 Starting audio upload for track \(trackId)")
        
        // Start accessing security-scoped resource
        let didStartAccessing = audioFileURL.startAccessingSecurityScopedResource()
        
        defer {
            if didStartAccessing {
                audioFileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        // Read audio file data
        let audioData: Data
        do {
            audioData = try Data(contentsOf: audioFileURL)
            print("📁 Read \(audioData.count) bytes from audio file")
        } catch {
            print("❌ Failed to read audio file: \(error)")
            throw error
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        var body = Data()
        
        // Add audio file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(audioFileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        print("📦 Created multipart body: \(body.count) bytes")
        
        // Get auth token
        guard let token = KeychainManager.shared.getAccessToken() else {
            print("❌ No access token found")
            throw NetworkError.unauthorized
        }
        
        // Create request
        let baseURL = "https://consigliary-production.up.railway.app/api/v1"
        guard let url = URL(string: "\(baseURL)/tracks/\(trackId)/upload-audio") else {
            print("❌ Invalid URL")
            throw NetworkError.invalidURL
        }
        
        print("🌐 Uploading to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 120 // 2 minutes for large files
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response")
            throw NetworkError.invalidResponse
        }
        
        print("📡 Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Server error response: \(responseString)")
            }
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(AudioUploadResponse.self, from: data)
    }
    
    struct AudioUploadResponse: Decodable {
        let success: Bool
        let data: AudioUploadData
        let message: String
        
        struct AudioUploadData: Decodable {
            let audioUrl: String
            let fingerprintId: String?
            let fingerprintGenerated: Bool
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case invalidResponse
    case serverError(Int)
}
