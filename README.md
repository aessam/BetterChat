# BetterChat

A modern, SwiftUI-native chat framework that provides beautiful, customizable messaging experiences with minimal setup.

## Overview

BetterChat offers a complete chat solution built entirely in SwiftUI, featuring:

- **Modern Architecture**: Protocol-oriented design with clean separation of concerns
- **Fully Customizable**: Comprehensive theming system with built-in presets
- **Rich Messaging**: Support for text, attachments, reactions, and thinking processes
- **Zero Dependencies**: Pure SwiftUI implementation
- **Performance Optimized**: Efficient rendering for smooth scrolling experiences

## Features

### 🎨 Theming & Customization
- **5 Built-in Themes**: Light, Dark, Blue, Green, and Minimal
- **Comprehensive Design System**: Colors, typography, spacing, and animations
- **Dynamic Theming**: Switch themes in real-time
- **Custom Theme Support**: Create your own themes easily

### 💬 Rich Messaging
- **Multiple Message Types**: Text, media, and system messages
- **Reactions**: Tap and hold to react to messages
- **Attachments**: Support for images, documents, and custom content
- **Thinking Process**: Display AI thinking steps with collapsible interface

### 🚀 Developer Experience
- **Declarative API**: SwiftUI-native approach with minimal boilerplate
- **Protocol-Oriented**: Easy to extend and customize
- **Type-Safe**: Comprehensive protocols ensure compile-time safety
- **Well-Documented**: Extensive DocC documentation with examples

## Quick Start

### Installation

Add BetterChat to your project by copying the `BetterChat` folder into your Xcode project.

### Basic Usage

```swift
import SwiftUI

struct ChatView: View {
    @StateObject private var dataSource = DemoDataSource()
    
    var body: some View {
        ModernChatView(
            dataSource: dataSource,
            attachmentActions: [
                AttachmentAction(
                    title: "Photo",
                    icon: Image(systemName: "photo"),
                    action: { 
                        ImageAttachment(
                            displayName: "Photo",
                            image: Image(systemName: "photo"),
                            thumbnail: Image(systemName: "photo")
                        )
                    }
                )
            ]
        )
        .chatTheme(.blue)
    }
}
```

### Custom Data Source

Create your own data source by implementing the `ChatDataSource` protocol:

```swift
class CustomDataSource: ObservableObject, ChatDataSource {
    @Published var messages: [DemoMessage] = []
    @Published var isTyping = false
    
    func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        let message = DemoMessage(
            id: UUID().uuidString,
            content: content,
            sender: .user,
            timestamp: Date(),
            attachments: attachments
        )
        messages.append(message)
        
        // Simulate response
        simulateResponse()
    }
    
    func reactToMessage(_ message: DemoMessage, reaction: String) {
        // Handle reactions
    }
    
    func removeReaction(from message: DemoMessage, reaction: String) {
        // Handle reaction removal
    }
}
```

## Theming

BetterChat includes a powerful theming system that allows complete customization of your chat interface.

### Built-in Themes

```swift
// Apply different themes
ModernChatView(dataSource: dataSource)
    .chatTheme(.light)    // Orange accent
    .chatTheme(.dark)     // Purple accent with dark background
    .chatTheme(.blue)     // Classic blue
    .chatTheme(.green)    // Nature green
    .chatTheme(.minimal)  // Clean gray
```

### Custom Themes

Create custom themes by defining your own color scheme:

```swift
let customTheme = ChatDesignTokens(
    colors: ChatColors(
        primary: .purple,
        secondary: Color(.systemGray5),
        background: Color(.systemBackground),
        surface: Color(.tertiarySystemBackground),
        text: .primary,
        textSecondary: .secondary,
        accent: .purple,
        error: .red,
        success: .green
    )
)

ModernChatView(dataSource: dataSource)
    .chatTheme(customTheme)
```

## Advanced Features

### Thinking Messages

Display AI thinking processes with progressive updates:

```swift
// Send "think" to trigger thinking mode
// The system will display thinking steps and then provide a response
```

### Attachments

Support various attachment types:

```swift
AttachmentAction(
    title: "Camera",
    icon: Image(systemName: "camera"),
    action: {
        ImageAttachment(
            displayName: "Camera Photo",
            image: Image(systemName: "camera"),
            thumbnail: Image(systemName: "camera")
        )
    }
)
```

### Reactions

Built-in reaction system with customizable emojis:

```swift
// Users can long-press messages to add reactions
// Default reactions: 👍 👎
// Reactions are managed automatically by the data source
```

