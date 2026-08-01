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

    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Messages"))
            .alert($viewModel.alertMessage)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    reloadToolbarItem()
                }
            }
            .refreshable {
                await viewModel.reload()
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
                                NavigationLink {
                                    ConversationView(otherUser: conversation.otherUser)
                                } label: {
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
        if viewModel.inbox == nil {
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

                    Text(conversation.lastMessageAt)
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

#Preview {
    NavigationStack {
        MessagesView()
    }
    .environment(\.api, .mock)
}
