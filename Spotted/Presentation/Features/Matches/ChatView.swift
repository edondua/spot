import SwiftUI
import AVFoundation
import WebKit
import UIKit

struct ChatView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let conversation: Conversation
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var isRecording = false
    @State private var showGiftPicker = false
    @State private var showGifPicker = false
    @State private var showPhotoPicker = false
    @State private var showProfileSheet = false
    @State private var recordingOffset: CGFloat = 0
    @State private var shouldCancelRecording = false
    @StateObject private var audioRecorder = AudioRecorderService()
    @State private var typingWorkItem: DispatchWorkItem?
    @State private var replyContext: MessageReplyContext?

    private enum DetailTab: Hashable { case chat, profile }
    @State private var selectedTab: DetailTab = .chat

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
                                    replyContext = makeReplyContext(from: msg)
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
                    // Mark messages as read
                    viewModel.markMessagesAsRead(in: conversation.id)
                }
                .onChange(of: conversation.messages.count) { _ in
                    scrollToBottom()
                }
            }

            // Input bar
            VStack(spacing: 12) {
                // Gift picker
                if showGiftPicker {
                    GiftPickerView(onGiftSelected: { gift in
                        sendGift(gift)
                        showGiftPicker = false
                    })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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

                // Reply composer (if replying)
                if let ctx = replyContext {
                    ReplyComposerBar(context: ctx) {
                        replyContext = nil
                    }
                    .padding(.horizontal, 16)
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
                            if showPhotoPicker { showGifPicker = false; showGiftPicker = false }
                        }
                    }) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(showPhotoPicker ? Color(red: 252/255, green: 108/255, blue: 133/255) : .gray)
                            .frame(width: 44, height: 44)
                    }

                    // Gift button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showGiftPicker.toggle()
                            if showGiftPicker { showGifPicker = false; showPhotoPicker = false }
                        }
                    }) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(showGiftPicker ? Color(red: 252/255, green: 108/255, blue: 133/255) : .gray)
                            .frame(width: 44, height: 44)
                    }

                    // GIF button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showGifPicker.toggle()
                            if showGifPicker { showGiftPicker = false; showPhotoPicker = false }
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
                    .cornerRadius(22)

                    // Voice memo or send button
                    if messageText.isEmpty && !isRecording {
                        // Voice memo button (Telegram style - hold to record)
                        Button(action: {
                            // Tap action (optional)
                        }) {
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
                                        // Track horizontal drag for cancel
                                        recordingOffset = value.translation.width

                                        // Cancel if dragged left more than 100pt
                                        if recordingOffset < -100 {
                                            shouldCancelRecording = true
                                        } else {
                                            shouldCancelRecording = false
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    if isRecording {
                                        if shouldCancelRecording {
                                            cancelRecording()
                                        } else {
                                            stopRecording()
                                        }
                                        recordingOffset = 0
                                        shouldCancelRecording = false
                                    }
                                }
                        )
                    } else if isRecording {
                        // Stop recording button
                        Button(action: {
                            stopRecording()
                            recordingOffset = 0
                            shouldCancelRecording = false
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
                    } else if !messageText.isEmpty {
                        // Send text button
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
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                // Recording indicator (Telegram style)
                if isRecording {
                    HStack(spacing: 12) {
                        // Cancel indicator (slide left)
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(shouldCancelRecording ? .red : .gray)
                            Text(shouldCancelRecording ? "Release to cancel" : "< Slide to cancel")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(shouldCancelRecording ? .red : .gray)
                        }
                        .opacity(0.7 + abs(recordingOffset) / 200.0)

                        Spacer()

                        // Recording duration with animated waveform
                        HStack(spacing: 8) {
                            // Animated waveform bars
                            HStack(spacing: 2) {
                                ForEach(0..<4, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.red)
                                        .frame(width: 2, height: CGFloat.random(in: 6...20))
                                        .animation(
                                            Animation.easeInOut(duration: 0.3)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(index) * 0.1),
                                            value: audioRecorder.recordingDuration
                                        )
                                }
                            }

                            Text("\(formatDuration(audioRecorder.recordingDuration))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .offset(x: recordingOffset)
                }
            }
            .background(Color(.systemBackground))
        }
        // Compact layout: full-screen overlay for the profile panel when selected
        .overlay(alignment: .center) {
            if selectedTab == .profile, horizontalSizeClass != .regular {
                profilePanel
                    .background(Color(.systemBackground))
                    .ignoresSafeArea()
            }
        }
        // Compact layout: show a segmented toggle at the top to switch Chat/Profile (kept above overlay)
        .safeAreaInset(edge: .top) {
            if horizontalSizeClass != .regular, otherUser != nil {
                Picker("Detail", selection: $selectedTab) {
                    Text("Chat").tag(DetailTab.chat)
                    Text("Profile").tag(DetailTab.profile)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        // Regular layout: persistent side panel for profile on the right
        .safeAreaInset(edge: .trailing) {
            if horizontalSizeClass == .regular, otherUser != nil {
                profilePanel
                    .frame(width: 360)
                    .background(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: -2, y: 0)
            }
        }
        .toolbar {
            if let otherUser = otherUser {
                ToolbarItem(placement: .principal) {
                    Button {
                        showProfileSheet = true
                    } label: {
                        HStack(spacing: 10) {
                            ProfileImageView(user: otherUser, size: 36, showVerificationBadge: false)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(otherUser.displayName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("View profile")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            if let otherUser = otherUser {
                NavigationStack {
                    UserProfileView(user: otherUser)
                        .environmentObject(viewModel)
                }
            }
        }
        .navigationTitle(otherUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            audioRecorder.checkPermission()
            // For brand-new matches (no messages), default to Profile on compact width
            if horizontalSizeClass != .regular, conversation.messages.isEmpty {
                selectedTab = .profile
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            scrollToBottom()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { _ in
            scrollToBottom()
        }
    }

    private func handleTypingChanged() {
        // Mark current user as typing and debounce stop
        viewModel.setTyping(in: conversation.id, userId: viewModel.currentUser.id, isTyping: !messageText.isEmpty)
        typingWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            viewModel.setTyping(in: conversation.id, userId: viewModel.currentUser.id, isTyping: false)
        }
        typingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }

    // MARK: - Profile panel view
    @ViewBuilder
    private var profilePanel: some View {
        if let otherUser = otherUser {
            UserProfileView(user: otherUser)
                .environmentObject(viewModel)
                .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        viewModel.sendMessage(to: conversation.id, text: messageText, reply: replyContext)
        messageText = ""
        replyContext = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom()
        }
    }

    private func makeReplyContext(from message: Message) -> MessageReplyContext {
        let senderName: String
        if message.senderId == viewModel.currentUser.id {
            senderName = "You"
        } else {
            senderName = otherUser?.name ?? "Someone"
        }
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

    private func startRecording() {
        audioRecorder.startRecording()
        isRecording = true

        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }

    private func stopRecording() {
        audioRecorder.stopRecording { url, duration in
            if let url = url {
                viewModel.sendVoiceMemo(to: conversation.id, audioUrl: url.path, duration: duration)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToBottom()
                }
            }
        }
        isRecording = false

        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }

    private func cancelRecording() {
        audioRecorder.cancelRecording()
        isRecording = false

        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func sendGift(_ gift: String) {
        viewModel.sendGift(to: conversation.id, giftEmoji: gift)

        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom()
        }
    }

    private func sendGif(_ gif: GifItem) {
        viewModel.sendGif(to: conversation.id, gifUrl: gif.url.absoluteString, caption: gif.title)

        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom()
        }
    }

    private func scrollToBottom() {
        if let lastMessage = conversation.messages.last {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let currentUser: User
    let otherUser: User?
    @StateObject private var audioPlayer = AudioPlayerService()

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 3) {
                if let reply = message.replyTo {
                    ReplyHeader(context: reply, avatar: avatarForReply(reply))
                }
                // Message content based on type
                switch message.type {
                case .text:
                    textBubble
                case .voiceMemo:
                    voiceMemoBubble
                case .gift:
                    giftBubble
                case .gif:
                    gifBubble
                case .photo:
                    photoBubble
                }

                // Time and status
                HStack(spacing: 4) {
                    Text(message.timeDisplay)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    // Status indicator (only for current user's messages)
                    if isCurrentUser {
                        messageStatusView
                    }
                }

                // Reactions (if any)
                if let reactions = message.reactions, !reactions.isEmpty {
                    ReactionsPillView(reactions: reactions)
                }
            }

            if !isCurrentUser { Spacer() }
        }
    }

    // Reply header inside bubble
    private struct ReplyHeader: View {
        let context: MessageReplyContext
        let avatar: User?
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                if let user = avatar {
                    ProfileImageView(user: user, size: 18, showVerificationBadge: false)
                        .clipShape(Circle())
                } else {
                    Rectangle()
                        .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .frame(width: 3)
                        .cornerRadius(1.5)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.senderName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(context.summary)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }

    private func avatarForReply(_ reply: MessageReplyContext) -> User? {
        if reply.senderId == currentUser.id { return currentUser }
        if let other = otherUser, reply.senderId == other.id { return other }
        return nil
    }

    // Message status indicator
    @ViewBuilder
    private var messageStatusView: some View {
        switch message.status {
        case .sending:
            Image(systemName: "clock")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        case .sent:
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
        case .delivered:
            HStack(spacing: -3) {
                Image(systemName: "checkmark")
                Image(systemName: "checkmark")
            }
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.secondary)
        case .read:
            HStack(spacing: -3) {
                Image(systemName: "checkmark")
                Image(systemName: "checkmark")
            }
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.blue)
        case .failed:
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 10))
                .foregroundColor(.red)
        }
    }

    private var textBubble: some View {
        Text(message.text)
            .font(.system(size: 16))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isCurrentUser ?
                    Color(red: 252/255, green: 108/255, blue: 133/255) :
                    Color(.systemGray5)
            )
            .foregroundColor(isCurrentUser ? .white : .primary)
            .cornerRadius(18)
    }

    private var voiceMemoBubble: some View {
        HStack(spacing: 12) {
            // Play button (Telegram style - circular)
            Button(action: {
                if audioPlayer.isPlaying {
                    audioPlayer.pause()
                } else if let url = message.voiceMemoUrl {
                    audioPlayer.play(url: URL(fileURLWithPath: url))
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isCurrentUser ? Color.white.opacity(0.3) : Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isCurrentUser ? .white : Color(red: 252/255, green: 108/255, blue: 133/255))
                        .offset(x: audioPlayer.isPlaying ? 0 : 1)
                }
            }

            // Waveform visualization with progress (Telegram/WhatsApp style)
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<25, id: \.self) { index in
                    let barProgress = Double(index) / 25.0
                    let isPlayed = barProgress < audioPlayer.progress

                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(
                            isPlayed ?
                                (isCurrentUser ? Color.white : Color(red: 252/255, green: 108/255, blue: 133/255)) :
                                (isCurrentUser ? Color.white.opacity(0.4) : Color.gray.opacity(0.4))
                        )
                        .frame(width: 2, height: waveformHeight(for: index, isPlaying: audioPlayer.isPlaying))
                        .animation(.easeInOut(duration: 0.3), value: audioPlayer.progress)
                        .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true), value: audioPlayer.isPlaying)
                }
            }
            .frame(width: 120)

            // Duration (shows current time when playing, total duration otherwise)
            if let duration = message.voiceMemoDuration {
                Text(audioPlayer.isPlaying ? formatDuration(audioPlayer.currentTime) : formatDuration(duration))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isCurrentUser ? .white.opacity(0.9) : .secondary)
                    .monospacedDigit()
                    .animation(.none, value: audioPlayer.currentTime)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            isCurrentUser ?
                Color(red: 252/255, green: 108/255, blue: 133/255) :
                Color(.systemGray5)
        )
        .cornerRadius(18)
    }

    private func waveformHeight(for index: Int, isPlaying: Bool) -> CGFloat {
        // Create a more realistic waveform pattern
        let baseHeights: [CGFloat] = [4, 8, 12, 16, 14, 10, 6, 8, 14, 18, 16, 12, 10, 14, 16, 12, 8, 6, 10, 14, 12, 8, 6, 4, 6]
        let baseHeight = baseHeights[index % baseHeights.count]

        // Add subtle pulsing animation during playback
        if isPlaying {
            let variation = CGFloat.random(in: -2...2)
            return max(4, baseHeight + variation)
        }

        return baseHeight
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var giftBubble: some View {
        VStack(spacing: 8) {
            Text(message.giftEmoji ?? "🎁")
                .font(.system(size: 60))

            Text("Sent you a gift!")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isCurrentUser ? .white : .primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            isCurrentUser ?
                Color(red: 252/255, green: 108/255, blue: 133/255) :
                Color(.systemGray5)
        )
        .cornerRadius(20)
    }

    private var gifBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let urlString = message.gifUrl, let url = URL(string: urlString) {
                GIFPlayerView(url: url)
                    .frame(width: 220, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(isCurrentUser ? 0.3 : 0.1), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray5))
                    .frame(width: 220, height: 180)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    )
            }

            Text(message.text.isEmpty ? "GIF" : message.text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isCurrentUser ? .white.opacity(0.9) : .primary)
        }
        .padding(12)
        .background(
            isCurrentUser ?
                Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.9) :
                Color(.systemGray5)
        )
        .cornerRadius(20)
    }

    private var photoBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let photoId = message.photoUrl {
                PhotoPlaceholderView(photoId: photoId, aspectRatio: 4/3)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray5))
                    .frame(width: 220, height: 160)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    )
            }
            if !message.text.isEmpty && message.text != "Photo" {
                Text(message.text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isCurrentUser ? .white.opacity(0.9) : .primary)
            }
        }
        .padding(12)
        .background(
            isCurrentUser ?
                Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.9) :
                Color(.systemGray5)
        )
        .cornerRadius(20)
    }
}

