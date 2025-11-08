import SwiftUI

// MARK: - Animation Presets
struct AnimationPresets {
    // Spring animations
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.8)

    // Easing animations
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeInOut(duration: 0.2)
    static let slow = Animation.easeInOut(duration: 0.5)

    // Interactive animations
    static let interactive = Animation.interactiveSpring(response: 0.3, dampingFraction: 0.7)
}

// MARK: - View Modifiers for Animations
struct PressableScale: ViewModifier {
    @State private var isPressed = false
    var scale: CGFloat = 0.97

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(AnimationPresets.spring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .offset(y: isVisible ? 0 : 20)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(AnimationPresets.spring.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(AnimationPresets.smooth.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    func pressableScale(_ scale: CGFloat = 0.97) -> some View {
        modifier(PressableScale(scale: scale))
    }

    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay))
    }

    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }

    func cardStyle() -> some View {
        self
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Animated Transitions
struct HeroTransition: ViewModifier {
    let namespace: Namespace.ID
    let id: String

    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace)
    }
}

extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    static var scaleAndFade: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }

    static var slideUp: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
}
