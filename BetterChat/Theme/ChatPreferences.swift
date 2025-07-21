import SwiftUI




// MARK: - Safe Area Aware Modifier
extension View {
    func safeAreaAware() -> some View {
        modifier(SafeAreaAwareModifier())
    }
}

private struct SafeAreaAwareModifier: ViewModifier {
    @Environment(\.chatTheme) private var theme
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Could update theme spacing based on safe area
                        }
                }
            )
    }
}
