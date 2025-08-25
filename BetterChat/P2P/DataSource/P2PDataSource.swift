import Foundation
import SwiftUI
import Combine
import MultipeerConnectivity


/// DataSource implementation for P2P chat that conforms to ChatDataSource
@MainActor
public class P2PDataSource: ObservableObject, ChatDataSource {
    // MARK: - ChatDataSource Requirements
    public typealias Message = P2PTextMessage
    public typealias Attachment = ImageAttachment
    
    @Published public var messages: [P2PTextMessage] = []
    @Published public var isTyping: Bool = false
    @Published public var isThinking: Bool = false
    @Published public var currentThoughts: [ThinkingThought] = []
    @Published public var completedThinkingSessions: [ThinkingSession] = []
    
    // MARK: - P2P Specific Properties
    @Published public var connectedPeers: [PeerInfo] = []
    @Published public var discoveredPeers: [PeerInfo] = []
    @Published public var typingPeers: Set<String> = []
    @Published public var connectionStatus: P2PConnectionState = .notConnected
    @Published public var allMessages: [any P2PMessage] = []
    
    // MARK: - Private Properties
    private let session: P2PSession
    private let processor: P2PMessageProcessor
    private var cancellables = Set<AnyCancellable>()
    private var typingTimers: [String: Timer] = [:]
    
    public init(displayName: String, serviceType: String = "test") {
        self.session = P2PSession(displayName: displayName, serviceType: serviceType)
        self.processor = P2PMessageProcessor()
        
        setupHandlers()
        setupSession()
        setupBindings()
    }
    
    private func setupHandlers() {
        // Register all built-in handlers
        processor.registerHandlers([
            TextMessageHandler(),
            ImageMessageHandler(),
            ReactionHandler(),
            TypingIndicatorHandler()
        ])
    }
    
    private func setupSession() {
        session.delegate = self
        session.startAdvertising()
        session.startBrowsing()
    }
    
    private func setupBindings() {
        // Sync connected peers
        session.$connectedPeers
            .assign(to: &$connectedPeers)
        
        // Sync discovered peers  
        session.$discoveredPeers
            .assign(to: &$discoveredPeers)
        
        // Update typing status based on typing peers
        $typingPeers
            .map { !$0.isEmpty }
            .assign(to: &$isTyping)
    }
    
    // MARK: - ChatActionHandler Methods
    
    public func sendMessage(text: String, attachments: [ImageAttachment]) {
        // Create appropriate message based on content
        let message: any P2PMessage
        
        if !attachments.isEmpty {
            // Image message with attachments
            message = P2PImageMessage(
                sender: .currentUser,
                attachments: attachments,
                caption: text.isEmpty ? nil : text,
                peerInfo: session.localPeerInfo,
                envelopeId: UUID().uuidString
            )
        } else {
            // Text message
            message = P2PTextMessage(
                sender: .currentUser,
                text: text,
                peerInfo: session.localPeerInfo,
                envelopeId: UUID().uuidString
            )
        }
        
        // Add to local messages
        if let textMessage = message as? P2PTextMessage {
            messages.append(textMessage)
        }
        allMessages.append(message)
        
        // Send via P2P
        Task {
            do {
                let envelope = try processor.encode(message: message)
                try session.broadcast(envelope: envelope)
            } catch {
                print("Failed to send message: \(error)")
                // Update message status to failed
                if let index = messages.firstIndex(where: { $0.id == message.id }) {
                    messages[index].status = .failed
                }
            }
        }
    }
    
    public func retryMessage(_ message: P2PTextMessage) {
        // Update status and try sending again
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].status = .sending
            
