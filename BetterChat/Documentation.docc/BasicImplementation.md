# Basic Implementation

Learn the fundamental concepts of BetterChat and build your first chat interface.

## Overview

This guide walks you through the core concepts and components needed to build a functional chat interface with BetterChat. By the end, you'll understand the architecture and have a working chat application.

## Core Architecture

BetterChat follows a protocol-oriented architecture with clear separation of concerns:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ChatDataSource│    │   ModernChatView│    │   ChatMessage   │
│   (Your Data)   │◄──►│   (UI Layer)    │◄──►│   (Model)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Components

1. **Data Source**: Manages messages and handles user actions
2. **Chat View**: Renders the UI and coordinates interactions
3. **Message Models**: Define the structure of your chat data
4. **Theme System**: Controls visual appearance

## Step 1: Define Your Message Model

Start by creating a message type that conforms to the necessary protocols:

```swift
struct MyMessage: ChatMessage, TextMessage, ReactableMessage, MediaMessage {
    // Required by ChatMessage
    let id: String
    let timestamp: Date
    let sender: MessageSender
    var status: MessageStatus = .sent
    
    // Required by TextMessage
    var text: String { return content }
    
    // Required by ReactableMessage
    var reactions: [Reaction] = []
    
    // Required by MediaMessage
    var attachments: [any ChatAttachment] = []
    
    // Your custom properties
    let content: String
    
    init(content: String, sender: MessageSender) {
        self.id = UUID().uuidString
        self.content = content
        self.sender = sender
        self.timestamp = Date()
    }
}
```

### Message Types Explained

- **`ChatMessage`**: Base protocol with essential properties
- **`TextMessage`**: Adds text content capability
- **`ReactableMessage`**: Enables emoji reactions
- **`MediaMessage`**: Supports attachments

## Step 2: Create Your Data Source

Implement the `ChatDataSource` protocol to manage your chat data:

```swift
class MyDataSource: ObservableObject, ChatDataSource {
    // Required published properties
    @Published var messages: [MyMessage] = []
    @Published var isTyping = false
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    // Required type aliases
    typealias Message = MyMessage
    typealias Attachment = ImageAttachment
    
    init() {
        // Add some sample messages
        addSampleMessages()
    }
    
    // MARK: - ChatDataSource Methods
    
    func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        let userMessage = MyMessage(content: content, sender: .user)
        messages.append(userMessage)
        
        // Simulate a response
        simulateResponse(to: content)
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
    
    // MARK: - Helper Methods
    
    private func addSampleMessages() {
        messages = [
            MyMessage(content: "Welcome to BetterChat! 👋", sender: .assistant),
            MyMessage(content: "This is a sample conversation.", sender: .assistant),
            MyMessage(content: "How can I help you today?", sender: .assistant)
        ]
    }
    
    private func simulateResponse(to userMessage: String) {
        // Show typing indicator
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isTyping = false
            
            let response = self.generateResponse(to: userMessage)
            let assistantMessage = MyMessage(content: response, sender: .assistant)
            self.messages.append(assistantMessage)
        }
    }
    
    private func generateResponse(to message: String) -> String {
        let responses = [
            "That's an interesting point! 🤔",
            "I understand what you mean.",
            "Let me think about that for a moment...",
            "Great question! Here's what I think:",
            "I appreciate you sharing that with me."
        ]
        return responses.randomElement() ?? "Thanks for your message!"
    }
}
```

## Step 3: Build the Chat Interface

Create your main chat view using `ModernChatView`:

```swift
struct MyChatView: View {
    @StateObject private var dataSource = MyDataSource()
    @State private var selectedTheme: ChatThemePreset = .blue
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Optional: Theme selector
                themeSelector
                
                // Main chat interface
                ModernChatView(
                    dataSource: dataSource,
                    attachmentActions: attachmentActions
                )
                .chatTheme(selectedTheme)
            }
            .navigationTitle("My Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var themeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([ChatThemePreset.light, .dark, .blue, .green, .minimal], id: \.self) { theme in
                    ThemeButton(theme: theme, selectedTheme: $selectedTheme)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var attachmentActions: [AttachmentAction] {
        [
            AttachmentAction(
                title: "Photo",
                icon: Image(systemName: "photo"),
                action: {
                    ImageAttachment(
                        displayName: "Sample Photo",
                        image: Image(systemName: "photo.circle"),
                        thumbnail: Image(systemName: "photo.circle")
                    )
                }
            ),
            AttachmentAction(
                title: "Document",
                icon: Image(systemName: "doc"),
                action: {
                    ImageAttachment(
                        displayName: "Document",
                        image: Image(systemName: "doc.circle"),
                        thumbnail: Image(systemName: "doc.circle")
                    )
                }
            )
        ]
    }
}
```

## Step 4: Create a Theme Button Component

Add a reusable component for theme selection:

