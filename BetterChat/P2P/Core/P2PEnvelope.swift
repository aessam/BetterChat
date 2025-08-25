import Foundation

/// The wire format for ALL P2P communications
/// Every message sent between peers uses this envelope structure
public struct P2PEnvelope: Codable {
    /// Unique identifier for this message
    public let id: String
    
    /// When the message was created
    public let timestamp: Date
    
    /// Information about the sender
    public let sender: PeerInfo
    
    /// MIME type identifying the payload format
    /// Examples: "text/plain", "image/jpeg", "application/x-reaction"
    public let mimeType: String
    
    /// The actual message content as binary data
    public let payload: Data
    
    /// Optional metadata/headers for the message
    public let metadata: [String: String]?
    
    /// Sequence number for ordering (optional)
    public let sequenceNumber: Int?
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        sender: PeerInfo,
        mimeType: String,
        payload: Data,
        metadata: [String: String]? = nil,
        sequenceNumber: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sender = sender
        self.mimeType = mimeType
        self.payload = payload
        self.metadata = metadata
        self.sequenceNumber = sequenceNumber
    }
}

/// Information about a peer in the P2P network
public struct PeerInfo: Codable, Hashable {
    /// Unique identifier for the peer
    public let peerID: String
    
    /// Display name for the peer
    public let displayName: String
    
    /// Optional device information
    public let deviceInfo: String?
    
    /// Avatar data (optional)
    public let avatarData: Data?
    
    public init(
        peerID: String,
        displayName: String,
        deviceInfo: String? = nil,
        avatarData: Data? = nil
    ) {
        self.peerID = peerID
        self.displayName = displayName
        self.deviceInfo = deviceInfo
        self.avatarData = avatarData
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(peerID)
    }
    
    public static func == (lhs: PeerInfo, rhs: PeerInfo) -> Bool {
        lhs.peerID == rhs.peerID
    }
}