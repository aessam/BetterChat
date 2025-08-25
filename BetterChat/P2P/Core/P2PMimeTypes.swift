import Foundation

/// Standard MIME types for P2P message payloads
public enum P2PMimeType {
    // Text formats
    public static let text = "text/plain"
    public static let markdown = "text/markdown"
    public static let html = "text/html"
    public static let rtf = "text/rtf"
    
    // Image formats
    public static let imageJPEG = "image/jpeg"
    public static let imagePNG = "image/png"
    public static let imageGIF = "image/gif"
    public static let imageHEIC = "image/heic"
    public static let imageSVG = "image/svg+xml"
    
    // Audio/Video formats
    public static let audioMPEG = "audio/mpeg"
    public static let audioWAV = "audio/wav"
    public static let videoMP4 = "video/mp4"
    public static let videoQuicktime = "video/quicktime"
    
    // Application-specific types
    public static let userProfile = "application/x-user-profile"
    public static let reaction = "application/x-reaction"
    public static let typingIndicator = "application/x-typing"
    public static let location = "application/x-location"
    public static let contact = "application/x-contact"
    public static let poll = "application/x-poll"
    public static let gameMove = "application/x-game-move"
    public static let systemMessage = "application/x-system"
    public static let receipt = "application/x-receipt"
    public static let edit = "application/x-edit"
    public static let delete = "application/x-delete"
    
    // Composite types
    public static let multipart = "multipart/mixed"
    public static let multipartAlternative = "multipart/alternative"
    public static let multipartRelated = "multipart/related"
    
    // Document formats
    public static let pdf = "application/pdf"
    public static let json = "application/json"
    public static let xml = "application/xml"
    public static let zip = "application/zip"
    
    /// Check if a MIME type represents text content
    public static func isText(_ mimeType: String) -> Bool {
        mimeType.hasPrefix("text/")
    }
    
    /// Check if a MIME type represents image content
    public static func isImage(_ mimeType: String) -> Bool {
        mimeType.hasPrefix("image/")
    }
    
    /// Check if a MIME type represents audio content
    public static func isAudio(_ mimeType: String) -> Bool {
        mimeType.hasPrefix("audio/")
    }
    
    /// Check if a MIME type represents video content
    public static func isVideo(_ mimeType: String) -> Bool {
        mimeType.hasPrefix("video/")
    }
    
    /// Check if a MIME type is multipart
    public static func isMultipart(_ mimeType: String) -> Bool {
        mimeType.hasPrefix("multipart/")
    }
    
    /// Extract the main type from a MIME type (e.g., "text" from "text/plain")
    public static func mainType(from mimeType: String) -> String? {
        mimeType.split(separator: "/").first.map(String.init)
    }
    
    /// Extract the subtype from a MIME type (e.g., "plain" from "text/plain")
    public static func subType(from mimeType: String) -> String? {
        let parts = mimeType.split(separator: "/")
        guard parts.count >= 2 else { return nil }
        return String(parts[1].split(separator: ";").first ?? "")
    }
}