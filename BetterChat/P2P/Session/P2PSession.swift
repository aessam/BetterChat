import Foundation
import MultipeerConnectivity
import Combine

/// Wrapper for MultipeerConnectivity session management
@MainActor
public class P2PSession: NSObject {
    /// The service type for discovery (must be 1-15 characters, lowercase letters, numbers, and hyphens)
    private let serviceType: String
    
    /// Local peer ID
    public let peerID: MCPeerID
    
    /// Local peer info
    public private(set) var localPeerInfo: PeerInfo
    
    /// The multipeer session
    private var session: MCSession?
    
    /// Service browser for discovering peers
    private var browser: MCNearbyServiceBrowser?
    
    /// Service advertiser for making ourselves discoverable
    private var advertiser: MCNearbyServiceAdvertiser?
    
    /// Delegate for session events
    public weak var delegate: P2PSessionDelegate?
    
    /// Currently connected peers
    @Published public private(set) var connectedPeers: [PeerInfo] = []
    
    /// Currently discovered but not connected peers  
    @Published public private(set) var discoveredPeers: [PeerInfo] = []
    
    /// Map of MCPeerID to PeerInfo
    private var peerInfoMap: [MCPeerID: PeerInfo] = [:]
    
    /// Queue for processing received data
    private let dataQueue = DispatchQueue(label: "com.betterchat.p2p.data", qos: .userInitiated)
    
    /// Maximum data size for reliable transmission (roughly 200KB to be safe)
    private let maxReliableDataSize = 200_000
    
    public init(
        displayName: String,
        serviceType: String = "test",
        avatarData: Data? = nil
    ) {
        self.serviceType = serviceType
        self.peerID = MCPeerID(displayName: displayName)
        self.localPeerInfo = PeerInfo(
            peerID: peerID.displayName,
            displayName: displayName,
            deviceInfo: getPlatformInfo(),
            avatarData: avatarData
        )
        
        super.init()
        
        setupSession()
    }
    
    private func setupSession() {
        session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session?.delegate = self
    }
    
    /// Start advertising this device for discovery
    public func startAdvertising(with discoveryInfo: [String: String]? = nil) {
        guard advertiser == nil else { 
            print("⚠️ Advertiser already running")
            return 
        }
        
        var info = discoveryInfo ?? [:]
        info["version"] = "1.0"
        info["platform"] = ProcessInfo.processInfo.operatingSystemVersionString
        
        print("🚀 Starting advertising for peer: \(peerID.displayName) with service: \(serviceType)")
        print("📋 Discovery info: \(info)")
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: info,
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        print("📢 Advertiser started")
    }
    
    /// Stop advertising
    public func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }
    
    /// Start browsing for peers
    public func startBrowsing() {
        guard browser == nil else { 
            print("⚠️ Browser already running")
            return 
        }
        
        print("🔍 Starting browsing for peers with service: \(serviceType)")
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        print("🔎 Browser started")
    }
    
    /// Stop browsing
    public func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }
    
    /// Invite a peer to connect
    public func invitePeer(_ peerID: MCPeerID, timeout: TimeInterval = 30) {
        guard let session = session else { return }
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: timeout)
    }
    
    /// Convenience method to invite a peer by PeerInfo
    public func invitePeer(_ peerInfo: PeerInfo, timeout: TimeInterval = 30) {
        if let mcPeerID = peerInfoMap.first(where: { $0.value.peerID == peerInfo.peerID })?.key {
            invitePeer(mcPeerID, timeout: timeout)
        }
    }
    
    /// Send data to specific peers
    public func send(envelope: P2PEnvelope, to peers: [MCPeerID]) throws {
        guard let session = session else {
            throw P2PSessionError.sessionNotInitialized
        }
        
        let data = try JSONEncoder().encode(envelope)
        
        // Use reliable mode for small data, streaming for large
        let mode: MCSessionSendDataMode = data.count < maxReliableDataSize ? .reliable : .unreliable
        
        try session.send(data, toPeers: peers, with: mode)
    }
    
    /// Broadcast data to all connected peers
    public func broadcast(envelope: P2PEnvelope) throws {
        guard let session = session else {
            throw P2PSessionError.sessionNotInitialized
        }
        
        let peers = session.connectedPeers
        guard !peers.isEmpty else {
            throw P2PSessionError.noPeersConnected
        }
        
        try send(envelope: envelope, to: peers)
    }
    
    /// Disconnect from all peers
    public func disconnect() {
        session?.disconnect()
        connectedPeers.removeAll()
        peerInfoMap.removeAll()
    }
    
    /// Clean up resources
    public func cleanup() {
        stopAdvertising()
        stopBrowsing()
        disconnect()
        session = nil
    }
    
    deinit {
        // Clean up synchronously
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
    }
}

