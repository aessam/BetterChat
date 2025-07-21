# Quick Start

Get up and running with BetterChat in minutes.

## Overview

This guide will help you integrate BetterChat into your SwiftUI application with minimal setup. You'll learn how to create a basic chat interface and customize it to fit your needs.

## Installation

### Option 1: Direct Integration

1. Copy the `BetterChat` folder into your Xcode project
2. Ensure all files are added to your target
3. Import `BetterChat` in your SwiftUI files

### Option 2: As a Framework

1. Add BetterChat as a local Swift package
2. Import the framework in your project

## Basic Setup

### Step 1: Create a Chat View

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var dataSource = DemoDataSource()
    
    var body: some View {
        ModernChatView(dataSource: dataSource)
            .chatTheme(.blue)
    }
}
```

### Step 2: Add Attachment Support

```swift
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
```

### Step 3: Customize Theme

```swift
// Use built-in themes
.chatTheme(.dark)     // Purple theme
.chatTheme(.green)    // Green theme
.chatTheme(.minimal)  // Gray theme

// Or create custom theme
let customTheme = ChatDesignTokens(
    colors: ChatColors(primary: .purple, accent: .purple)
)
.chatTheme(customTheme)
```

## Next Steps

- <doc:BasicImplementation> - Learn about core concepts
- <doc:CustomDataSource> - Create your own data source
- <doc:ThemingGuide> - Deep dive into theming system

## Common Issues

### Build Errors

If you encounter build errors:

1. Ensure all BetterChat files are added to your target
2. Check that import statements are correct
3. Verify iOS deployment target is 15.0+

### Performance

For optimal performance:

1. Limit message history in your data source
2. Use lazy loading for attachments
3. Implement proper memory management