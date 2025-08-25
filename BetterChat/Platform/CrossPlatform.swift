import SwiftUI

// MARK: - Platform-specific type aliases and extensions

#if os(iOS)
import UIKit

public typealias PlatformImage = UIImage
public typealias PlatformColor = UIColor

extension Image {
    init(platformImage: PlatformImage) {
        self.init(uiImage: platformImage)
    }
}

extension PlatformImage {
    static func from(data: Data) -> PlatformImage? {
        UIImage(data: data)
    }
}

/// Get device name
public func getDeviceName() -> String {
    UIDevice.current.name
}

/// Get platform info
public func getPlatformInfo() -> String {
    "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
}

#elseif os(macOS)
import AppKit

public typealias PlatformImage = NSImage
public typealias PlatformColor = NSColor

extension Image {
    init(platformImage: PlatformImage) {
        self.init(nsImage: platformImage)
    }
}

extension PlatformImage {
    static func from(data: Data) -> PlatformImage? {
        NSImage(data: data)
    }
}

/// Get device name
public func getDeviceName() -> String {
    Host.current().localizedName ?? ProcessInfo.processInfo.hostName
}

/// Get platform info
public func getPlatformInfo() -> String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
}

// Add missing color extensions for macOS
extension NSColor {
    static var systemBackground: NSColor {
        return NSColor.windowBackgroundColor
    }
    
    static var secondarySystemBackground: NSColor {
        return NSColor.controlBackgroundColor
    }
    
    static var tertiarySystemBackground: NSColor {
        return NSColor.textBackgroundColor
    }
    
    static var systemGray: NSColor {
        return NSColor.gray
    }
    
    static var systemGray2: NSColor {
        return NSColor.gray.withAlphaComponent(0.8)
    }
    
    static var systemGray3: NSColor {
        return NSColor.gray.withAlphaComponent(0.6)
    }
    
    static var systemGray4: NSColor {
        return NSColor.gray.withAlphaComponent(0.4)
    }
    
    static var systemGray5: NSColor {
        return NSColor.gray.withAlphaComponent(0.2)
    }
    
    static var systemGray6: NSColor {
        return NSColor.gray.withAlphaComponent(0.1)
    }
}

#endif

// MARK: - Cross-platform utilities

/// Create an empty platform image
public func createEmptyPlatformImage() -> PlatformImage {
    #if os(iOS)
    return UIImage()
    #elseif os(macOS)
    return NSImage()
    #endif
}

/// Convert platform image to data
public func imageToData(_ image: PlatformImage, compressionQuality: CGFloat = 0.8) -> Data? {
    #if os(iOS)
    return image.jpegData(compressionQuality: compressionQuality)
    #elseif os(macOS)
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return nil
    }
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    #endif
}
