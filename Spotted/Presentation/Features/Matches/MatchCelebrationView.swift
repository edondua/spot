import SwiftUI

struct MatchCelebrationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    let matchedUser: User

    @State private var showContent = false
    @State private var particlesOpacity: CGFloat = 0
    @State private var photosScale: CGFloat = 0.5
    @State private var overlayOpacity: CGFloat = 0
    @State private var confetti: [ConfettiPiece] = []

    var currentUser: User {
        viewModel.currentUser
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 252/255, green: 108/255, blue: 133/255),
                    Color(red: 255/255, green: 77/255, blue: 109/255),
                    Color.purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti
            ZStack {
                ForEach(confetti) { piece in
                    ConfettiView(piece: piece)
                }
            }
            .opacity(particlesOpacity)

            VStack(spacing: 0) {
                Spacer()

                // Photos overlapping
                ZStack {
                    // Left photo (current user) - tilted left
                    ProfileImageView(user: currentUser, size: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: -5, y: 10)
                        .rotationEffect(.degrees(-15))
                        .offset(x: -60, y: 20)
                        .scaleEffect(photosScale)

                    // Right photo (matched user) - tilted right
                    ProfileImageView(user: matchedUser, size: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 5, y: 10)
                        .rotationEffect(.degrees(15))
                        .offset(x: 60, y: 20)
                        .scaleEffect(photosScale)
                }
                .padding(.bottom, 60)

                // "It's a Match!" text
                VStack(spacing: 16) {
                    Text("It's a Match!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)

                    if let location = currentUser.currentCheckIn?.location {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 16))
                            Text("You both spotted each other at \(location.name)")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    } else {
                        Text("You and \(matchedUser.name) liked each other!")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showContent)

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        // Open conversation
                        if viewModel.getConversation(with: matchedUser.id) != nil {
                            isPresented = false
                            // Navigate to chat (handled by parent)
                        }
                    } label: {
                        Text("Send Message")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)

                    Button {
                        isPresented = false
                    } label: {
                        Text("Keep Swiping")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startCelebration()
        }
    }

    private func startCelebration() {
        // Generate confetti
        for i in 0..<50 {
            confetti.append(ConfettiPiece(
                id: i,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: -20,
                color: [.yellow, .pink, .purple, .blue, .green, .orange].randomElement()!,
                rotation: Double.random(in: 0...360)
            ))
        }

        // Animate everything
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            photosScale = 1
            overlayOpacity = 1
        }

        withAnimation(.easeIn(duration: 0.5).delay(0.2)) {
            particlesOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showContent = true
        }

        // Animate confetti falling
        for i in 0..<confetti.count {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2...4)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: duration)) {
                    confetti[i].y = UIScreen.main.bounds.height + 50
                    confetti[i].rotation += Double.random(in: 360...720)
                }
            }
        }

        // Haptic feedback
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impactMedium = UIImpactFeedbackGenerator(style: .medium)
            impactMedium.impactOccurred()
        }
    }
}

// MARK: - Confetti Piece Model
struct ConfettiPiece: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    let color: Color
    var rotation: Double
}

// MARK: - Confetti View
struct ConfettiView: View {
    let piece: ConfettiPiece

    var body: some View {
        Circle()
            .fill(piece.color)
            .frame(width: 8, height: 8)
            .position(x: piece.x, y: piece.y)
            .rotationEffect(.degrees(piece.rotation))
    }
}

// MARK: - Match Celebration Coordinator
struct MatchCelebrationCoordinator: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var matchedUserId: String?

    var matchedUser: User? {
        guard let userId = matchedUserId else { return nil }
        return viewModel.getUser(by: userId)
    }

    var body: some View {
        if let matchedUser = matchedUser {
            MatchCelebrationView(
                isPresented: Binding(
                    get: { matchedUserId != nil },
                    set: { if !$0 { matchedUserId = nil } }
                ),
                matchedUser: matchedUser
            )
        }
    }
}

#Preview {
    MatchCelebrationView(
        isPresented: .constant(true),
        matchedUser: User(
            name: "Emma",
            age: 25,
            bio: "Coffee lover ☕️",
            photos: ["photo1", "photo2"],
            profilePhoto: "photo1",
            interests: ["Coffee", "Travel"]
        )
    )
    .environmentObject(AppViewModel())
}
