import Foundation
import SwiftUI

/// Base implementation of a P2P message
public struct P2PTextMessage: P2PMessage, TextMessage {
    public let id: String
    public let timestamp: Date
    public let sender: MessageSender
    public var status: MessageStatus
    public let text: String
    public let peerInfo: PeerInfo
    public let envelopeId: String
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        sender: MessageSender,
        status: MessageStatus = .sent,
        text: String,
        peerInfo: PeerInfo,
        envelopeId: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sender = sender
        self.status = status
        self.text = text
        self.peerInfo = peerInfo
        self.envelopeId = envelopeId
    }
}

/// P2P message with image attachment
public struct P2PImageMessage: P2PMessage, MediaMessage {
    public typealias Attachment = ImageAttachment
    
    public let id: String
    public let timestamp: Date
    public let sender: MessageSender
    public var status: MessageStatus
    public let attachments: [ImageAttachment]
    public let caption: String?
    public let peerInfo: PeerInfo
    public let envelopeId: String
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        sender: MessageSender,
        status: MessageStatus = .sent,
        attachments: [ImageAttachment],
        caption: String? = nil,
        peerInfo: PeerInfo,
        envelopeId: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sender = sender
        self.status = status
        self.attachments = attachments
        self.caption = caption
        self.peerInfo = peerInfo
        self.envelopeId = envelopeId
    }
}

/// System message for P2P events
public struct P2PSystemMessage: P2PMessage {
    public let id: String
    public let timestamp: Date
    public let sender: MessageSender = .system
    public var status: MessageStatus = .sent
    public let text: String
    public let peerInfo: PeerInfo
    public let envelopeId: String
    public let eventType: SystemEventType
    
    public enum SystemEventType {
        case peerJoined
        case peerLeft
        case connectionEstablished
        case connectionLost
        case custom(String)
    }
    
    public init(
        text: String,
        peerInfo: PeerInfo,
        eventType: SystemEventType,
        envelopeId: String = UUID().uuidString
    ) {
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.text = text
        self.peerInfo = peerInfo
        self.eventType = eventType
        self.envelopeId = envelopeId
    }
}

/// Generic P2P message for unknown MIME types
public struct P2PGenericMessage: P2PMessage {
    public let id: String
    public let timestamp: Date
    public let sender: MessageSender
    public var status: MessageStatus
    public let mimeType: String
    public let displayText: String
    public let rawData: Data
    public let peerInfo: PeerInfo
    public let envelopeId: String
    
    public init(from envelope: P2PEnvelope) {
        self.id = UUID().uuidString
        self.timestamp = envelope.timestamp
        self.sender = .otherUser
        self.status = .delivered
        self.mimeType = envelope.mimeType
        self.displayText = "[\(P2PMimeType.subType(from: envelope.mimeType) ?? "Unknown") content]"
        self.rawData = envelope.payload
        self.peerInfo = envelope.sender
        self.envelopeId = envelope.id
    }
}