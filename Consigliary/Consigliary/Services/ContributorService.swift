import Foundation
import Combine

struct ContributorResponse: Codable {
    let success: Bool
    let data: Contributor
    let message: String?
}

struct ContributorsResponse: Codable {
    let success: Bool
    let data: [Contributor]
}

struct SplitSheetResponse: Codable {
    let success: Bool
    let data: SplitSheet
}

struct ContributorDeleteResponse: Codable {
    let success: Bool
    let message: String
}

struct AddContributorRequest: Encodable {
    let name: String
    let role: String?
    let splitPercentage: Double
    let email: String?
    let proAffiliation: String?
}

struct UpdateContributorRequest: Encodable {
    let name: String?
    let role: String?
    let splitPercentage: Double?
    let email: String?
    let proAffiliation: String?
}

@MainActor
class ContributorService: ObservableObject {
    static let shared = ContributorService()
    
    private init() {}
    
    func getContributors(trackId: String) async throws -> [Contributor] {
        let response: ContributorsResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks/\(trackId)/contributors",
            method: .get,
            requiresAuth: true
        )
        return response.data
    }
    
    func addContributor(
        trackId: String,
        name: String,
        role: String?,
        splitPercentage: Double,
        email: String?,
        proAffiliation: String?
    ) async throws -> Contributor {
        let request = AddContributorRequest(
            name: name,
            role: role,
            splitPercentage: splitPercentage,
            email: email,
            proAffiliation: proAffiliation
        )
        
        let response: ContributorResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks/\(trackId)/contributors",
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.data
    }
    
    func updateContributor(
        id: String,
        name: String?,
        role: String?,
        splitPercentage: Double?,
        email: String?,
        proAffiliation: String?
    ) async throws -> Contributor {
        let request = UpdateContributorRequest(
            name: name,
            role: role,
            splitPercentage: splitPercentage,
            email: email,
            proAffiliation: proAffiliation
        )
        
        let response: ContributorResponse = try await NetworkManager.shared.request(
            endpoint: "/contributors/\(id)",
            method: .put,
            body: request,
            requiresAuth: true
        )
        return response.data
    }
    
    func deleteContributor(id: String) async throws {
        let _: ContributorDeleteResponse = try await NetworkManager.shared.request(
            endpoint: "/contributors/\(id)",
            method: .delete,
            requiresAuth: true
        )
    }
    
    func getSplitSheet(trackId: String) async throws -> SplitSheet {
        let response: SplitSheetResponse = try await NetworkManager.shared.request(
            endpoint: "/tracks/\(trackId)/split-sheet",
            method: .get,
            requiresAuth: true
        )
        return response.data
    }
}
