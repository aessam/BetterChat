import SwiftUI

/// Unified color system that works across iOS and macOS
public struct UnifiedColors {
    
    // MARK: - System Colors
    
    /// Primary background color
    public static var background: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    /// Secondary background color
    public static var secondaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    /// Tertiary background color
    public static var tertiaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.textBackgroundColor)
        #endif
    }
    
    // MARK: - Gray Scale
    
    public static var systemGray: Color {
        #if os(iOS)
        return Color(UIColor.systemGray)
        #elseif os(macOS)
        return Color(NSColor.gray)
        #endif
    }
    
    public static var systemGray2: Color {
        #if os(iOS)
        return Color(UIColor.systemGray2)
        #elseif os(macOS)
        return Color(NSColor.gray.withAlphaComponent(0.8))
        #endif
    }
    
    public static var systemGray3: Color {
        #if os(iOS)
        return Color(UIColor.systemGray3)
        #elseif os(macOS)
        return Color(NSColor.gray.withAlphaComponent(0.6))
        #endif
    }
    
    public static var systemGray4: Color {
        #if os(iOS)
        return Color(UIColor.systemGray4)
        #elseif os(macOS)
        return Color(NSColor.gray.withAlphaComponent(0.4))
        #endif
    }
    
    public static var systemGray5: Color {
        #if os(iOS)
        return Color(UIColor.systemGray5)
        #elseif os(macOS)
        return Color(NSColor.gray.withAlphaComponent(0.2))
        #endif
    }
    
    public static var systemGray6: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #elseif os(macOS)
        return Color(NSColor.gray.withAlphaComponent(0.1))
        #endif
    }
    
    // MARK: - Label Colors
    
    public static var label: Color {
        #if os(iOS)
        return Color(UIColor.label)
        #elseif os(macOS)
        return Color(NSColor.labelColor)
        #endif
    }
    
    public static var secondaryLabel: Color {
        #if os(iOS)
        return Color(UIColor.secondaryLabel)
        #elseif os(macOS)
        return Color(NSColor.secondaryLabelColor)
        #endif
    }
    
    public static var tertiaryLabel: Color {
        #if os(iOS)
        return Color(UIColor.tertiaryLabel)
        #elseif os(macOS)
        return Color(NSColor.tertiaryLabelColor)
        #endif
    }
    
    public static var quaternaryLabel: Color {
        #if os(iOS)
        return Color(UIColor.quaternaryLabel)
        #elseif os(macOS)
        return Color(NSColor.quaternaryLabelColor)
        #endif
    }
    
    // MARK: - Separator Colors
    
    public static var separator: Color {
        #if os(iOS)
        return Color(UIColor.separator)
        #elseif os(macOS)
        return Color(NSColor.separatorColor)
        #endif
    }
    
    public static var opaqueSeparator: Color {
        #if os(iOS)
        return Color(UIColor.opaqueSeparator)
        #elseif os(macOS)
        return Color(NSColor.separatorColor)
        #endif
    }
    
    // MARK: - Fill Colors
    
    public static var fill: Color {
        #if os(iOS)
        return Color(UIColor.systemFill)
        #elseif os(macOS)
        return Color(NSColor.controlColor)
        #endif
    }
    
    public static var secondaryFill: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemFill)
        #elseif os(macOS)
        return Color(NSColor.controlColor.withAlphaComponent(0.8))
        #endif
    }
    
    public static var tertiaryFill: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemFill)
        #elseif os(macOS)
        return Color(NSColor.controlColor.withAlphaComponent(0.6))
        #endif
    }
    
    public static var quaternaryFill: Color {
        #if os(iOS)
        return Color(UIColor.quaternarySystemFill)
        #elseif os(macOS)
        return Color(NSColor.controlColor.withAlphaComponent(0.4))
        #endif
    }
    
    // MARK: - System Colors
    
    public static var systemBlue: Color {
        #if os(iOS)
        return Color(UIColor.systemBlue)
        #elseif os(macOS)
        return Color(NSColor.systemBlue)
        #endif
    }
    
    public static var systemGreen: Color {
        #if os(iOS)
        return Color(UIColor.systemGreen)
        #elseif os(macOS)
        return Color(NSColor.systemGreen)
        #endif
    }
    
    public static var systemIndigo: Color {
        #if os(iOS)
        return Color(UIColor.systemIndigo)
        #elseif os(macOS)
        return Color(NSColor.systemIndigo)
        #endif
    }
    
    public static var systemOrange: Color {
        #if os(iOS)
        return Color(UIColor.systemOrange)
        #elseif os(macOS)
        return Color(NSColor.systemOrange)
        #endif
    }
    
    public static var systemPink: Color {
        #if os(iOS)
        return Color(UIColor.systemPink)
        #elseif os(macOS)
        return Color(NSColor.systemPink)
        #endif
    }
    
    public static var systemPurple: Color {
        #if os(iOS)
        return Color(UIColor.systemPurple)
        #elseif os(macOS)
        return Color(NSColor.systemPurple)
        #endif
    }
    
    public static var systemRed: Color {
        #if os(iOS)
        return Color(UIColor.systemRed)
        #elseif os(macOS)
        return Color(NSColor.systemRed)
        #endif
    }
    
    public static var systemTeal: Color {
        #if os(iOS)
        return Color(UIColor.systemTeal)
        #elseif os(macOS)
        return Color(NSColor.systemTeal)
        #endif
    }
    
    public static var systemYellow: Color {
        #if os(iOS)
        return Color(UIColor.systemYellow)
        #elseif os(macOS)
        return Color(NSColor.systemYellow)
        #endif
    }
}