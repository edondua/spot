import SwiftUI

struct ProfileVerificationView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var verificationStep: VerificationStep = .intro
    @State private var showCamera = false
    @State private var capturedImage: UIImage? = nil
    @State private var isVerifying = false
    @State private var showContent = false

    enum VerificationStep {
        case intro
        case instructions
        case camera
        case processing
        case success
        case failed
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                switch verificationStep {
                case .intro:
                    introView
                case .instructions:
                    instructionsView
                case .camera:
                    cameraView
                case .processing:
                    processingView
                case .success:
                    successView
                case .failed:
                    failedView
                }
            }
        }
        .navigationTitle("Verify Your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if verificationStep != .processing && verificationStep != .success {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $capturedImage)
        }
        .onChange(of: capturedImage) { _, newImage in
            if newImage != nil {
                verificationStep = .processing
                simulateVerification()
            }
        }
    }

    // MARK: - Intro View
    private var introView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                // Verification badge icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.2),
                                    Color.blue.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(.blue)
                }

                VStack(spacing: 16) {
                    Text("Get Verified")
                        .font(.system(size: 32, weight: .bold))

                    Text("Verified profiles get more matches and build trust with others")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                // Benefits list
                VStack(spacing: 16) {
                    VerificationBenefit(icon: "checkmark.shield.fill", text: "Show you're real", color: .blue)
                    VerificationBenefit(icon: "heart.fill", text: "Get 3x more matches", color: Color(red: 252/255, green: 108/255, blue: 133/255))
                    VerificationBenefit(icon: "star.fill", text: "Stand out from the crowd", color: .orange)
                }
                .padding(.horizontal, 40)

                // Start button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        verificationStep = .instructions
                    }
                }) {
                    Text("Start Verification")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .pressableScale()
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Instructions View
    private var instructionsView: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("How it works")
                        .font(.system(size: 28, weight: .bold))

                    Text("Follow these simple steps to verify your profile")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                .padding(.horizontal, 40)

                // Steps
                VStack(spacing: 24) {
                    VerificationInstructionStep(
                        number: 1,
                        icon: "face.smiling",
                        title: "Take a selfie",
                        description: "We'll take a photo of you to verify your identity"
                    )

                    VerificationInstructionStep(
                        number: 2,
                        icon: "sparkles",
                        title: "Strike a pose",
                        description: "Copy the pose shown on screen to confirm it's really you"
                    )

                    VerificationInstructionStep(
                        number: 3,
                        icon: "checkmark.seal.fill",
                        title: "Get verified!",
                        description: "We'll review your photo and verify you within minutes"
                    )
                }
                .padding(.horizontal, 32)

                // Privacy note
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.blue)
                        Text("Your privacy is protected")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Text("Your verification photo is encrypted and never shown on your profile")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 32)

                // Continue button
                Button(action: {
                    showCamera = true
                    verificationStep = .camera
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Open Camera")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .pressableScale()
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Camera View
    private var cameraView: some View {
        VStack {
            Spacer()
            
            Text("Opening camera...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
            
            ProgressView()
                .padding(.top, 16)
            
            Spacer()
        }
    }

    // MARK: - Processing View
    private var processingView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Captured image preview
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 4)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)

                Text("Verifying your photo...")
                    .font(.system(size: 20, weight: .semibold))

                Text("This usually takes a few seconds")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                // Success animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.2), Color.green.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(showContent ? 1 : 0.5)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(.green)
                        .scaleEffect(showContent ? 1 : 0.5)
                }
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 16) {
                    Text("You're Verified!")
                        .font(.system(size: 32, weight: .bold))
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("Your profile now has the verified badge")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    showContent = true
                }
            }

            Spacer()

            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(16)
            }
            .pressableScale()
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
        }
    }

    // MARK: - Failed View
    private var failedView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(.orange)
                }

                VStack(spacing: 16) {
                    Text("Verification Failed")
                        .font(.system(size: 28, weight: .bold))

                    Text("We couldn't verify your photo. Please try again with better lighting")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                Button(action: {
                    capturedImage = nil
                    verificationStep = .instructions
                }) {
                    Text("Try Again")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .cornerRadius(16)
                }
                .pressableScale()

                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Helper Functions
    private func simulateVerification() {
        isVerifying = true

        // Simulate verification delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isVerifying = false

            // Randomly succeed or fail for demo purposes
            // In production, this would be an actual ML/AI verification
            let success = true // Always succeed for demo

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                if success {
                    viewModel.verifyCurrentUser()
                    verificationStep = .success
                } else {
                    verificationStep = .failed
                }
            }
        }
    }
}

// MARK: - Verification Benefit Component
struct VerificationBenefit: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .cornerRadius(12)

            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - Verification Instruction Step Component
struct VerificationInstructionStep: View {
    let number: Int
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)

                Text("\(number)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)

                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }

                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

#Preview {
    ProfileVerificationView()
        .environmentObject(AppViewModel())
}
