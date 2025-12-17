import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    struct RegisterRequest: Encodable {
        let email: String
        let password: String
        let name: String
        let artistName: String
    }
    
    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }
    
    struct AuthResponse: Decodable {
        let success: Bool
        let data: AuthData
        let message: String?
        
        struct AuthData: Decodable {
            let user: User
            let accessToken: String
            let refreshToken: String
        }
    }
    
    struct User: Decodable {
        let id: String
        let email: String
        let name: String
        let artistName: String
        let subscriptionPlan: String
    }
    
    @MainActor
    func register(email: String, password: String, name: String, artistName: String) async throws -> User {
        let request = RegisterRequest(
            email: email,
            password: password,
            name: name,
            artistName: artistName
        )
        
        let response: AuthResponse = try await NetworkManager.shared.request(
            endpoint: "/auth/register",
            method: .post,
            body: request
        )
        
        KeychainManager.shared.saveAccessToken(response.data.accessToken)
        KeychainManager.shared.saveRefreshToken(response.data.refreshToken)
        KeychainManager.shared.saveUserId(response.data.user.id)
        
        return response.data.user
    }
    
    @MainActor
    func login(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, password: password)
        
        let response: AuthResponse = try await NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: .post,
            body: request
        )
        
        KeychainManager.shared.saveAccessToken(response.data.accessToken)
        KeychainManager.shared.saveRefreshToken(response.data.refreshToken)
        KeychainManager.shared.saveUserId(response.data.user.id)
        
        return response.data.user
    }
    
    @MainActor
    func logout() {
        KeychainManager.shared.clearAll()
    }
    
    func isLoggedIn() -> Bool {
        return KeychainManager.shared.getAccessToken() != nil
    }
}