```swift
struct ThemeButton: View {
    let theme: ChatThemePreset
    @Binding var selectedTheme: ChatThemePreset
    
    private var isSelected: Bool {
        selectedTheme == theme
    }
    
    private var themeColor: Color {
        switch theme {
        case .light: return .orange
        case .dark: return .purple
        case .blue: return .blue
        case .green: return .green
        case .minimal: return .gray
        }
    }
    
    var body: some View {
        Button(themeName) {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTheme = theme
            }
        }
        .font(.caption)
        .fontWeight(isSelected ? .semibold : .regular)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
    }
    
    private var themeName: String {
        switch theme {
        case .light: return "Light"
        case .dark: return "Dark"
        case .blue: return "Blue"
        case .green: return "Green"
        case .minimal: return "Minimal"
        }
    }
    
    private var backgroundColor: Color {
        isSelected ? themeColor.opacity(0.2) : Color(.systemGray6)
    }
    
    private var textColor: Color {
        isSelected ? themeColor : .secondary
    }
    
    private var borderColor: Color {
        isSelected ? themeColor : Color(.systemGray4)
    }
}
```

## Step 5: Add to Your App

Integrate your chat view into your app:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyChatView()
        }
    }
}
```

## Understanding the Data Flow

```
User Input → ModernChatView → ChatDataSource → Update @Published Properties → UI Refresh
     ↑                                                                              ↓
   UI Updates ←─────────────────────────────────────────────────────────────────────┘
```

1. **User Action**: User types message or taps button
2. **View Layer**: ModernChatView captures the action
3. **Data Source**: Calls appropriate method on ChatDataSource
4. **State Update**: Data source updates @Published properties
5. **UI Refresh**: SwiftUI automatically refreshes the interface

## Key Concepts

### ObservableObject Pattern

```swift
class MyDataSource: ObservableObject, ChatDataSource {
    @Published var messages: [MyMessage] = [] // ← UI updates when this changes
    @Published var isTyping = false           // ← UI shows typing indicator
    
    func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        // Modify @Published properties to trigger UI updates
        messages.append(newMessage) // ← This triggers UI refresh
    }
}
```

### Protocol Composition

```swift
// Combine multiple protocols for rich functionality
struct MyMessage: ChatMessage,      // ← Basic message properties
                  TextMessage,      // ← Text content
                  ReactableMessage, // ← Emoji reactions
                  MediaMessage {    // ← Attachment support
    // Implementation...
}
```

### Theme Application

```swift
ModernChatView(dataSource: dataSource)
    .chatTheme(.blue)  // ← Apply built-in theme
    // or
    .chatTheme(customTheme)  // ← Apply custom theme
```

## Common Patterns

### Adding Message Validation

```swift
func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
    // Validate input
    guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return
    }
    
    // Create and add message
    let message = MyMessage(content: content, sender: .user)
    messages.append(message)
    
    // Handle response
    processUserMessage(content)
}
```

### Message Persistence

```swift
class PersistentDataSource: MyDataSource {
    private let userDefaults = UserDefaults.standard
    private let messagesKey = "savedMessages"
    
    override init() {
        super.init()
        loadMessages()
    }
    
    override func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        super.sendMessage(content, attachments: attachments)
        saveMessages()
    }
    
    private func saveMessages() {
        if let data = try? JSONEncoder().encode(messages) {
            userDefaults.set(data, forKey: messagesKey)
        }
    }
    
    private func loadMessages() {
        guard let data = userDefaults.data(forKey: messagesKey),
              let savedMessages = try? JSONDecoder().decode([MyMessage].self, from: data) else {
            return
        }
        self.messages = savedMessages
    }
}
```

### Error Handling

```swift
func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
    let message = MyMessage(content: content, sender: .user)
    message.status = .sending
    messages.append(message)
    
    // Simulate network request
    sendToServer(message) { [weak self] result in
        DispatchQueue.main.async {
            switch result {
            case .success:
                self?.updateMessageStatus(message.id, to: .sent)
            case .failure(let error):
                self?.updateMessageStatus(message.id, to: .failed)
                self?.showError(error)
            }
        }
    }
}

private func updateMessageStatus(_ messageId: String, to status: MessageStatus) {
    guard let index = messages.firstIndex(where: { $0.id == messageId }) else { return }
    messages[index].status = status
}
```

## Next Steps

Now that you have a basic chat interface:

1. <doc:CustomDataSource> - Learn advanced data source patterns
2. <doc:ThemingGuide> - Customize the visual appearance
3. <doc:ThinkingMessages> - Add AI thinking capabilities
4. <doc:AttachmentSystem> - Handle different types of attachments

## Troubleshooting

### Common Issues

**Messages not appearing:**
- Ensure your data source conforms to `ObservableObject`
- Check that you're modifying `@Published` properties
- Verify the data source is passed correctly to `ModernChatView`

**Theme not applying:**
- Make sure `.chatTheme()` is called on `ModernChatView`
- Check that you're using the environment properly in custom components

**Build errors:**
- Ensure all required protocol methods are implemented
- Check that type aliases match your actual types
- Verify iOS deployment target is 15.0+

### Performance Tips

1. **Limit message history** in memory for large conversations
2. **Use lazy loading** for attachments and media
3. **Implement efficient updates** using targeted array modifications
4. **Profile memory usage** during long conversations

This foundation provides everything you need for a functional chat interface. The protocol-oriented design makes it easy to extend and customize as your needs grow.