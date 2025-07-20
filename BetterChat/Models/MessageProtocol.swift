import SwiftUI

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
}

public protocol MessageProtocol: Identifiable {
    var id: String { get }
    var timestamp: Date { get }
    var sender: MessageSender { get }
    var status: MessageStatus { get }
    var reactionType: String? { get }
}

public protocol ChatDataSource {
    associatedtype Message: MessageProtocol
    associatedtype MessageContent: View
    associatedtype AttachmentPreview: View
    associatedtype ReactionPicker: View
    
    var messages: [Message] { get }
    
    @ViewBuilder
    func messageContent(for message: Message) -> MessageContent
    
    @ViewBuilder
    func attachmentPreview(for attachment: Any) -> AttachmentPreview
    
    @ViewBuilder
    func reactionPicker(for message: Message) -> ReactionPicker
    
    func onSendMessage(text: String, attachments: [Any])
    func onRetryMessage(_ message: Message)
    func onTapAttachment(in message: Message)
    func onReaction(_ reaction: String, to message: Message)
}