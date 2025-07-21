# ``BetterChat``

A modern, SwiftUI-native chat framework for building beautiful messaging experiences.

## Overview

BetterChat provides a complete solution for implementing chat interfaces in SwiftUI applications. Built with modern Swift patterns and focusing on developer experience, it offers powerful customization while maintaining simplicity.

### Key Features

- **🎨 Comprehensive Theming**: Built-in themes with full customization support
- **💬 Rich Messaging**: Text, attachments, reactions, and thinking processes
- **🚀 SwiftUI Native**: Declarative API that feels natural in SwiftUI
- **📱 Performance Optimized**: Smooth scrolling and efficient rendering
- **🔧 Protocol-Oriented**: Extensible architecture for custom implementations

## Topics

### Getting Started

- <doc:QuickStart>
- <doc:BasicImplementation>
- <doc:CustomDataSource>

### Core Components

- ``ModernChatView``
- ``ChatDataSource``
- ``ChatMessage``
- ``ChatAttachment``

### Theming and Customization

- <doc:ThemingGuide>
- ``ChatDesignTokens``
- ``ChatColors``
- ``ChatThemePreset``

### Advanced Features

- <doc:ThinkingMessages>
- <doc:AttachmentSystem>
- <doc:ReactionSystem>

### Protocols

- ``ChatDataSource``
- ``ChatMessage``
- ``TextMessage``
- ``ReactableMessage``
- ``MediaMessage``
- ``ChatAttachment``

### UI Components

- ``ModernChatView``
- ``InputArea``
- ``MessageRow``
- ``ThinkingIndicatorView``

### Models

- ``ThinkingThought``
- ``ThinkingSession``
- ``Reaction``
- ``ImageAttachment``
- ``AttachmentAction``

### View Modifiers

- ``View/chatTheme(_:)``
- ``View/chatBubble(role:shape:)``
- ``View/userBubble(shape:)``
- ``View/assistantBubble(shape:)``
- ``View/systemBubble(shape:)``

### Demo and Examples

- ``DemoDataSource``
- ``DemoMessage``
- ``ModernChatDemoView``