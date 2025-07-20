import SwiftUI

// MARK: - Demo Message Implementation
public struct DemoMessage: ChatMessage, TextMessage, ReactableMessage, MediaMessage {
    public let id: String
    public let timestamp: Date
    public let sender: MessageSender
    public let status: MessageStatus
    public let text: String
    public let reactions: [Reaction]
    public let attachments: [ImageAttachment]
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        sender: MessageSender,
        status: MessageStatus = .sent,
        text: String,
        reactions: [Reaction] = [],
        attachments: [ImageAttachment] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sender = sender
        self.status = status
        self.text = text
        self.reactions = reactions
        self.attachments = attachments
    }
}