// MARK: - Message Row with Avatar and Grouping
struct MessageRow: View {
    let message: Message
    let isCurrentUser: Bool
    let showAvatar: Bool
    let avatarUser: User?
    let isLastOutgoing: Bool
    @State private var showReactionsBar = false
    @EnvironmentObject private var viewModel: AppViewModel
    let conversationId: String
    let onReply: (Message) -> Void
    @State private var dragX: CGFloat = 0

    var body: some View {
        ZStack(alignment: .leading) {
            if dragX > 0 {
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    .padding(.leading, 12)
                    .transition(.opacity)
            }

            HStack(alignment: .bottom, spacing: 8) {
                if isCurrentUser {
                    Spacer(minLength: 40)
                    VStack(alignment: .trailing, spacing: 4) {
                        MessageBubble(message: message, isCurrentUser: true, currentUser: viewModel.currentUser, otherUser: avatarUser)
                            .onLongPressGesture { showReactionsBar.toggle() }
                        .overlay(alignment: .topTrailing) {
                            if showReactionsBar { ReactionPicker { emoji in
                                viewModel.toggleReaction(in: conversationId, messageId: message.id, emoji: emoji, by: viewModel.currentUser.id)
                                showReactionsBar = false
                            }
                            .offset(y: -44)
                            }
                        }
                    if isLastOutgoing, message.status == .read, let user = avatarUser {
                        HStack(spacing: 6) {
                            Text("Seen")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            ProfileImageView(user: user, size: 14, showVerificationBadge: false)
                                .clipShape(Circle())
                        }
                    }
                }
                } else {
                    if showAvatar, let user = avatarUser {
                        ProfileImageView(user: user, size: 28, showVerificationBadge: false)
                            .padding(.bottom, 2)
                    } else {
                        Color.clear.frame(width: 28, height: 28)
                    }
                    MessageBubble(message: message, isCurrentUser: false, currentUser: viewModel.currentUser, otherUser: avatarUser)
                        .onLongPressGesture { showReactionsBar.toggle() }
                        .overlay(alignment: .topLeading) {
                            if showReactionsBar { ReactionPicker { emoji in
                                viewModel.toggleReaction(in: conversationId, messageId: message.id, emoji: emoji, by: viewModel.currentUser.id)
                                showReactionsBar = false
                            }
                            .offset(y: -44)
                            }
                        }
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .offset(x: min(dragX, 80))
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        // Only consider rightward drags for reply
                        dragX = max(0, value.translation.width)
                    }
                    .onEnded { _ in
                        if dragX > 60 {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            onReply(message)
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragX = 0
                        }
                    }
            )
        }
    }
}

