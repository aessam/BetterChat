import SwiftUI
import MultipeerConnectivity

/// Demo app showing P2P chat functionality
// Uncommented @main to run P2P demo instead of TestableDemo
// @main - Now using enhanced TestableDemo instead
struct P2PChatApp: App {
    var body: some Scene {
        WindowGroup {
            P2PChatDemoView()
        }
    }
}

/// Main demo view for P2P chat
struct P2PChatDemoView: View {
    @StateObject private var dataSource = P2PDataSource(
        displayName: getDeviceName()
    )
    @State private var showPeerList = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top bar with peer count and button
                HStack {
                    Text("P2P Chat")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: { showPeerList.toggle() }) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.blue)
                            
                            // Show connected count if any, otherwise show discovered count
                            let totalPeers = dataSource.connectedPeers.count + dataSource.discoveredPeers.count
                            if totalPeers > 0 {
                                Text("\(totalPeers)")
                                    .font(.caption)
                                    .foregroundColor(dataSource.connectedPeers.count > 0 ? .green : .orange)
                            } else {
                                // Always show the button, even with no peers
                                Text("0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(UnifiedColors.secondaryBackground)
                
                // Connection status bar
                P2PConnectionStatusView(dataSource: dataSource)
                
                // Chat view using BetterChat
                BetterChat.chat(dataSource)
                    .chatTheme(ChatThemePreset.blue)
                
            }
            .sheet(isPresented: $showPeerList) {
                P2PPeerListView(dataSource: dataSource)
            }
        }
    }
}

/// Shows connection status and connected peers
struct P2PConnectionStatusView: View {
    @ObservedObject var dataSource: P2PDataSource
    @Environment(\.chatTheme) private var theme
    
    var body: some View {
        if !dataSource.connectedPeers.isEmpty {
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                
                Text("Connected to \(dataSource.connectedPeers.count) peer\(dataSource.connectedPeers.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !dataSource.typingPeers.isEmpty {
                    HStack(spacing: 4) {
                        Text("typing")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(Color.secondary)
                                    .frame(width: 3, height: 3)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(UnifiedColors.systemGray6)
        }
    }
}

/// List of available and connected peers
struct P2PPeerListView: View {
    @ObservedObject var dataSource: P2PDataSource
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with Done button
            HStack {
                Text("Peers")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(UnifiedColors.secondaryBackground)
            
            List {
                Section("Available Peers") {
                    if dataSource.discoveredPeers.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No peers found")
                                .foregroundColor(.secondary)
                                .italic()
                            Text("Make sure other devices are running the same app on the same network")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        ForEach(dataSource.discoveredPeers, id: \.peerID) { peer in
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text(peer.displayName)
                                        .font(.headline)
                                    
                                    if let deviceInfo = peer.deviceInfo {
                                        Text(deviceInfo)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button("Connect") {
                                    dataSource.connectToPeer(peer)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                    }
                }
                
                Section("Connected Peers") {
                    if dataSource.connectedPeers.isEmpty {
                        Text("No peers connected")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(dataSource.connectedPeers, id: \.peerID) { peer in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading) {
                                    Text(peer.displayName)
                                        .font(.headline)
                                    
                                    if let deviceInfo = peer.deviceInfo {
                                        Text(deviceInfo)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if dataSource.typingPeers.contains(peer.peerID) {
                                    Text("typing...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section("Connection Info") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(statusText)
                            .foregroundColor(statusColor)
                    }
                    
                    HStack {
                        Text("Service Type")
                        Spacer()
                        Text("test")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Discovery")
                        Spacer()
                        Text("Advertising & Browsing")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Device Name")
                        Spacer()
                        Text(getDeviceName())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var statusText: String {
        switch dataSource.connectionStatus {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting..."
        case .notConnected:
            return "Not Connected"
        case .disconnected:
            return "Disconnected"
        }
    }
    
    private var statusColor: Color {
        switch dataSource.connectionStatus {
        case .connected:
            return .green
        case .connecting:
            return .orange
        case .notConnected, .disconnected:
            return .red
        }
    }
}

// MARK: - Preview
struct P2PChatDemoView_Previews: PreviewProvider {
    static var previews: some View {
        P2PChatDemoView()
    }
}