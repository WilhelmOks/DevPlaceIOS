import SwiftUI
import DevPlaceSwiftSDK

struct NotificationsView: View {
    @Environment(\.api) var api

    let reselectSignal: Bool
    let onOpenPost: (PostDestination) -> Void
    let onOpenConversation: (User) -> Void
    let onOpenOwnProfile: () -> Void

    var body: some View {
        NotificationsViewContent(
            viewModel: .init(api: api),
            reselectSignal: reselectSignal,
            onOpenPost: onOpenPost,
            onOpenConversation: onOpenConversation,
            onOpenOwnProfile: onOpenOwnProfile,
        )
    }
}

private struct NotificationsViewContent: View {
    @State var viewModel: NotificationsView.ViewModel

    let reselectSignal: Bool
    let onOpenPost: (PostDestination) -> Void
    let onOpenConversation: (User) -> Void
    let onOpenOwnProfile: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    private let appState = AppState.shared

    @State private var isAtTop = true

    var body: some View {
        content()
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text("Notifications"))
            .alert($viewModel.alertMessage)
            .toolbar {
                if appState.isLoggedIn {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Mark all read") {
                            Task {
                                await viewModel.markAllRead()
                            }
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onChange(of: reselectSignal) {
                if isAtTop {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .onChange(of: scenePhase) { _, newValue in
                guard newValue == .active else { return }
                Task {
                    await viewModel.refresh()
                }
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
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y <= geometry.contentInsets.top
        } action: { _, newValue in
            isAtTop = newValue
        }
    }

    @ViewBuilder private func emptyState() -> some View {
        if !appState.isLoggedIn {
            ContentUnavailableView(
                "Sign in required",
                systemImage: "bell.slash",
                description: Text("Sign in from the Settings tab to see your notifications."),
            )
        } else if viewModel.notifications == nil {
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
                                Task {
                                    switch await viewModel.open(notification: notification) {
                                    case .post(let destination):
                                        onOpenPost(destination)
                                    case .conversation(let otherUser):
                                        onOpenConversation(otherUser)
                                    case .web(let url):
                                        openURL(url)
                                    case .ownProfile:
                                        onOpenOwnProfile()
                                    case nil:
                                        break
                                    }
                                }
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
        NotificationsView(reselectSignal: false, onOpenPost: { _ in }, onOpenConversation: { _ in }, onOpenOwnProfile: {})
    }
    .environment(\.api, .mock)
}
