import Foundation

class iCloudFileHandler {
    static let shared = iCloudFileHandler()
    
    private init() {}
    
    /// Handles iCloud file download and returns when file is ready
    func prepareFile(at url: URL, completion: @escaping (URL?) -> Void) {
        // Start accessing security-scoped resource
        let hasAccess = url.startAccessingSecurityScopedResource()
        
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // Check if file is in iCloud and needs to be downloaded
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey])
            let isUbiquitous = resourceValues.isUbiquitousItem ?? false
            
            if isUbiquitous {
                let downloadStatus = resourceValues.ubiquitousItemDownloadingStatus
                print("📱 iCloud file detected: \(url.lastPathComponent)")
                print("   Download status: \(downloadStatus?.rawValue ?? "unknown")")
                
                // If not downloaded, start download
                if downloadStatus != .current {
                    print("⬇️ Starting iCloud download...")
                    try FileManager.default.startDownloadingUbiquitousItem(at: url)
                    
                    // Wait and check download status
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.checkDownloadStatus(url: url, completion: completion)
                    }
                    return
                } else {
                    print("✅ iCloud file already downloaded")
                }
            }
            
            // Copy file to temporary location for app access
            let tempDir = FileManager.default.temporaryDirectory
            let tempFileURL = tempDir.appendingPathComponent(url.lastPathComponent)
            
            // Remove existing temp file if it exists
            if FileManager.default.fileExists(atPath: tempFileURL.path) {
                try? FileManager.default.removeItem(at: tempFileURL)
            }
            
            // Copy file to temp location
            try FileManager.default.copyItem(at: url, to: tempFileURL)
            print("✅ File copied to temporary location: \(tempFileURL.lastPathComponent)")
            
            // Return temp file URL
            completion(tempFileURL)
            
        } catch {
            print("❌ Error preparing file: \(error)")
            print("   Attempting to use original URL...")
            // Try to use the URL anyway
            completion(url)
        }
    }
    
    private func checkDownloadStatus(url: URL, completion: @escaping (URL?) -> Void, attempt: Int = 1) {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            let downloadStatus = resourceValues.ubiquitousItemDownloadingStatus
            
            if downloadStatus == .current {
                print("✅ iCloud file downloaded successfully after \(attempt) attempt(s)")
                completion(url)
            } else if attempt < 10 {
                print("⏳ Still downloading... Attempt \(attempt)/10")
                // Check again in 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkDownloadStatus(url: url, completion: completion, attempt: attempt + 1)
                }
            } else {
                print("❌ Download timeout after 10 attempts")
                // Try to use the URL anyway
                completion(url)
            }
        } catch {
            print("❌ Error checking download status: \(error)")
            // Try to use the URL anyway
            completion(url)
        }
    }
    
    /// Async version for modern Swift concurrency
    func prepareFile(at url: URL) async -> URL? {
        await withCheckedContinuation { continuation in
            prepareFile(at: url) { preparedURL in
                continuation.resume(returning: preparedURL)
            }
        }
    }
}
