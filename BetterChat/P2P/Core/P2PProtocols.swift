import Foundation
import SwiftUI

/// Protocol for handling specific MIME type payloads
public protocol P2PPayloadHandler {
    /// MIME types this handler can process
    var supportedMimeTypes: [String] { get }
    
    /// Process an incoming envelope into a message update
    func handle(envelope: P2PEnvelope) throws -> P2PMessageUpdate
    
    /// Encode a chat message into an envelope (if this handler supports it)
    func encode(message: any ChatMessage) throws -> P2PEnvelope?
}

/// Types of updates that can result from processing a P2P message
public enum P2PMessageUpdate {
    /// A new message to add to the chat
    case newMessage(any ChatMessage)
    
    /// Update an existing message
    case updateMessage(id: String, update: MessageUpdate)
    
    /// Typing status change
    case typingStatus(peer: PeerInfo, isTyping: Bool)
    
    /// Add/remove reaction to a message
    case reaction(messageId: String, reaction: Reaction, action: ReactionAction)
    
    /// System event (peer joined/left, etc.)
    case systemEvent(P2PSystemEvent)
    
    /// Edit an existing message
    case editMessage(id: String, newContent: String)
    
    /// Delete a message
    case deleteMessage(id: String)
    
    /// Mark message as read
    case messageReceipt(id: String, status: MessageStatus)
    
    public enum ReactionAction {
        case add
        case remove
    }
}

/// Updates to apply to an existing message
public struct MessageUpdate {
    public let content: String?
    public let status: MessageStatus?
    public let reactions: [Reaction]?
    public let editedAt: Date?
    
    public init(
        content: String? = nil,
        status: MessageStatus? = nil,
        reactions: [Reaction]? = nil,
        editedAt: Date? = nil
    ) {
        self.content = content
        self.status = status
        self.reactions = reactions
        self.editedAt = editedAt
    }
}

/// System events in P2P communication
public enum P2PSystemEvent {
    case peerConnected(PeerInfo)
    case peerDisconnected(PeerInfo)
    case peerUpdatedProfile(PeerInfo)
    case connectionError(Error)
    case syncRequest
    case syncResponse([P2PEnvelope])
}

/// Protocol for P2P session delegates
public protocol P2PSessionDelegate: AnyObject {
    /// Called when data is received from a peer
    func session(didReceive data: Data, from peer: PeerInfo)
    
    /// Called when a peer connects
    func session(peer: PeerInfo, didChangeState state: P2PConnectionState)
    
    /// Called when there's an error
    func session(didEncounterError error: Error)
    
    /// Called when a peer is discovered during browsing
    func session(didDiscover peer: PeerInfo)
    
    /// Called when a discovered peer is lost
    func session(didLose peer: PeerInfo)
}

/// Connection states for P2P peers
public enum P2PConnectionState {
    case notConnected
    case connecting
    case connected
    case disconnected
}

/// Protocol for objects that can be sent as P2P payloads
public protocol P2PSerializable {
    /// Convert to data for transmission
    func serialize() throws -> Data
    
    /// Create from received data
    static func deserialize(from data: Data) throws -> Self
}

/// Extension to make Codable types P2P serializable
extension P2PSerializable where Self: Codable {
    public func serialize() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    public static func deserialize(from data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}

/// Protocol for P2P message types that integrate with BetterChat
public protocol P2PMessage: ChatMessage {
    /// The peer who sent this message
    var peerInfo: PeerInfo { get }
    
    /// Original envelope ID for tracking
    var envelopeId: String { get }
}