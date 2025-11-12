import SwiftUI

// MARK: - Long Press Progress Overlay
struct LongPressProgressView: View {
    let progress: Double // 0.0 to 1.0
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background pulsing circle
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: size * 1.2, height: size * 1.2)
                .scaleEffect(1.0 + (progress * 0.3))
                .opacity(0.5 + (progress * 0.5))

            // Progress ring
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 252/255, green: 108/255, blue: 133/255),
                            Color(red: 255/255, green: 149/255, blue: 0/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)

            // Center icon that scales up
            Image(systemName: "location.fill")
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(0.8 + (progress * 0.4))
                .opacity(0.7 + (progress * 0.3))
        }
    }
}

// MARK: - Long Press Gesture Handler
struct LongPressGestureModifier: ViewModifier {
    let minimumDuration: Double
    let onComplete: () -> Void

    @State private var isPressing = false
    @State private var progress: Double = 0
    @State private var timer: Timer?

    func body(content: Content) -> some View {
        ZStack {
            content

            // Progress overlay
            if isPressing {
                LongPressProgressView(progress: progress, size: 80)
                    .allowsHitTesting(false)
            }
        }
        .scaleEffect(isPressing ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressing)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressing {
                        startPressing()
                    }
                }
                .onEnded { _ in
                    stopPressing()
                }
        )
    }

    private func startPressing() {
        isPressing = true
        progress = 0

        // Light haptic at start
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        let startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            progress = min(elapsed / minimumDuration, 1.0)

            if progress >= 1.0 {
                completePressing()
            }
        }
    }

    private func stopPressing() {
        isPressing = false
        progress = 0
        timer?.invalidate()
        timer = nil
    }

    private func completePressing() {
        timer?.invalidate()
        timer = nil

        // Medium haptic on completion
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isPressing = false
        progress = 0

        onComplete()
    }
}

extension View {
    func longPressWithProgress(minimumDuration: Double = 0.5, onComplete: @escaping () -> Void) -> some View {
        self.modifier(LongPressGestureModifier(minimumDuration: minimumDuration, onComplete: onComplete))
    }
}
