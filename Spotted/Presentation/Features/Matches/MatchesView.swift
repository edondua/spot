import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var searchText = ""

    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return viewModel.conversations
        } else {
            return viewModel.conversations.filter { conversation in
                guard let otherUserId = conversation.participants.first(where: { $0 != viewModel.currentUser.id }),
                      let otherUser = viewModel.getUser(by: otherUserId) else {
                    return false
                }
                return otherUser.name.localizedCaseInsensitiveContains(searchText) ||
                       conversation.messages.contains { $0.text.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Matches section at top
                    if !viewModel.matches.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("New Matches")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.horizontal)
                                .padding(.top, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Array(viewModel.matches.enumerated()), id: \.element.id) { index, match in
                                        if let otherUserId = match.users.first(where: { $0 != viewModel.currentUser.id }),
                                           let otherUser = viewModel.getUser(by: otherUserId) {
                                            MatchCircle(match: match, otherUser: otherUser)
                                                .slideIn(delay: Double(index) * 0.1)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                    }

                    Divider()

                    // Messages section below
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Messages")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 16)

                        if viewModel.conversations.isEmpty {
                            emptyMessagesView
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(filteredConversations.enumerated()), id: \.element.id) { index, conversation in
                                    if let otherUserId = conversation.participants.first(where: { $0 != viewModel.currentUser.id }),
                                       let otherUser = viewModel.getUser(by: otherUserId) {
                                        NavigationLink(destination: ChatContainerView(conversation: conversation)) {
                                            ConversationRow(conversation: conversation, otherUser: otherUser)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .slideIn(delay: Double(index) * 0.05)

                                        Divider()
                                            .padding(.leading, 90)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Matches")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search messages")
        }
    }

    private var emptyMatchesView: some View {
        VStack(spacing: 18) {
            Image(systemName: "flame.fill")
                .font(.system(size: 70))
                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

            Text("Start Matching")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Like people to match with them and start chatting")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private var emptyMessagesView: some View {
        VStack(spacing: 18) {
            Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

            Text("No Messages Yet")
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Tap your matches above to start chatting")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Match Circle (Instagram-style)
struct MatchCircle: View {
    @EnvironmentObject var viewModel: AppViewModel
    let match: Match
    let otherUser: User

    var body: some View {
        NavigationLink(destination: matchDestination) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    // Profile photo with gradient border
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 252/255, green: 108/255, blue: 133/255),
                                    Color(red: 255/255, green: 149/255, blue: 0/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 84, height: 84)

                    ProfileImageView(user: otherUser, size: 78)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 3)
                        )

                    // Match indicator
                    Circle()
                        .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 3)
                        )
                }

                // Name
                Text(otherUser.name.components(separatedBy: " ").first ?? otherUser.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 80)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var matchDestination: some View {
        // Find or create conversation
        if let conversation = viewModel.conversations.first(where: { conv in
            conv.participants.contains(otherUser.id)
        }) {
            return AnyView(ChatView(conversation: conversation))
        } else {
            // Create new conversation
            let newConversation = Conversation(
                participants: [viewModel.currentUser.id, otherUser.id]
            )
            return AnyView(ChatView(conversation: newConversation))
        }
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation
    let otherUser: User
    @EnvironmentObject var viewModel: AppViewModel

    var isUnread: Bool {
        // Check if last message is not from current user (simulating unread)
        if let lastMessage = conversation.lastMessage {
            return lastMessage.senderId != viewModel.currentUser.id
        }
        return false
    }

    var body: some View {
        HStack(spacing: 14) {
            // User photo with unread indicator
            ZStack(alignment: .topTrailing) {
                ProfileImageView(user: otherUser, size: 68)

                if isUnread {
                    Circle()
                        .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: 4, y: -4)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(otherUser.name)
                        .font(.system(size: 17, weight: isUnread ? .bold : .semibold))
                        .foregroundColor(.primary)

                    if otherUser.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }

                    Spacer()

                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.timeDisplay)
                            .font(.system(size: 13))
                            .foregroundColor(isUnread ? Color(red: 252/255, green: 108/255, blue: 133/255) : .secondary)
                            .fontWeight(isUnread ? .semibold : .regular)
                    }
                }

                if let lastMessage = conversation.lastMessage {
                    HStack(spacing: 6) {
                        // Show who sent the last message
                        if lastMessage.senderId == viewModel.currentUser.id {
                            Text("You:")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }

                        Text(lastMessage.text)
                            .font(.system(size: 15))
                            .foregroundColor(isUnread ? .primary : .secondary)
                            .fontWeight(isUnread ? .medium : .regular)
                            .lineLimit(2)
                    }
                } else {
                    Text("Say hi to your new match!")
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .fontWeight(.medium)
                }
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
    }
}

#Preview {
    MatchesView()
        .environmentObject(AppViewModel())
}
