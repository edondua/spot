import SwiftUI

/// Hinge-style container that allows switching between chat and profile
struct ChatContainerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let conversation: Conversation
    @State private var selectedTab = 0

    var otherUser: User? {
        let otherUserId = conversation.participants.first { $0 != viewModel.currentUser.id }
        return otherUserId.flatMap { viewModel.getUser(by: $0) }
    }

    var body: some View {
        ZStack {
            if let user = otherUser {
                // Full screen swipeable content
                TabView(selection: $selectedTab) {
                    // Chat view
                    ChatContentView(conversation: conversation)
                        .tag(0)

                    // Profile view - full screen
                    ScrollView {
                        UserProfileContentView(user: user)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Subtle page indicator at top
                VStack {
                    HStack(spacing: 8) {
                        // Chat indicator
                        Circle()
                            .fill(selectedTab == 0 ? Color(red: 252/255, green: 108/255, blue: 133/255) : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)

                        // Profile indicator
                        Circle()
                            .fill(selectedTab == 1 ? Color(red: 252/255, green: 108/255, blue: 133/255) : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    .padding(.top, 8)

                    Spacer()
                }
            }
        }
        .navigationTitle(otherUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

/// Chat content without navigation wrapper
struct ChatContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let conversation: Conversation
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var isRecording = false
    @State private var showGifPicker = false
    @State private var recordingOffset: CGFloat = 0
    @State private var shouldCancelRecording = false
    @StateObject private var audioRecorder = AudioRecorderService()

    var otherUser: User? {
        let otherUserId = conversation.participants.first { $0 != viewModel.currentUser.id }
        return otherUserId.flatMap { viewModel.getUser(by: $0) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(conversation.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == viewModel.currentUser.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                    viewModel.markMessagesAsRead(in: conversation.id)
                }
            }

            // Input bar
            VStack(spacing: 12) {
                if showGifPicker {
                    GifPickerView(onGifSelected: { gif in
                        sendGif(gif)
                        showGifPicker = false
                    })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                HStack(spacing: 10) {
                    // GIF button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showGifPicker.toggle()
                        }
                    }) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(showGifPicker ? Color(red: 252/255, green: 108/255, blue: 133/255) : .gray)
                            .frame(width: 44, height: 44)
                    }

                    // Text input
                    HStack(spacing: 8) {
                        TextField("Type a message", text: $messageText)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .disabled(isRecording)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(24)

                    // Voice memo / Send button
                    if messageText.isEmpty {
                        if !isRecording {
                            // Mic button
                            Button(action: {}) {
                                Circle()
                                    .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "mic.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.1)
                                    .onEnded { _ in
                                        startRecording()
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if isRecording {
                                            recordingOffset = value.translation.width
                                            if recordingOffset < -100 {
                                                shouldCancelRecording = true
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        if isRecording {
                                            stopRecording()
                                        }
                                    }
                            )
                        } else {
                            // Stop recording button
                            Button(action: {
                                stopRecording()
                            }) {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "stop.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    } else {
                        // Send button
                        Button(action: sendMessage) {
                            Circle()
                                .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
        }
    }

    private func scrollToBottom() {
        guard let lastMessage = conversation.messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.sendMessage(to: conversation.id, text: trimmedMessage)

        messageText = ""

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom()
        }
    }

    private func sendGif(_ gif: GifItem) {
        viewModel.sendGif(to: conversation.id, gifUrl: gif.url.absoluteString, caption: nil)

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom()
        }
    }

    private func startRecording() {
        isRecording = true
        recordingOffset = 0
        shouldCancelRecording = false
        audioRecorder.startRecording()

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func stopRecording() {
        isRecording = false

        if shouldCancelRecording {
            audioRecorder.cancelRecording()
            shouldCancelRecording = false
        } else {
            audioRecorder.stopRecording { url, duration in
                if let url = url {
                    viewModel.sendVoiceMemo(to: conversation.id, audioUrl: url.path, duration: duration)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom()
                    }
                }
            }
        }

        recordingOffset = 0

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

/// User profile content without navigation wrapper
struct UserProfileContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let user: User

    var body: some View {
        UserProfileView(user: user)
            .environmentObject(viewModel)
    }
}

#Preview {
    let viewModel = AppViewModel()
    return NavigationStack {
        ChatContainerView(conversation: viewModel.conversations.first!)
            .environmentObject(viewModel)
    }
}
