import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://consigliary-production.up.railway.app/api/v1"
    private var isRefreshing = false
    private var refreshLock = NSLock()
    
    private init() {}
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError
        case serverError(String)
        case unauthorized
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .serverError(let message):
                return message
            case .unauthorized:
                return "Unauthorized - please log in again"
            }
        }
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = false,
        isRetry: Bool = false
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = KeychainManager.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        print("📡 API Response: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📦 Response Data: \(responseString)")
        }
        
        if httpResponse.statusCode == 401 {
            // Try to refresh token if this isn't already a retry
            if !isRetry, requiresAuth {
                print("🔄 Access token expired (401), attempting refresh...")
                print("   Endpoint: \(endpoint)")
                do {
                    try await refreshAccessToken()
                    print("✅ Token refreshed successfully, retrying original request...")
                    // Retry the original request with new token
                    return try await self.request(
                        endpoint: endpoint,
                        method: method,
                        body: body,
                        requiresAuth: requiresAuth,
                        isRetry: true
                    )
                } catch let refreshError {
                    print("❌ Token refresh failed: \(refreshError)")
                    if let networkError = refreshError as? NetworkError {
                        print("   Error type: \(networkError.localizedDescription)")
                    }
                    throw NetworkError.unauthorized
                }
            }
            print("⚠️ 401 error but cannot refresh (isRetry=\(isRetry), requiresAuth=\(requiresAuth))")
            throw NetworkError.unauthorized
        }
        
        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.error.message)
            }
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(T.self, from: data)
            print("✅ Successfully decoded response")
            return result
        } catch {
            print("❌ Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                print("Decoding error details: \(decodingError)")
            }
            throw NetworkError.decodingError
        }
    }
    
    private func refreshAccessToken() async throws {
        // Prevent concurrent refresh attempts
        refreshLock.lock()
        if isRefreshing {
            refreshLock.unlock()
            // Wait a bit for the ongoing refresh to complete
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            return
        }
        isRefreshing = true
        refreshLock.unlock()
        
        defer {
            refreshLock.lock()
            isRefreshing = false
            refreshLock.unlock()
        }
        
        print("🔐 Attempting to retrieve refresh token from Keychain...")
        guard let refreshToken = KeychainManager.shared.getRefreshToken() else {
            print("❌ No refresh token found in Keychain")
            throw NetworkError.unauthorized
        }
        print("✅ Refresh token retrieved (length: \(refreshToken.count))")
        print("   Token preview: \(refreshToken.prefix(50))...")
        
        struct RefreshRequest: Encodable {
            let refreshToken: String
        }
        
        struct RefreshResponse: Decodable {
            let success: Bool
            let data: TokenData
            
            struct TokenData: Decodable {
                let accessToken: String
            }
        }
        
        guard let url = URL(string: baseURL + "/auth/refresh") else {
            print("❌ Invalid refresh URL")
            throw NetworkError.invalidURL
        }
        
        print("🌐 Calling refresh endpoint: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(RefreshRequest(refreshToken: refreshToken))
        } catch {
            print("❌ Failed to encode refresh request: \(error)")
            throw NetworkError.serverError("Failed to encode refresh request")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response from refresh endpoint")
            throw NetworkError.noData
        }
        
        print("📡 Refresh endpoint response: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📦 Refresh response data: \(responseString)")
        }
        
        if httpResponse.statusCode != 200 {
            print("❌ Refresh failed with status \(httpResponse.statusCode)")
            throw NetworkError.unauthorized
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let refreshResponse = try decoder.decode(RefreshResponse.self, from: data)
            print("✅ Successfully decoded refresh response")
            print("   New access token length: \(refreshResponse.data.accessToken.count)")
            
            // Save new access token
            KeychainManager.shared.saveAccessToken(refreshResponse.data.accessToken)
            print("✅ New access token saved to Keychain")
        } catch {
            print("❌ Failed to decode refresh response: \(error)")
            throw NetworkError.decodingError
        }
    }
}

struct ErrorResponse: Decodable {
    let success: Bool
    let error: ErrorDetail
    
    struct ErrorDetail: Decodable {
        let code: String
        let message: String
    }
}
