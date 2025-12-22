import Foundation

class LicenseService {
    static let shared = LicenseService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Models
    
    struct License: Codable, Identifiable {
        let id: String
        let userId: String
        let trackId: String
        let verificationId: String?
        let licenseeName: String?
        let licenseeEmail: String
        let licenseePlatform: String?
        let licenseeChannelUrl: String?
        let licenseFee: String
        let currency: String
        let territory: String
        let duration: String?
        let exclusivity: String?
        let stripeInvoiceId: String?
        let stripePaymentIntentId: String?
        let paymentStatus: String
        let paidAt: Date?
        let pdfUrl: String?
        let status: String
        let sentAt: Date?
        let signedAt: Date?
        let expiresAt: Date?
        let createdAt: Date
        let updatedAt: Date
    }
    
    struct CreateLicenseRequest: Encodable {
        let trackId: String
        let verificationId: String?
        let licenseeName: String?
        let licenseeEmail: String
        let licenseePlatform: String?
        let licenseeChannelUrl: String?
        let licenseFee: Double
        let currency: String
        let territory: String
        let duration: String
        let exclusivity: String
        let sendEmail: Bool
    }
    
    struct LicenseResponse: Decodable {
        let success: Bool
        let data: LicenseData
        let message: String
        
        struct LicenseData: Decodable {
            let license: License
            let pdfUrl: String?
            let stripeInvoiceUrl: String?
            let stripeInvoiceId: String?
            let emailSent: Bool?
        }
    }
    
    struct LicensesResponse: Decodable {
        let success: Bool
        let data: LicensesData
        
        struct LicensesData: Decodable {
            let licenses: [License]
        }
    }
    
    struct UpdateLicenseRequest: Encodable {
        let status: String?
        let paymentStatus: String?
    }
    
    // MARK: - API Methods
    
    func createLicense(
        trackId: String,
        verificationId: String? = nil,
        licenseeName: String? = nil,
        licenseeEmail: String,
        licenseePlatform: String? = nil,
        licenseeChannelUrl: String? = nil,
        licenseFee: Double,
        currency: String = "USD",
        territory: String = "Worldwide",
        duration: String = "Perpetual",
        exclusivity: String = "non-exclusive",
        sendEmail: Bool = true
    ) async throws -> LicenseResponse.LicenseData {
        let request = CreateLicenseRequest(
            trackId: trackId,
            verificationId: verificationId,
            licenseeName: licenseeName,
            licenseeEmail: licenseeEmail,
            licenseePlatform: licenseePlatform,
            licenseeChannelUrl: licenseeChannelUrl,
            licenseFee: licenseFee,
            currency: currency,
            territory: territory,
            duration: duration,
            exclusivity: exclusivity,
            sendEmail: sendEmail
        )
        
        let response: LicenseResponse = try await networkManager.request(
            endpoint: "/licenses",
            method: .post,
            body: request,
            requiresAuth: true
        )
        
        return response.data
    }
    
    func getLicenses() async throws -> [License] {
        let response: LicensesResponse = try await networkManager.request(
            endpoint: "/licenses",
            method: .get,
            requiresAuth: true
        )
        
        return response.data.licenses
    }
    
    func getLicense(id: String) async throws -> License {
        struct SingleLicenseResponse: Decodable {
            let success: Bool
            let data: LicenseData
            
            struct LicenseData: Decodable {
                let license: License
            }
        }
        
        let response: SingleLicenseResponse = try await networkManager.request(
            endpoint: "/licenses/\(id)",
            method: .get,
            requiresAuth: true
        )
        
        return response.data.license
    }
    
    func updateLicense(
        id: String,
        status: String? = nil,
        paymentStatus: String? = nil
    ) async throws -> License {
        let request = UpdateLicenseRequest(
            status: status,
            paymentStatus: paymentStatus
        )
        
        struct UpdateResponse: Decodable {
            let success: Bool
            let data: LicenseData
            let message: String
            
            struct LicenseData: Decodable {
                let license: License
            }
        }
        
        let response: UpdateResponse = try await networkManager.request(
            endpoint: "/licenses/\(id)",
            method: .put,
            body: request,
            requiresAuth: true
        )
        
        return response.data.license
    }
}
