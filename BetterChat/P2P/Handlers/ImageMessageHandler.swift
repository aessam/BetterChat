import Foundation
import SwiftUI

/// Payload for image messages
public struct ImagePayload: Codable, P2PSerializable {
    public let imageData: Data
    public let thumbnailData: Data?
    public let caption: String?
    public let mimeType: String
    public let filename: String
    
    public init(
        imageData: Data,
        thumbnailData: Data? = nil,
        caption: String? = nil,
        mimeType: String,
        filename: String
    ) {
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.caption = caption
        self.mimeType = mimeType
        self.filename = filename
    }
}

/// Handler for image message payloads
public class ImageMessageHandler: P2PPayloadHandler {
    public var supportedMimeTypes: [String] {
        [
            P2PMimeType.imageJPEG,
            P2PMimeType.imagePNG,
            P2PMimeType.imageGIF,
            P2PMimeType.imageHEIC
        ]
    }
    
    public init() {}
    
    public func handle(envelope: P2PEnvelope) throws -> P2PMessageUpdate {
        // For simple image types, the payload is the image data directly
        // For more complex cases, it might be an ImagePayload
        
        let imageData: Data
        let caption: String?
        let filename: String
        
        // Check if this is a structured payload or raw image data
        if let metadata = envelope.metadata,
           metadata["structured"] == "true" {
            // Structured payload with metadata
            let payload = try ImagePayload.deserialize(from: envelope.payload)
            imageData = payload.imageData
            caption = payload.caption
            filename = payload.filename
        } else {
            // Raw image data
            imageData = envelope.payload
            caption = envelope.metadata?["caption"]
            filename = envelope.metadata?["filename"] ?? "image.\(P2PMimeType.subType(from: envelope.mimeType) ?? "jpg")"
        }
        
        // Create image attachment
        let platformImage = PlatformImage.from(data: imageData) ?? createEmptyPlatformImage()
        let image = Image(platformImage: platformImage)
        
        let attachment = ImageAttachment(
            displayName: filename,
            size: Int64(imageData.count),
            image: image,
            thumbnail: image // For now, use same image as thumbnail
        )
        
        // Determine sender
        let sender: MessageSender = envelope.sender.peerID == getCurrentPeerID() ? .currentUser : .otherUser
        
        // Create image message
        let message = P2PImageMessage(
            id: envelope.id,
            timestamp: envelope.timestamp,
            sender: sender,
            status: sender == .currentUser ? .sent : .delivered,
            attachments: [attachment],
            caption: caption,
            peerInfo: envelope.sender,
            envelopeId: envelope.id
        )
        
        return .newMessage(message)
    }
    
    public func encode(message: any ChatMessage) throws -> P2PEnvelope? {
        // Check if this is a media message with image attachments
        guard let mediaMessage = message as? (any MediaMessage),
              let imageAttachment = mediaMessage.attachments.first as? ImageAttachment else {
            return nil
        }
        
        // For now, we'll need to convert the SwiftUI Image to data
        // This is a simplified version - in production, you'd store the original data
        let imageData = Data() // Placeholder - would need actual image data
        
        let caption: String?
        if let imageMessage = message as? P2PImageMessage {
            caption = imageMessage.caption
        } else {
            caption = nil
        }
        
        return P2PEnvelope(
            id: message.id,
            timestamp: message.timestamp,
            sender: getCurrentPeerInfo(),
            mimeType: P2PMimeType.imageJPEG,
            payload: imageData,
            metadata: [
                "filename": imageAttachment.displayName,
                "caption": caption ?? ""
            ].compactMapValues { $0.isEmpty ? nil : $0 }
        )
    }
    
    private func getCurrentPeerID() -> String {
        ProcessInfo.processInfo.hostName ?? "unknown"
    }
    
    private func getCurrentPeerInfo() -> PeerInfo {
        PeerInfo(
            peerID: getCurrentPeerID(),
            displayName: getDeviceName(),
            deviceInfo: getPlatformInfo()
        )
    }
}