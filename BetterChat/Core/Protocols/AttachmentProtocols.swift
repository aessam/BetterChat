import SwiftUI

// MARK: - Attachment System
public protocol ChatAttachment: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var size: Int64? { get }
}

// MARK: - Attachment Types
public struct ImageAttachment: ChatAttachment {
    public let id: String
    public let displayName: String
    public let size: Int64?
    public let image: Image
    public let thumbnail: Image?
    
    public init(id: String = UUID().uuidString, displayName: String, size: Int64? = nil, image: Image, thumbnail: Image? = nil) {
        self.id = id
        self.displayName = displayName
        self.size = size
        self.image = image
        self.thumbnail = thumbnail
    }
}

public struct LinkAttachment: ChatAttachment {
    public let id: String
    public let displayName: String
    public let size: Int64?
    public let url: URL
    public let title: String?
    public let description: String?
    public let thumbnail: Image?
    
    public init(id: String = UUID().uuidString, displayName: String, size: Int64? = nil, url: URL, title: String? = nil, description: String? = nil, thumbnail: Image? = nil) {
        self.id = id
        self.displayName = displayName
        self.size = size
        self.url = url
        self.title = title
        self.description = description
        self.thumbnail = thumbnail
    }
}

// MARK: - Attachment Actions
public struct AttachmentAction {
    public let title: String
    public let icon: Image
    public let action: () async -> Any?
    
    public init(title: String, icon: Image, action: @escaping () async -> Any?) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}