            Task {
                do {
                    let envelope = try processor.encode(message: message)
                    try session.broadcast(envelope: envelope)
                    messages[index].status = .sent
                } catch {
                    messages[index].status = .failed
                }
            }
        }
    }
    
    /// Connect to a discovered peer
    public func connectToPeer(_ peer: PeerInfo) {
        session.invitePeer(peer)
    }
    
    public func reactToMessage(_ message: P2PTextMessage, reaction: String) {
        // Send reaction via P2P
        Task {
            do {
                let envelope = try ReactionHandler.createReactionEnvelope(
                    messageId: message.id,
                    emoji: reaction,
                    action: .add,
                    sender: session.localPeerInfo
                )
                try session.broadcast(envelope: envelope)
            } catch {
                print("Failed to send reaction: \(error)")
            }
        }
    }
    
    public func removeReaction(from message: P2PTextMessage, reaction: String) {
        // Send reaction removal via P2P
        Task {
            do {
                let envelope = try ReactionHandler.createReactionEnvelope(
                    messageId: message.id,
                    emoji: reaction,
                    action: .remove,
                    sender: session.localPeerInfo
                )
                try session.broadcast(envelope: envelope)
            } catch {
                print("Failed to remove reaction: \(error)")
            }
        }
    }
    
    // MARK: - P2P Specific Methods
    
    /// Send typing indicator to peers
    public func sendTypingIndicator(_ isTyping: Bool) {
        Task {
            do {
                let envelope = try TypingIndicatorHandler.createTypingEnvelope(
                    isTyping: isTyping,
                    sender: session.localPeerInfo
                )
                try session.broadcast(envelope: envelope)
            } catch {
                print("Failed to send typing indicator: \(error)")
            }
        }
    }
    
    /// Invite a specific peer to connect
    public func invitePeer(_ peerID: MCPeerID) {
        session.invitePeer(peerID, timeout: 30)
    }
    
    /// Disconnect from all peers
    public func disconnect() {
        session.disconnect()
        connectedPeers.removeAll()
        messages.removeAll()
        allMessages.removeAll()
        typingPeers.removeAll()
    }
    
    // MARK: - Message Processing
    
    private func handleIncomingEnvelope(_ envelope: P2PEnvelope) {
        do {
            let update = try processor.process(envelope: envelope)
            
            switch update {
            case .newMessage(let message):
                handleNewMessage(message)
                
            case .typingStatus(let peer, let isTyping):
                handleTypingStatus(peer: peer, isTyping: isTyping)
                
            case .reaction(let messageId, let reaction, let action):
                handleReaction(messageId: messageId, reaction: reaction, action: action)
                
            case .systemEvent(let event):
                handleSystemEvent(event)
                
            case .updateMessage(let id, let update):
                handleMessageUpdate(id: id, update: update)
                
            case .editMessage(let id, let newContent):
                handleMessageEdit(id: id, newContent: newContent)
                
            case .deleteMessage(let id):
                handleMessageDelete(id: id)
                
            case .messageReceipt(let id, let status):
                handleMessageReceipt(id: id, status: status)
            }
        } catch {
            print("Failed to process envelope: \(error)")
        }
    }
    
    private func handleNewMessage(_ message: any ChatMessage) {
        if let textMessage = message as? P2PTextMessage {
            messages.append(textMessage)
        }
        
        if let p2pMessage = message as? any P2PMessage {
            allMessages.append(p2pMessage)
        }
    }
    
    private func handleTypingStatus(peer: PeerInfo, isTyping: Bool) {
        if isTyping {
            typingPeers.insert(peer.peerID)
            
            // Clear typing after 5 seconds
            typingTimers[peer.peerID]?.invalidate()
            typingTimers[peer.peerID] = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                Task { @MainActor in
                    self.typingPeers.remove(peer.peerID)
                }
            }
        } else {
            typingPeers.remove(peer.peerID)
            typingTimers[peer.peerID]?.invalidate()
            typingTimers[peer.peerID] = nil
        }
    }
    
    private func handleReaction(messageId: String, reaction: Reaction, action: P2PMessageUpdate.ReactionAction) {
        // Find and update the message with the reaction
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            // For now, we'll need to recreate the message with reactions
            // In a real app, you'd make messages mutable or use a different approach
            print("Reaction \(action) for message \(messageId): \(reaction.emoji)")
        }
    }
    
    private func handleSystemEvent(_ event: P2PSystemEvent) {
        switch event {
        case .peerConnected(let peer):
            let systemMessage = P2PSystemMessage(
                text: "\(peer.displayName) joined the chat",
                peerInfo: peer,
                eventType: .peerJoined
            )
            allMessages.append(systemMessage)
            
        case .peerDisconnected(let peer):
            let systemMessage = P2PSystemMessage(
                text: "\(peer.displayName) left the chat",
                peerInfo: peer,
                eventType: .peerLeft
            )
            allMessages.append(systemMessage)
            typingPeers.remove(peer.peerID)
            
        default:
            break
        }
    }
    
    private func handleMessageUpdate(id: String, update: MessageUpdate) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            if let status = update.status {
                messages[index].status = status
            }
        }
    }
    
    private func handleMessageEdit(id: String, newContent: String) {
        // Handle message edits if supported
    }
    
    private func handleMessageDelete(id: String) {
        messages.removeAll { $0.id == id }
        allMessages.removeAll { $0.id == id }
    }
    
    private func handleMessageReceipt(id: String, status: MessageStatus) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].status = status
        }
    }
}

// MARK: - P2PSessionDelegate
extension P2PDataSource: P2PSessionDelegate {
    public func session(didReceive data: Data, from peer: PeerInfo) {
        do {
            let envelope = try JSONDecoder().decode(P2PEnvelope.self, from: data)
            handleIncomingEnvelope(envelope)
        } catch {
            print("Failed to decode envelope: \(error)")
        }
    }
    
    public func session(peer: PeerInfo, didChangeState state: P2PConnectionState) {
        connectionStatus = state
        
        switch state {
        case .connected:
            handleSystemEvent(.peerConnected(peer))
        case .disconnected, .notConnected:
            handleSystemEvent(.peerDisconnected(peer))
        default:
            break
        }
    }
    
    public func session(didEncounterError error: Error) {
        print("P2P session error: \(error)")
        handleSystemEvent(.connectionError(error))
    }
    
    public func session(didDiscover peer: PeerInfo) {
        // Peer discovery is automatically handled by the binding to session.$discoveredPeers
        print("Discovered peer: \(peer.displayName)")
    }
    
    public func session(didLose peer: PeerInfo) {
        // Peer loss is automatically handled by the binding to session.$discoveredPeers
        print("Lost peer: \(peer.displayName)")
    }
}