import SwiftUI
import UIKit

/// Hinge-style container that allows switching between chat and profile
struct ChatContainerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let conversation: Conversation
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private enum DetailTab: Hashable { case chat, profile }
    @State private var selectedTab: DetailTab = .chat

    var otherUser: User? {
        let otherUserId = conversation.participants.first { $0 != viewModel.currentUser.id }
        return otherUserId.flatMap { viewModel.getUser(by: $0) }
    }

    var body: some View {
        Group {
            if let user = otherUser {
                if horizontalSizeClass == .regular {
                    // Side-by-side layout on regular width
                    HStack(spacing: 0) {
                        ChatContentView(conversation: conversation)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Divider()

                        profilePanel(user: user)
                            .frame(width: 360)
                            .background(Color(.systemBackground))
                    }
                } else {
                    // Compact width: segmented toggle to switch views
                    VStack(spacing: 0) {
                        Picker("Detail", selection: $selectedTab) {
                            Text("Chat").tag(DetailTab.chat)
                            Text("Profile").tag(DetailTab.profile)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        if selectedTab == .chat {
                            ChatContentView(conversation: conversation)
                        } else {
                            profilePanel(user: user)
                        }
                    }
                }
            }
        }
        .navigationTitle(otherUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            // For brand-new matches (no messages) on compact width, show Profile first
            if horizontalSizeClass != .regular, conversation.messages.isEmpty {
                selectedTab = .profile
            }
        }
    }

    // MARK: - Profile panel
    @ViewBuilder
    private func profilePanel(user: User) -> some View {
        UserProfileContentView(user: user)
            .toolbar(.hidden, for: .navigationBar)
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
    @State private var showPhotoPicker = false
    @State private var recordingOffset: CGFloat = 0
    @State private var shouldCancelRecording = false
    @StateObject private var audioRecorder = AudioRecorderService()
    @State private var typingWorkItem: DispatchWorkItem?
    @State private var replyContext: MessageReplyContext?

    var otherUser: User? {
        let otherUserId = conversation.participants.first { $0 != viewModel.currentUser.id }
        return otherUserId.flatMap { viewModel.getUser(by: $0) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(conversation.messages.enumerated()), id: \.element.id) { index, message in
                            let previous = index > 0 ? conversation.messages[index - 1] : nil
                            let isCurrentUser = message.senderId == viewModel.currentUser.id
                            let otherUser = self.otherUser
                            let showAvatar = !isCurrentUser && shouldShowAvatar(current: message, previous: previous)
                            let isLastOutgoing = isLastOutgoingMessage(messages: conversation.messages, index: index, currentUserId: viewModel.currentUser.id)

                            if isNewDay(current: message, previous: previous) {
                                DaySeparator(date: message.timestamp)
                                    .padding(.vertical, 6)
                            }

                            MessageRow(
                                message: message,
                                isCurrentUser: isCurrentUser,
                                showAvatar: showAvatar,
                                avatarUser: otherUser,
                                isLastOutgoing: isLastOutgoing,
                                conversationId: conversation.id,
                                onReply: { msg in
                                    replyContext = makeReplyContext(from: msg, otherUser: otherUser)
                                }
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                    viewModel.markMessagesAsRead(in: conversation.id)
                }
                .onChange(of: conversation.messages.count) { _ in
                    scrollToBottom()
                }
            }

            // Input bar
            VStack(spacing: 12) {
                if let ctx = replyContext {
                    ReplyComposerBar(context: ctx) {
                        replyContext = nil
                    }
                    .padding(.horizontal)
                }
                if showGifPicker {
                    GifPickerView(onGifSelected: { gif in
                        sendGif(gif)
                        showGifPicker = false
                    })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showPhotoPicker {
                    PhotoAttachmentPickerView(onPhotoSelected: { photoId in
                        viewModel.sendPhoto(to: conversation.id, photoUrl: photoId)
                        showPhotoPicker = false
                    })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                HStack(spacing: 10) {
                    // Typing indicator (other user)
                    if let other = otherUser, viewModel.isUserTyping(in: conversation.id, userId: other.id) {
                        TypingIndicatorRow(user: other)
                            .padding(.horizontal, 16)
                    }
                    // Photo button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showPhotoPicker.toggle()
                            if showPhotoPicker { showGifPicker = false }
                        }
                    }) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(showPhotoPicker ? Color(red: 252/255, green: 108/255, blue: 133/255) : .gray)
                            .frame(width: 44, height: 44)
                    }

                    // GIF button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showGifPicker.toggle()
                            if showGifPicker { showPhotoPicker = false }
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
                            .onChange(of: messageText) { _ in
                                handleTypingChanged()
                            }
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
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            scrollToBottom()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { _ in
            scrollToBottom()
        }
    }

    private func handleTypingChanged() {
        viewModel.setTyping(in: conversation.id, userId: viewModel.currentUser.id, isTyping: !messageText.isEmpty)
        typingWorkItem?.cancel()
        let w = DispatchWorkItem {
            viewModel.setTyping(in: conversation.id, userId: viewModel.currentUser.id, isTyping: false)
        }
        typingWorkItem = w
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: w)
    }

    private func scrollToBottom() {
        guard let lastMessage = conversation.messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }

    private func makeReplyContext(from message: Message, otherUser: User?) -> MessageReplyContext {
        let senderName = message.senderId == viewModel.currentUser.id ? "You" : (otherUser?.name ?? "Someone")
        let summary: String
        switch message.type {
        case .text:
            summary = message.text
        case .voiceMemo:
            let dur = Int(message.voiceMemoDuration ?? 0)
            summary = "Voice message (\(dur)s)"
        case .gift:
            summary = "Gift \(message.giftEmoji ?? "🎁")"
        case .gif:
            summary = message.text.isEmpty ? "GIF" : message.text
        case .photo:
            summary = message.text.isEmpty ? "Photo" : message.text
        }
        return MessageReplyContext(messageId: message.id, senderId: message.senderId, senderName: senderName, summary: summary)
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.sendMessage(to: conversation.id, text: trimmedMessage, reply: replyContext)

        messageText = ""
        replyContext = nil

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

// MARK: - Helper Functions
private func isNewDay(current: Message, previous: Message?) -> Bool {
    guard let prev = previous else { return true }
    let cal = Calendar.current
    return !cal.isDate(prev.timestamp, inSameDayAs: current.timestamp)
}

private func shouldShowAvatar(current: Message, previous: Message?) -> Bool {
    guard let prev = previous else { return true }
    if prev.senderId != current.senderId { return true }
    // Show avatar if time gap > 5 minutes to start a new visual group
    return current.timestamp.timeIntervalSince(prev.timestamp) > 5 * 60
}

private func isLastOutgoingMessage(messages: [Message], index: Int, currentUserId: String) -> Bool {
    guard messages.indices.contains(index) else { return false }
    let isOutgoing = messages[index].senderId == currentUserId
    if !isOutgoing { return false }
    // No later message from current user
    return !messages[(index+1)..<messages.count].contains { $0.senderId == currentUserId }
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
