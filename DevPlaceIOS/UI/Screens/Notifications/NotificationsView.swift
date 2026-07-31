import SwiftUI
import DevPlaceSwiftSDK

struct NotificationsView: View {
    @Environment(\.api) var api

    var body: some View {
        NotificationsViewContent(viewModel: .init(api: api))
    }
}

private struct NotificationsViewContent: View {
    @State var viewModel: NotificationsView.ViewModel

    @State private var selectedPost: NotificationsView.NavigationTarget?

    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Notifications"))
            .alert($viewModel.alertMessage)
            .navigationDestination(item: $selectedPost) { target in
                PostView(slug: target.slug, scrollToCommentId: target.scrollToCommentId)
            }
            .onChange(of: selectedPost) { _, newValue in
                if newValue == nil {
                    Task {
                        await viewModel.refreshUnreadCount()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Mark all read") {
                        Task {
                            await viewModel.markAllRead()
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder private func content() -> some View {
        ScrollView {
            if viewModel.groups.isEmpty {
                emptyState()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
            } else {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.groups, id: \.label) { group in
                        groupSection(group)
                    }
                    if viewModel.notifications?.nextCursor != nil {
                        ProgressView()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                Task {
                                    await viewModel.loadMore()
                                }
                            }
                    }
                }
                .padding()
            }
        }
    }

    @ViewBuilder private func emptyState() -> some View {
        if viewModel.notifications == nil {
            ProgressView()
        } else {
            ContentUnavailableView(
                "No notifications",
                systemImage: "bell.slash",
                description: Text("You're all caught up."),
            )
        }
    }

    @ViewBuilder private func groupSection(_ group: NotificationGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.label)
                .font(.headline)
                .foregroundStyle(Color.FG_2)

            BoxView(backgroundColor: .BG_1, paddingSize: .none) {
                VStack(spacing: 0) {
                    ForEach(group.entries) { notification in
                        NotificationRow(
                            notification: notification,
                            onSelect: {
                                selectedPost = viewModel.navigationTarget(for: notification)
                                /* navigating already marks as read, so this needs to be called only when there is no navigation.
                                Task {
                                    await viewModel.markRead(uid: notification.data.id)
                                }*/
                            },
                        )
                        if notification.id != group.entries.last?.id {
                            Divider()
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

private struct NotificationRow: View {
    let notification: DevPlaceSwiftSDK.Notification
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 10) {
                if let user = notification.actor {
                    UserImage(user: user)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.data.message)
                        .font(.subheadline)
                        .foregroundStyle(Color.FG_1)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    RelativeTimeLabel(date: notification.data.createdAt)
                }

                if !notification.data.read {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                }
            }
            .padding(12)
            .background(notification.data.read ? Color.clear : Color.accentColor.opacity(0.08))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
    .environment(\.api, .mock)
}