// MARK: - MCSessionDelegate
extension P2PSession: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            let p2pState: P2PConnectionState
            
            let peerInfo = peerInfoMap[peerID] ?? PeerInfo(
                peerID: peerID.displayName,
                displayName: peerID.displayName
            )
            
            switch state {
            case .notConnected:
                p2pState = .notConnected
                // Remove from connected peers
                connectedPeers.removeAll { $0.peerID == peerID.displayName }
                // Add back to discovered peers if still available
                if peerInfoMap[peerID] != nil && !discoveredPeers.contains(where: { $0.peerID == peerInfo.peerID }) {
                    discoveredPeers.append(peerInfo)
                }
                
            case .connecting:
                p2pState = .connecting
                
            case .connected:
                p2pState = .connected
                // Move from discovered to connected
                discoveredPeers.removeAll { $0.peerID == peerID.displayName }
                if !connectedPeers.contains(where: { $0.peerID == peerID.displayName }) {
                    connectedPeers.append(peerInfo)
                }
                
            @unknown default:
                p2pState = .notConnected
            }
            
            delegate?.session(peer: peerInfo, didChangeState: p2pState)
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        dataQueue.async { [weak self] in
            guard let self = self else { return }
            
            let peerInfo = self.peerInfoMap[peerID] ?? PeerInfo(
                peerID: peerID.displayName,
                displayName: peerID.displayName
            )
            
            Task { @MainActor in
                self.delegate?.session(didReceive: data, from: peerInfo)
            }
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle streaming data if needed for large files
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Handle resource transfers if needed
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Handle completed resource transfers
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension P2PSession: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("🎯 Found peer: \(peerID.displayName) with info: \(info ?? [:])")
        
        // Create peer info
        let peerInfo = PeerInfo(
            peerID: peerID.displayName,
            displayName: peerID.displayName,
            deviceInfo: info?["platform"]
        )
        peerInfoMap[peerID] = peerInfo
        
        // Add to discovered peers if not already connected
        if !connectedPeers.contains(where: { $0.peerID == peerInfo.peerID }) {
            discoveredPeers.append(peerInfo)
            print("✅ Added \(peerInfo.displayName) to discovered peers")
            delegate?.session(didDiscover: peerInfo)
        } else {
            print("⚠️ Peer \(peerInfo.displayName) already connected")
        }
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let peerInfo = peerInfoMap.removeValue(forKey: peerID) {
            // Remove from discovered peers
            discoveredPeers.removeAll { $0.peerID == peerInfo.peerID }
            delegate?.session(didLose: peerInfo)
        }
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("❌ Browser failed to start: \(error)")
        delegate?.session(didEncounterError: error)
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension P2PSession: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📩 Received invitation from peer: \(peerID.displayName)")
        // Auto-accept invitations for now
        // In production, you might want to prompt the user
        invitationHandler(true, session)
        print("✅ Accepted invitation from peer: \(peerID.displayName)")
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("❌ Advertiser failed to start: \(error)")
        delegate?.session(didEncounterError: error)
    }
}

/// Errors that can occur in P2P session
public enum P2PSessionError: LocalizedError {
    case sessionNotInitialized
    case noPeersConnected
    case dataEncodingFailed
    case peerNotFound
    
    public var errorDescription: String? {
        switch self {
        case .sessionNotInitialized:
            return "P2P session not initialized"
        case .noPeersConnected:
            return "No peers connected"
        case .dataEncodingFailed:
            return "Failed to encode data"
        case .peerNotFound:
            return "Peer not found"
        }
    }
}