import SwiftUI

// MARK: - Core Message Types
public enum MessageStatus {
    case sending
    case sent
    case delivered
    case read
    case failed
}

public enum MessageSender {
    case currentUser
    case otherUser
    case system
}

// MARK: - Message Protocol
public protocol ChatMessage: Identifiable {
    var id: String { get }
    var timestamp: Date { get }
    var sender: MessageSender { get }
    var status: MessageStatus { get }
}

// MARK: - Content Protocols
public protocol TextMessage: ChatMessage {
    var text: String { get }
}

public protocol MediaMessage: ChatMessage {
    associatedtype Attachment: ChatAttachment
    var attachments: [Attachment] { get }
}

public protocol ReactableMessage: ChatMessage {
    var reactions: [Reaction] { get }
}

