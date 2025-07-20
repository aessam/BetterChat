import SwiftUI

public struct ReactionHandler: ViewModifier {
    let onReaction: (String) -> Void
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear.onTapGesture { location in
                        // Handle tap on reaction buttons
                    }
                }
            )
    }
}

public extension View {
    func onReactionSelected(_ action: @escaping (String) -> Void, isPresented: Binding<Bool>) -> some View {
        self.modifier(ReactionHandler(onReaction: action, isPresented: isPresented))
    }
}