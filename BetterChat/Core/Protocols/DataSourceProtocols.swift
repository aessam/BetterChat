import SwiftUI

// MARK: - Data Source Protocols

// Protocol for providing chat data
public protocol ChatDataProvider {
    associatedtype Message: ChatMessage
    
    var messages: [Message] { get }
    var isTyping: Bool { get }
    var isThinking: Bool { get }
    var currentThoughts: [ThinkingThought] { get }
    var completedThinkingSessions: [ThinkingSession] { get }
}

// Protocol for handling user actions
public protocol ChatActionHandler {
    associatedtype Message: ChatMessage
    associatedtype Attachment: ChatAttachment
    
    func sendMessage(text: String, attachments: [Attachment])
    func retryMessage(_ message: Message)
    func reactToMessage(_ message: Message, reaction: String)
    func removeReaction(from message: Message, reaction: String)
}


/// The main protocol for implementing chat data sources in BetterChat.
///
/// `ChatDataSource` combines data provision and action handling capabilities,
/// providing everything needed to power a chat interface. Implementations
/// should manage message storage, handle user interactions, and provide
/// real-time updates through the `ObservableObject` protocol.
///
/// ## Implementation Example
///
/// ```swift
/// class MyDataSource: ObservableObject, ChatDataSource {
///     @Published var messages: [MyMessage] = []
///     @Published var isTyping = false
///     
///     typealias Message = MyMessage
///     typealias Attachment = ImageAttachment
///     
///     func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
///         // Handle sending logic
///     }
///     
///     func reactToMessage(_ message: MyMessage, reaction: String) {
///         // Handle reaction logic
///     }
///     
///     func removeReaction(from message: MyMessage, reaction: String) {
///         // Handle reaction removal
///     }
/// }
/// ```
///
/// - Important: Implementations must be marked with `@MainActor` or ensure
///   UI updates happen on the main queue.
/// - Note: The protocol automatically inherits from `ObservableObject` for
///   reactive UI updates.
public protocol ChatDataSource: ChatDataProvider, ChatActionHandler, ObservableObject where Message == Self.Message, Attachment == Self.Attachment {
    // Combined protocol for simple use cases
}

// MARK: - Scroll Position
public struct ChatScrollPosition {
    public let messageId: String?
    public let offset: CGFloat
    
    public init(messageId: String? = nil, offset: CGFloat = 0) {
        self.messageId = messageId
        self.offset = offset
    }
    
    public static let bottom = ChatScrollPosition()
}