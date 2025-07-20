import SwiftUI

public protocol AttachmentItem {
    var id: String { get }
    var displayName: String { get }
}

public struct AttachmentAction {
    public let title: String
    public let icon: Image
    public let action: () async -> AttachmentItem?
    
    public init(title: String, icon: Image, action: @escaping () async -> AttachmentItem?) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}