// MARK: - Day Separator
struct DaySeparator: View {
    let date: Date
    var body: some View {
        HStack {
            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
            Text(dayString(for: date)).font(.system(size: 12, weight: .semibold)).foregroundColor(.secondary)
            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
        }
        .padding(.horizontal, 16)
    }

    private func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Helpers
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

// MARK: - Photo Attachment Picker
struct PhotoAttachmentPickerView: View {
    let onPhotoSelected: (String) -> Void
    private let photos = (1...12).map { "photo\($0)" }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Send a photo")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(photos, id: \.self) { pid in
                        Button(action: { onPhotoSelected(pid) }) {
                            PhotoPlaceholderView(photoId: pid, aspectRatio: 1.0)
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Reply Composer Bar
struct ReplyComposerBar: View {
    let context: MessageReplyContext
    let onCancel: () -> Void
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                .frame(width: 3, height: 36)
                .cornerRadius(1.5)
            VStack(alignment: .leading, spacing: 2) {
                Text("Replying to \(context.senderName)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(context.summary)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Reactions UI
struct ReactionPicker: View {
    let onPick: (String) -> Void
    // Extended emoji set (can be expanded freely)
    private let emojis: [String] = [
        "👍","❤️","😂","😮","😢","🙏","🔥","👏","😍","😎",
        "🤔","😅","🎉","✨","💯","🤯","🤗","🙌","👀","😴"
    ]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(emojis, id: \.self) { e in
                    Text(e)
                        .font(.system(size: 20))
                        .padding(6)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .onTapGesture { onPick(e) }
                }
            }
            .padding(6)
        }
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
    }
}

struct ReactionsPillView: View {
    // emoji -> set(userIds)
    let reactions: [String: Set<String>]
    private var counts: [(String, Int)] {
        reactions.map { ($0.key, $0.value.count) }.sorted { $0.0 < $1.0 }
    }
    var body: some View {
        HStack(spacing: 6) {
            ForEach(counts, id: \.0) { (emoji, count) in
                HStack(spacing: 4) {
                    Text(emoji)
                    Text("\(count)").font(.system(size: 11, weight: .semibold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.top, 2)
    }
}

// MARK: - Typing Indicator
struct TypingIndicatorRow: View {
    let user: User
    var body: some View {
        HStack(spacing: 8) {
            ProfileImageView(user: user, size: 22, showVerificationBadge: false)
            TypingBubble()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TypingBubble: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 6, height: 6)
                    .opacity(0.6)
                    .scaleEffect(1 + 0.2 * sin(phase + CGFloat(i)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
        .onAppear {
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                phase = 2 * .pi
            }
        }
    }
}

// MARK: - Gift Picker View
struct GiftPickerView: View {
    let onGiftSelected: (String) -> Void

    let gifts = [
        ("🎁", "Gift"),
        ("🌹", "Rose"),
        ("💐", "Bouquet"),
        ("☕️", "Coffee"),
        ("🍷", "Wine"),
        ("🍕", "Pizza"),
        ("🍰", "Cake"),
        ("💝", "Heart Gift"),
        ("💎", "Diamond"),
        ("⭐️", "Star")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Send a gift")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gifts, id: \.0) { gift in
                        Button(action: {
                            onGiftSelected(gift.0)
                        }) {
                            VStack(spacing: 6) {
                                Text(gift.0)
                                    .font(.system(size: 40))

                                Text(gift.1)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 70, height: 80)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - GIF Picker View
struct GifPickerView: View {
    let onGifSelected: (GifItem) -> Void

    private let gifs: [GifItem] = [
        GifItem(title: "Happy Dance", urlString: "https://media.tenor.com/2nKSTDDekOgAAAAC/dance.gif"),
        GifItem(title: "Excited", urlString: "https://media.tenor.com/3bTxZ5kZmf4AAAAC/baby-excited.gif"),
        GifItem(title: "Cheering", urlString: "https://media.tenor.com/mc5CPVC1w30AAAAC/lets-go-happy.gif"),
        GifItem(title: "Cute Wave", urlString: "https://media.tenor.com/4Z1XNo0PIZsAAAAC/hi-hello.gif"),
        GifItem(title: "Hugs", urlString: "https://media.tenor.com/3F21Kq5O7-cAAAAC/hug.gif"),
        GifItem(title: "Coffee Cheers", urlString: "https://media.tenor.com/n0V1wYwgd0QAAAAC/coffee.gif")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share a GIF")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gifs) { gif in
                        Button(action: {
                            onGifSelected(gif)
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                GIFPlayerView(url: gif.url)
                                    .frame(width: 140, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                Text(gif.title)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 140)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

struct GifItem: Identifiable, Hashable {
    let id: String
    let title: String
    let url: URL

    init(title: String, urlString: String) {
        self.title = title
        self.id = urlString
        self.url = URL(string: urlString) ?? URL(string: "https://media.tenor.com/2nKSTDDekOgAAAAC/dance.gif")!
    }
}

struct GIFPlayerView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.backgroundColor = .clear
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.clipsToBounds = true
        webView.load(URLRequest(url: url))
        webView.contentMode = .scaleAspectFill
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard uiView.url != url else { return }
        uiView.load(URLRequest(url: url))
    }
}

// MARK: - Audio Recorder Service
class AudioRecorderService: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?

    func checkPermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if granted {
                    print("AudioRecorder: Microphone permission granted")
                } else {
                    print("AudioRecorder: Microphone permission denied")
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    print("AudioRecorder: Microphone permission granted")
                } else {
                    print("AudioRecorder: Microphone permission denied")
                }
            }
        }
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("voice_\(UUID().uuidString).m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
            recordingStartTime = Date()
            recordingDuration = 0

            // Start timer to update duration
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }

            print("AudioRecorder: Recording started")
        } catch {
            print("AudioRecorder: Failed to start recording - \(error)")
        }
    }

    func stopRecording(completion: @escaping (URL?, TimeInterval) -> Void) {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil

        let duration = recordingDuration
        let url = audioRecorder?.url

        isRecording = false
        recordingDuration = 0
        recordingStartTime = nil

        print("AudioRecorder: Recording stopped, duration: \(duration)s")

        completion(url, duration)
    }

    func cancelRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil

        // Delete the recording file
        if let url = audioRecorder?.url {
            try? FileManager.default.removeItem(at: url)
            print("AudioRecorder: Recording cancelled and deleted")
        }

        isRecording = false
        recordingDuration = 0
        recordingStartTime = nil
    }
}

// MARK: - Audio Player Service
class AudioPlayerService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var progress: Double = 0 // 0.0 to 1.0

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?

    func play(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
            print("AudioPlayer: Playing audio from \(url.path)")
        } catch {
            print("AudioPlayer: Failed to play audio - \(error)")
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
            self.progress = player.duration > 0 ? player.currentTime / player.duration : 0
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        progress = 0
        stopProgressTimer()
    }
}

#Preview {
    NavigationView {
        ChatView(conversation: Conversation(
            participants: ["current_user", "user_1"],
            messages: [
                Message(senderId: "user_1", text: "Hey! Want to grab coffee?", timestamp: Date().addingTimeInterval(-3600)),
                Message(senderId: "current_user", text: "Sure! When are you free?", timestamp: Date().addingTimeInterval(-3500)),
                Message(senderId: "user_1", text: "Voice message", timestamp: Date().addingTimeInterval(-300), type: .voiceMemo, voiceMemoUrl: "/tmp/voice.m4a", voiceMemoDuration: 5.0),
                Message(senderId: "user_1", text: "Happy Dance", timestamp: Date().addingTimeInterval(-200), type: .gif, gifUrl: "https://media.tenor.com/2nKSTDDekOgAAAAC/dance.gif"),
                Message(senderId: "current_user", text: "Sent a gift", timestamp: Date().addingTimeInterval(-60), type: .gift, giftEmoji: "☕️")
            ]
        ))
        .environmentObject(AppViewModel())
    }
}
