# Creating a Custom Data Source

Learn how to implement your own data source for BetterChat.

## Overview

The data source is the heart of your chat implementation. It manages messages, handles user interactions, and provides data to the chat interface. This guide shows you how to create a custom data source that integrates with your app's backend.

## Basic Implementation

### Step 1: Create Your Message Type

```swift
struct MyMessage: ChatMessage, TextMessage, ReactableMessage, MediaMessage {
    let id: String
    let content: String
    let sender: MessageSender
    let timestamp: Date
    var status: MessageStatus = .sent
    var reactions: [Reaction] = []
    var attachments: [any ChatAttachment] = []
}
```

### Step 2: Implement the Data Source

```swift
class MyDataSource: ObservableObject, ChatDataSource {
    @Published var messages: [MyMessage] = []
    @Published var isTyping = false
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    // Required typealias
    typealias Message = MyMessage
    typealias Attachment = ImageAttachment
    
    func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        let message = MyMessage(
            id: UUID().uuidString,
            content: content,
            sender: .user,
            timestamp: Date(),
            attachments: Array(attachments)
        )
        
        messages.append(message)
        
        // Send to your backend
        sendToBackend(message)
    }
    
    func reactToMessage(_ message: MyMessage, reaction: String) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        var updatedMessage = messages[index]
        let newReaction = Reaction(id: UUID().uuidString, emoji: reaction, count: 1)
        updatedMessage.reactions.append(newReaction)
        messages[index] = updatedMessage
    }
    
    func removeReaction(from message: MyMessage, reaction: String) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        var updatedMessage = messages[index]
        updatedMessage.reactions.removeAll { $0.emoji == reaction }
        messages[index] = updatedMessage
    }
}
```

## Advanced Features

### Backend Integration

```swift
class BackendDataSource: ObservableObject, ChatDataSource {
    private let apiClient: APIClient
    private let websocket: WebSocketManager
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        self.websocket = WebSocketManager()
        setupWebSocketHandlers()
    }
    
    private func setupWebSocketHandlers() {
        websocket.onMessageReceived = { [weak self] message in
            DispatchQueue.main.async {
                self?.messages.append(message)
            }
        }
        
        websocket.onTypingIndicator = { [weak self] isTyping in
            DispatchQueue.main.async {
                self?.isTyping = isTyping
            }
        }
    }
    
    func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        let message = MyMessage(
            id: UUID().uuidString,
            content: content,
            sender: .user,
            timestamp: Date(),
            status: .sending,
            attachments: Array(attachments)
        )
        
        messages.append(message)
        
        Task {
            do {
                let result = try await apiClient.sendMessage(content, attachments: attachments)
                await updateMessageStatus(message.id, status: .sent)
            } catch {
                await updateMessageStatus(message.id, status: .failed)
            }
        }
    }
    
    @MainActor
    private func updateMessageStatus(_ messageId: String, status: MessageStatus) {
        guard let index = messages.firstIndex(where: { $0.id == messageId }) else { return }
        messages[index].status = status
    }
}
```

### Thinking Messages Integration

```swift
extension MyDataSource {
    func handleThinkingMessage(_ content: String) {
        guard content.lowercased() == "think" else {
            sendMessage(content, attachments: [])
            return
        }
        
        let thinkingSession = ThinkingSession(
            thoughts: [],
            messageId: UUID().uuidString
        )
        
        // Start thinking process
        simulateThinking(session: thinkingSession)
    }
    
    private func simulateThinking(session: ThinkingSession) {
        var currentSession = session
        let thoughts = [
            "Analyzing the question...",
            "Considering different approaches...",
            "Formulating a comprehensive response..."
        ]
        
        for (index, thoughtContent) in thoughts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1)) {
                let thought = ThinkingThought(
                    content: thoughtContent,
                    timestamp: Date()
                )
                currentSession.thoughts.append(thought)
                
                if index == thoughts.count - 1 {
                    // Thinking complete, add response
                    self.completedThinkingSessions.append(currentSession)
                    self.addThinkingResponse(sessionId: currentSession.messageId)
                }
            }
        }
    }
}
```

### Persistence

```swift
class PersistentDataSource: MyDataSource {
    private let storage: MessageStorage
    
    override init() {
        self.storage = MessageStorage()
        super.init()
        loadMessages()
    }
    
    private func loadMessages() {
        messages = storage.loadMessages()
    }
    
    override func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        super.sendMessage(content, attachments: attachments)
        
        // Save to local storage
        storage.saveMessages(messages)
    }
}
```

## Best Practices

### Performance Optimization

1. **Limit Message History**: Keep only recent messages in memory
2. **Lazy Loading**: Load older messages on demand
3. **Efficient Updates**: Use targeted updates instead of replacing entire arrays

```swift
class OptimizedDataSource: MyDataSource {
    private let maxMessagesInMemory = 100
    
    override func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        super.sendMessage(content, attachments: attachments)
        
        // Trim old messages
        if messages.count > maxMessagesInMemory {
            messages = Array(messages.suffix(maxMessagesInMemory))
        }
    }
}
```

### Error Handling

```swift
enum ChatError: Error {
    case networkError
    case invalidMessage
    case attachmentTooLarge
}

extension MyDataSource {
    private func handleError(_ error: ChatError, for messageId: String) {
        DispatchQueue.main.async {
            if let index = self.messages.firstIndex(where: { $0.id == messageId }) {
                self.messages[index].status = .failed
            }
            
            // Show error message
            let errorMessage = MyMessage(
                id: UUID().uuidString,
                content: "Failed to send message: \(error.localizedDescription)",
                sender: .system,
                timestamp: Date()
            )
            self.messages.append(errorMessage)
        }
    }
}
```

### Testing

```swift
class MockDataSource: MyDataSource {
    override func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        let message = MyMessage(
            id: UUID().uuidString,
            content: content,
            sender: .user,
            timestamp: Date(),
            attachments: Array(attachments)
        )
        
        messages.append(message)
        
        // Simulate response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = MyMessage(
                id: UUID().uuidString,
                content: "Mock response to: \(content)",
                sender: .assistant,
                timestamp: Date()
            )
            self.messages.append(response)
        }
    }
}
```

## Common Patterns

### Message Grouping

```swift
extension MyDataSource {
    var groupedMessages: [[MyMessage]] {
        var groups: [[MyMessage]] = []
        var currentGroup: [MyMessage] = []
        
        for message in messages {
            if let lastMessage = currentGroup.last,
               message.sender == lastMessage.sender,
               message.timestamp.timeIntervalSince(lastMessage.timestamp) < 300 {
                currentGroup.append(message)
            } else {
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [message]
            }
        }
        
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        return groups
    }
}
```

### Real-time Updates

```swift
class RealtimeDataSource: MyDataSource {
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupRealtimeUpdates()
    }
    
    private func setupRealtimeUpdates() {
        // Listen for real-time message updates
        NotificationCenter.default
            .publisher(for: .newMessageReceived)
            .compactMap { $0.object as? MyMessage }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.messages.append(message)
            }
            .store(in: &cancellables)
    }
}
```

## Next Steps

- <doc:ThinkingMessages> - Learn about thinking message implementation
- <doc:AttachmentSystem> - Handle different attachment types
- <doc:ReactionSystem> - Implement reactions properly