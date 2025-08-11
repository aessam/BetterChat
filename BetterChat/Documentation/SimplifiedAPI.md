# BetterChat Simplified API

## Philosophy

BetterChat focuses on **rendering chat UI only**. All other features (attachments, effects, suggestions) are handled by the consumer through customization slots.

## Basic Usage

```swift
// Minimal - just text messages and reactions
BetterChat.chat(dataSource)
```

## Customization Slots

BetterChat provides four customization slots:

```
┌─────────────────────────────────┐
│     Suggestion View (optional)   │ ← Autocomplete, @mentions
├─────────────────────────────────┤
│        Input Text Field          │
├──────┬──────────────────┬───────┤
│ Acc. │                  │ Send  │ ← Accessory + Input + Send
└──────┴──────────────────┴───────┘
┌─────────────────────────────────┐
│  InputAccessoryView (optional)   │ ← Message effects bar
└─────────────────────────────────┘
        [  Keyboard  ]
```

## Full Example

```swift
BetterChat.chat(
    dataSource,
    reactions: ["👍", "👎"],
    
    // Left side button (instead of attachments)
    accessory: {
        Button(action: showOptions) {
            Image(systemName: "plus")
        }
    },
    
    // Bar above keyboard (for effects, formatting, etc)
    inputAccessory: {
        HStack {
            EffectButton("💥 Slam")
            EffectButton("🌊 Gentle")
            EffectButton("👻 Invisible")
        }
        .padding()
    },
    
    // Suggestions above input field
    suggestions: { text in
        if text.hasPrefix("@") {
            MentionSuggestions(search: text)
        }
    }
)
```

## What BetterChat Does

✅ Renders messages  
✅ Handles reactions (configurable)  
✅ Shows typing indicators  
✅ Manages scroll behavior  
✅ Provides theming  

## What BetterChat Doesn't Do

❌ Attachments (use accessory slot)  
❌ Message effects (use inputAccessory slot)  
❌ Autocomplete (use suggestions slot)  
❌ Custom message types (keep it simple)  
❌ Backend integration (consumer's responsibility)

## Migration from Complex API

Before (552 lines):
```swift
let config = BetterChat.configured()
    .registerMessageType(VoiceMessage.self) { ... }
    .attachable(PhotoAttachable.self, ...) 
    .registerReactions(...)

BetterChat.chatView(dataSource, configuration: config)
```

After (< 100 lines):
```swift
BetterChat.chat(
    dataSource,
    accessory: { /* your button */ },
    inputAccessory: { /* your effects */ },
    suggestions: { /* your autocomplete */ }
)
```

## Benefits

1. **Separation of Concerns** - BetterChat only handles chat rendering
2. **Full Control** - Consumers own all custom features
3. **Simple Demo** - 154 lines vs 552 lines
4. **No Assumptions** - No forced attachment system
5. **Flexible** - Use any or none of the slots

## Input Accessory View Use Cases

The `inputAccessory` slot appears above the keyboard and is perfect for:

- **Message Effects**: Slam, Gentle, Invisible Ink
- **Text Formatting**: Bold, Italic, Code blocks  
- **Quick Actions**: Templates, Canned responses
- **Send Options**: Schedule, Priority, Encrypt
- **Rich Input**: Voice recording, Drawing tools

## Keyboard Behavior

- Scrolling dismisses keyboard immediately (not interactively)
- Input accessory view moves with keyboard
- Proper keyboard avoidance built-in