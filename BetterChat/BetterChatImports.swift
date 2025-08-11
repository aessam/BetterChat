import SwiftUI
import Combine

// This file consolidates all the modular components
// Each file is now focused and maintainable, but we need this
// to make sure all the types are available across the module

// All the split files will automatically be compiled together
// since they're in the same target, so no additional imports needed

// MARK: - Public API Documentation
// The BetterChat module now supports:
//
// 1. Custom Message Type Registration:
//    betterChat.registerMessageType(VoiceMessage.self) { message in
//        VoiceMessageView(message: message) 
//    }
//
// 2. Attachable System with Pickers:
//    betterChat.attachable(PhotoAttachable.self,
//        picker: { PhotoPicker() },
//        cellView: { PhotoCellView(attachable: $0) },
//        converter: { /* convert to ChatAttachment */ }
//    )
//
// 3. Reaction Configuration:
//    betterChat.allowReactions([.from, .to])
//             .customReactions(["❤️", "👍", "😂"])