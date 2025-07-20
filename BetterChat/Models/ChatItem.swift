import Foundation

public enum ChatItemType {
    case message
    case thinkingSession
}

public protocol ChatItem: Identifiable {
    var id: String { get }
    var timestamp: Date { get }
    var sender: MessageSender { get }
    var itemType: ChatItemType { get }
}