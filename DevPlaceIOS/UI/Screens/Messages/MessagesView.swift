import SwiftUI
import DevPlaceSwiftSDK

struct MessagesView: View {
    @Environment(\.api) var api

    var body: some View {
        MessagesViewContent(viewModel: .init(api: api))
    }
}

private struct MessagesViewContent: View {
    @State var viewModel: MessagesView.ViewModel

    private let appState = AppState.shared

    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Messages"))
            .navigationDestination(for: User.self) { otherUser in
                ConversationView(otherUser: otherUser)
                    .id(otherUser.id)
            }
            .alert($viewModel.alertMessage)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    reloadToolbarItem()
                }
            }
            .refreshable {
                await viewModel.reload()
            }
            .onChange(of: appState.isLoggedIn) {
                Task {
                    await viewModel.load()
                }
            }
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder private func content() -> some View {
        ScrollView {
            if viewModel.conversations.isEmpty {
                emptyState()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
            } else {
                LazyVStack(spacing: 0) {
                    BoxView(backgroundColor: .BG_1, paddingSize: .none) {
                        VStack(spacing: 0) {
                            ForEach(viewModel.conversations, id: \.otherUser.id) { conversation in
                                NavigationLink(value: conversation.otherUser) {
                                    ConversationRow(conversation: conversation)
                                }
                                .buttonStyle(.plain)

                                if conversation.otherUser.id != viewModel.conversations.last?.otherUser.id {
                                    Divider()
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
    }

    @ViewBuilder private func emptyState() -> some View {
        if !appState.isLoggedIn {
            ContentUnavailableView(
                "Sign in required",
                systemImage: "bubble.left.and.bubble.right",
                description: Text("Sign in from the Settings tab to see your messages."),
            )
        } else if viewModel.inbox == nil {
            ProgressView()
        } else {
            ContentUnavailableView(
                "No conversations",
                systemImage: "bubble.left.and.bubble.right",
                description: Text("Your direct messages will appear here."),
            )
        }
    }

    @ViewBuilder private func reloadToolbarItem() -> some View {
        if viewModel.isReloading {
            ProgressView()
        } else {
            Button {
                Task { await viewModel.reload() }
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

private struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            UserImage(user: conversation.otherUser)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(conversation.otherUser.username)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.FG_1)

                    Spacer(minLength: 8)

                    Group {
                        if let date = conversation.lastMessageDate {
                            Text(date, format: .relative(presentation: .named, unitsStyle: .wide))
                        } else {
                            Text(conversation.lastMessageAt)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color.FG_2)
                }

                Text(conversation.lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(Color.FG_2)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if conversation.unread {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(12)
        .background(conversation.unread ? Color.accentColor.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
    }
}

private extension Conversation {
    static let isoParsers: [ISO8601DateFormatter] = {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]
        return [fractional, standard]
    }()

    var lastMessageDate: Date? {
        for parser in Self.isoParsers {
            if let date = parser.date(from: lastMessageAt) {
                return date
            }
        }
        return nil
    }
}

#Preview {
    NavigationStack {
        MessagesView()
    }
    .environment(\.api, .mock)
}