## Architecture

BetterChat follows a clean, protocol-oriented architecture:

```
BetterChat/
├── Core/
│   ├── Protocols/          # Core protocols for extensibility
│   │   ├── MessageProtocols.swift
│   │   ├── DataSourceProtocols.swift
│   │   └── AttachmentProtocols.swift
│   ├── Models/             # Data models
│   │   ├── ThinkingModels.swift
│   │   └── Reaction.swift
│   └── BetterChat.swift    # Main framework entry
├── Views/
│   ├── ChatView/           # Main chat components
│   │   └── ModernChatView.swift
│   ├── Components/         # Reusable UI components
│   │   ├── InputArea.swift
│   │   ├── MessageRow.swift
│   │   └── ThinkingIndicatorView.swift
│   └── Modifiers/          # ViewModifiers for styling
│       ├── BubbleModifiers.swift
│       ├── InputModifiers.swift
│       ├── InteractionModifiers.swift
│       ├── LayoutModifiers.swift
│       └── ConfigurationModifiers.swift
├── Theme/                  # Theming system
│   ├── ChatTheme.swift
│   ├── ChatConstants.swift
│   └── ChatPreferences.swift
└── Demo/                   # Example implementation
    ├── DemoDataSource.swift
    ├── DemoMessage.swift
    └── DemoViews.swift
```

### Key Protocols

- **`ChatDataSource`**: Main protocol for data management
- **`ChatMessage`**: Base protocol for message types
- **`ChatAttachment`**: Protocol for attachment handling
- **`ReactableMessage`**: Protocol for messages that support reactions

## Examples

### Building a Complete Chat App

Here's how to build a complete chat application similar to the demo:

1. **Create your data source**:

```swift
class MyChatDataSource: ObservableObject, ChatDataSource {
    @Published var messages: [MyMessage] = []
    @Published var isTyping = false
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    // Implement required methods...
}
```

2. **Define your message type**:

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

3. **Create the chat view**:

```swift
struct MyChatView: View {
    @StateObject private var dataSource = MyChatDataSource()
    @State private var selectedTheme: ChatThemePreset = .blue
    
    var body: some View {
        NavigationView {
            VStack {
                themePicker
                
                ModernChatView(
                    dataSource: dataSource,
                    attachmentActions: attachmentActions
                )
                .chatTheme(selectedTheme)
            }
            .navigationTitle("My Chat")
        }
    }
    
    private var attachmentActions: [AttachmentAction] {
        [
            AttachmentAction(
                title: "Photo",
                icon: Image(systemName: "photo"),
                action: { /* Return attachment */ }
            )
        ]
    }
}
```

### Custom Message Bubbles

Customize message appearance with ViewModifiers:

```swift
Text("Custom message")
    .chatBubble(role: .user, shape: .rounded)
    .chatTheme(.green)
```

### Interactive Elements

Add interactive elements to your chat:

```swift
Button("Send") {
    // Send action
}
.sendButton()

Button("+") {
    // Attachment action
}
.attachmentButton()
```

## Performance

BetterChat is optimized for performance:

- **Efficient Rendering**: Only visible messages are rendered
- **Smooth Scrolling**: Optimized for large message lists
- **Memory Management**: Automatic cleanup of off-screen content
- **Lazy Loading**: Content loaded as needed

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Best Practices

### Data Source Implementation

1. **Use @Published for reactive updates**
2. **Implement proper message ordering**
3. **Handle errors gracefully**
4. **Provide loading states**

### Theming

1. **Use semantic colors for accessibility**
2. **Test themes in light and dark mode**
3. **Consider accessibility contrast ratios**
4. **Provide theme persistence**

### Performance

1. **Limit message history in memory**
2. **Use lazy loading for attachments**
3. **Optimize image rendering**
4. **Handle large message lists efficiently**

## Contributing

We welcome contributions! Please follow these guidelines:

1. **Code Style**: Follow Swift conventions and existing patterns
2. **Documentation**: Add DocC documentation for public APIs
3. **Testing**: Include unit tests for new features
4. **Examples**: Update examples when adding features

## License

BetterChat is available under the MIT license. See the LICENSE file for more info.

## Support

- **Documentation**: Comprehensive DocC documentation included
- **Examples**: Multiple examples and tutorials
- **Issues**: Report issues on GitHub
- **Discussions**: Join our community discussions

---

**BetterChat** - Making SwiftUI chat experiences better, one message at a time. 🚀