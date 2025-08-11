import SwiftUI
import Combine

// MARK: - Minimal Demo (All in one file)

struct SimpleMessage: ChatMessage, TextMessage, ReactableMessage {
    let id = UUID().uuidString
    let timestamp = Date()
    let sender: MessageSender
    var status = MessageStatus.sent
    let text: String
    var reactions: [Reaction]
}

class MinimalDataSource: ObservableObject, ChatDataSource {
    typealias Message = SimpleMessage
    typealias Attachment = ImageAttachment
    
    @Published var messages: [SimpleMessage] = [
        SimpleMessage(sender: .otherUser, text: "Welcome!", reactions: []),
        SimpleMessage(sender: .currentUser, text: "Thanks!", reactions: [])
    ]
    @Published var isTyping = false
    @Published var isThinking = false
    @Published var currentThoughts: [ThinkingThought] = []
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    func sendMessage(text: String, attachments: [ImageAttachment]) {
        messages.append(SimpleMessage(sender: .currentUser, text: text, reactions: []))
        
        // Simple auto-reply
        Task { @MainActor in
            isTyping = true
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isTyping = false
            messages.append(SimpleMessage(sender: .otherUser, text: "Got it! 👍", reactions: []))
        }
    }
    
    func retryMessage(_ message: SimpleMessage) {}
    
    func reactToMessage(_ message: SimpleMessage, reaction: String) {
        guard let i = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[i].reactions.append(Reaction(emoji: reaction, count: 1, isSelected: true))
    }
    
    func removeReaction(from message: SimpleMessage, reaction: String) {
        guard let i = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[i].reactions.removeAll { $0.emoji == reaction }
    }
}

// MARK: - Demo View

struct MinimalDemoView: View {
    @StateObject private var dataSource = MinimalDataSource()
    @State private var currentMessage = "Tap buttons to send quick messages"
    
    var body: some View {
        BetterChat.chat(
            dataSource,
            reactions: ["👍", "👎"],
            accessory: {
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            },
            inputAccessory: {
                // Persistent bar above input field
                VStack(spacing: 4) {
                    // Message display
                    Text(currentMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut, value: currentMessage)
                    
                    // Interactive buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            dataSource.sendMessage(text: "Hi! 👋", attachments: [])
                            currentMessage = "Sent: Hi! 👋"
                            withAnimation {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    currentMessage = "Tap buttons to send quick messages"
                                }
                            }
                        }) {
                            Label("Say Hi", systemImage: "hand.wave")
                                .font(.caption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            dataSource.sendMessage(text: "Bye! 👋", attachments: [])
                            currentMessage = "Sent: Bye! 👋"
                            withAnimation {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    currentMessage = "Tap buttons to send quick messages"
                                }
                            }
                        }) {
                            Label("Say Bye", systemImage: "hand.wave.fill")
                                .font(.caption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
                .overlay(alignment: .top) {
                    Divider()
                }
            },
            suggestions: { text in
                if text.hasPrefix("@") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("@john")
                        Text("@sarah")
                        Text("@team")
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
            }
        )
        .chatTheme(ChatThemePreset.blue)
    }
}

// MARK: - App Entry

//@main
//struct MinimalApp: App {
//    var body: some Scene {
//        WindowGroup {
//            MinimalDemoView()
//        }
//    }
//}
