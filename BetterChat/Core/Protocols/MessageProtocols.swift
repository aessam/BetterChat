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

/// The base protocol for all messages in BetterChat.
///
/// `ChatMessage` defines the core properties that every message must have.
/// It serves as the foundation for more specialized message types like
/// ``TextMessage``, ``MediaMessage``, and ``ReactableMessage``.
///
/// ## Implementation Example
///
/// ```swift
/// struct MyMessage: ChatMessage {
///     let id: String
///     let timestamp: Date
///     let sender: MessageSender
///     var status: MessageStatus = .sent
/// }
/// ```
///
/// ## Specialized Message Types
///
/// For messages with specific capabilities, conform to additional protocols:
/// - ``TextMessage`` for text content
/// - ``MediaMessage`` for attachments
/// - ``ReactableMessage`` for emoji reactions
///
/// - Note: The `id` property must be unique across all messages in a conversation.
/// - Important: `status` should reflect the current delivery state of the message.
public protocol ChatMessage: Identifiable {
    /// Unique identifier for the message.
    var id: String { get }
    
    /// When the message was created or received.
    var timestamp: Date { get }
    
    /// Who sent the message (user, assistant, or system).
    var sender: MessageSender { get }
    
    /// Current delivery status of the message.
    var status: MessageStatus { get }
}
