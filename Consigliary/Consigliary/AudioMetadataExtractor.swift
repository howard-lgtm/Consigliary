import Foundation
import AVFoundation

struct AudioMetadata {
    var title: String?
    var artist: String?
    var albumArtist: String?
    var album: String?
    var genre: String?
    var year: String?
    var duration: String?
    var composer: String?
    var copyright: String?
    var isrc: String?
}

class AudioMetadataExtractor {
    static func extractMetadata(from url: URL) -> AudioMetadata {
        var metadata = AudioMetadata()
        
        let asset = AVAsset(url: url)
        
        // Get duration
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        if durationSeconds.isFinite && durationSeconds > 0 {
            let minutes = Int(durationSeconds) / 60
            let seconds = Int(durationSeconds) % 60
            metadata.duration = String(format: "%d:%02d", minutes, seconds)
        }
        
        // Get metadata items
        let metadataItems = asset.commonMetadata
        
        for item in metadataItems {
            guard let key = item.commonKey?.rawValue,
                  let value = item.value as? String else { continue }
            
            switch key {
            case AVMetadataKey.commonKeyTitle.rawValue:
                metadata.title = value
                print("📝 Title: \(value)")
                
            case AVMetadataKey.commonKeyArtist.rawValue:
                metadata.artist = value
                print("🎤 Artist: \(value)")
                
            case AVMetadataKey.commonKeyAlbumName.rawValue:
                metadata.album = value
                print("💿 Album: \(value)")
                
            case AVMetadataKey.commonKeyCreationDate.rawValue:
                // Extract year from date
                if let year = extractYear(from: value) {
                    metadata.year = year
                    print("📅 Year: \(year)")
                }
                
            case AVMetadataKey.commonKeyCreator.rawValue,
                 AVMetadataKey.commonKeyAuthor.rawValue:
                if metadata.composer == nil {
                    metadata.composer = value
                    print("✍️ Composer: \(value)")
                }
                
            case AVMetadataKey.commonKeyCopyrights.rawValue:
                metadata.copyright = value
                print("© Copyright: \(value)")
                
            default:
                break
            }
        }
        
        // Try to get additional metadata from format-specific tags
        for format in asset.availableMetadataFormats {
            let formatMetadata = asset.metadata(forFormat: format)
            
            for item in formatMetadata {
                if let key = item.key as? String {
                    // ID3 tags for MP3
                    if format == .id3Metadata {
                        switch key {
                        case "TALB": // Album
                            if metadata.album == nil, let value = item.stringValue {
                                metadata.album = value
                            }
                        case "TPE1": // Artist
                            if metadata.artist == nil, let value = item.stringValue {
                                metadata.artist = value
                            }
                        case "TPE2": // Album Artist
                            if let value = item.stringValue {
                                metadata.albumArtist = value
                            }
                        case "TIT2": // Title
                            if metadata.title == nil, let value = item.stringValue {
                                metadata.title = value
                            }
                        case "TYER", "TDRC": // Year
                            if metadata.year == nil, let value = item.stringValue {
                                metadata.year = extractYear(from: value) ?? value
                            }
                        case "TCON": // Genre
                            if let value = item.stringValue {
                                metadata.genre = value
                            }
                        case "TCOM": // Composer
                            if metadata.composer == nil, let value = item.stringValue {
                                metadata.composer = value
                            }
                        case "TCOP": // Copyright
                            if metadata.copyright == nil, let value = item.stringValue {
                                metadata.copyright = value
                            }
                        case "TSRC": // ISRC
                            if let value = item.stringValue {
                                metadata.isrc = value
                                print("🔢 ISRC: \(value)")
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        print("✅ Metadata extraction complete")
        return metadata
    }
    
    private static func extractYear(from dateString: String) -> String? {
        // Try to extract 4-digit year from various date formats
        let yearPattern = "\\b(19|20)\\d{2}\\b"
        if let regex = try? NSRegularExpression(pattern: yearPattern),
           let match = regex.firstMatch(in: dateString, range: NSRange(dateString.startIndex..., in: dateString)) {
            if let range = Range(match.range, in: dateString) {
                return String(dateString[range])
            }
        }
        return nil
    }
}
