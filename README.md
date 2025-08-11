# BetterChat

A clean, customizable SwiftUI chat interface that focuses on simplicity and flexibility.

## Quick Start

### Basic Usage (3 lines!)

```swift
import BetterChat

// That's it!
BetterChat.chat(dataSource)
```

### With Customization

```swift
BetterChat.chat(
    dataSource,
    reactions: ["👍", "👎"],  // Double-tap reactions
    
    // Left button slot
    accessory: {
        Button("📎") { /* your action */ }
    },
    
    // Bar above input field  
    inputAccessory: {
        HStack {
            Button("Quick Reply 1") { }
            Button("Quick Reply 2") { }
        }
    },
    
    // Suggestions (@ mentions, # channels, etc)
    suggestions: { text in
        if text.hasPrefix("@") {
            MentionsList()
        }
    }
)
```

## Features

✅ **Simple** - 3-line basic usage  
✅ **Flexible** - Customizable slots for any UI  
✅ **Clean** - BetterChat only renders chat, you handle the rest  
✅ **Reactions** - Double-tap for reactions (one per message)  
✅ **Themes** - Built-in theming system  

## Demo

Run `TestableDemo.swift` to see all features with interactive toggles:
- Toggle attachment button
- Toggle input accessory bar  
- Toggle mentions (@/#)
- Toggle reactions
- Claude stickers! 🤖 🧠 ✨ 🎯 💭 🔮

## What BetterChat Does

- Renders messages
- Handles reactions  
- Shows typing indicators
- Manages scroll behavior
- Provides theming

## What BetterChat Doesn't Do

- Attachments (use accessory slot)
- Message effects (use inputAccessory slot)  
- Autocomplete (use suggestions slot)
- Backend integration (your responsibility)

## Requirements

- iOS 17.0+
- Swift 5.9+
- SwiftUI

## License

MIT