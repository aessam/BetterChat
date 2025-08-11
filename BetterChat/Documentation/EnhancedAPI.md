# BetterChat Enhanced API Documentation

## Overview

BetterChat now provides a powerful, extensible API for creating fully customized chat interfaces with support for custom message types, attachables, and reactions.

## Core APIs

### 1. Message Type Registration

Register custom message types with their corresponding views:

```swift
let config = BetterChat.configured()
    .registerMessageType(VoiceMessage.self) { message in
        VoiceMessageView(message: message)
    }
    .registerMessageType(LocationMessage.self) { message in
        LocationMessageView(message: message)
    }
```

### 2. Attachable System

Register attachable types with pickers and cell views:

```swift
config.attachable(PhotoAttachable.self,
    picker: { 
        PhotoPicker() 
    },
    cellView: { attachable in
        PhotoCellView(attachable: attachable)
    },
    converter: { photo in
        ImageAttachment(
            displayName: photo.displayName,
            image: Image(uiImage: photo.data)
        )
    }
)
```

### 3. Reaction System

Register reactions with callbacks and configuration:

```swift
config.registerReactions(
    ["🤌🏼", "👎", "❤️", "👍", "😂"],
    allowEdit: false,  // Prevent editing after selection
    selectionCallback: { emoji, message in
        // Called when user selects a reaction
        print("User reacted with \(emoji)")
    },
    removalCallback: { emoji, message in
        // Called when user removes a reaction
        print("User removed \(emoji)")
    }
)
```

## Key Features

### User Reaction Display
- User's own reaction appears as a badge at the bottom-right of their message bubble
- Visual feedback shows which reaction the user selected
- Reactions can be changed or removed based on `allowEdit` setting

### Reaction Behavior
- **allowEdit: true** - Users can change or remove their reactions
- **allowEdit: false** - Once selected, reactions are permanent
- Selection callbacks enable analytics, backend updates, or animations
- The reaction picker shows user's current reaction with reduced opacity

### Message Type Flexibility
- Any type conforming to `ChatMessage` can be registered
- Custom views can display any content (voice, video, location, etc.)
- Fallback rendering for unregistered types

### Attachable Architecture
- Separate picker UI from attachment data
- Custom cell views for attachment preview
- Automatic conversion to `ChatAttachment` protocol

## Complete Example

```swift
struct AppChatView: View {
    @StateObject private var dataSource = AppDataSource()
    
    var body: some View {
        let betterChat = BetterChat.configured()
            // Custom message types
            .registerMessageType(VoiceMessage.self) { message in
                VoiceMessageView(message: message)
            }
            .registerMessageType(PollMessage.self) { message in
                PollMessageView(message: message)
            }
            
            // Attachables with pickers
            .attachable(PhotoAttachable.self,
                picker: { PhotoPicker() },
                cellView: { PhotoCellView(attachable: $0) },
                converter: { photo in
                    ImageAttachment(image: photo.image)
                }
            )
            .attachable(LocationAttachable.self,
                picker: { LocationPicker() },
                cellView: { LocationCellView(attachable: $0) },
                converter: { location in
                    CustomLocationAttachment(
                        lat: location.latitude,
                        lng: location.longitude
                    )
                }
            )
            
            // Reactions with behavior
            .registerReactions(
                ["🤌🏼", "👎", "❤️", "🔥", "😂"],
                allowEdit: false,
                selectionCallback: { emoji, message in
                    // Track analytics
                    Analytics.track(.reaction, properties: [
                        "emoji": emoji,
                        "messageId": message.id
                    ])
                    
                    // Update backend
                    APIClient.shared.addReaction(emoji, to: message.id)
                },
                removalCallback: { emoji, message in
                    APIClient.shared.removeReaction(emoji, from: message.id)
                }
            )
        
        BetterChat.chatView(
            dataSource: dataSource,
            configuration: betterChat
        )
    }
}
```

## Implementation Notes

### Creating Custom Message Types

```swift
struct CustomMessage: ChatMessage {
    let id: String
    let timestamp: Date
    let sender: MessageSender
    let status: MessageStatus
    
    // Add your custom properties
    let customData: YourDataType
}
```

### Creating Attachables

```swift
struct CustomAttachable: Attachable {
    let data: YourDataType
    
    var previewImage: Image? {
        // Return preview image if available
    }
    
    var displayName: String {
        // Return display name
    }
}
```

### DataSource Integration

Your data source handles the actual message operations while the configuration handles the UI and callbacks:

```swift
class AppDataSource: ChatDataSource {
    func reactToMessage(_ message: Message, reaction: String) {
        // Update local state
        // The reaction callback will handle backend/analytics
    }
}
```

## Migration Guide

From the old API:
```swift
// Old
let chatView = BetterChat.chatView(dataSource: dataSource)
```

To the new enhanced API:
```swift
// New
let config = BetterChat.configured()
    .registerMessageType(...)
    .attachable(...)
    .registerReactions(...)

let chatView = BetterChat.chatView(
    dataSource: dataSource,
    configuration: config
)
```

## Benefits

1. **Type Safety** - Leverages Swift's type system for compile-time safety
2. **Extensibility** - Add unlimited message types and attachables
3. **Callbacks** - React to user interactions with custom logic
4. **Visual Feedback** - User's reactions shown as badges on messages
5. **Flexible Configuration** - Control reaction behavior per app requirements
6. **Clean Separation** - UI configuration separate from data management