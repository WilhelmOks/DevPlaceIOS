import SwiftUI
import DevPlaceSwiftSDK

struct MainView: View {
    @Environment(\.api) private var api
    @Environment(\.scenePhase) private var scenePhase

    private let appState = AppState.shared

    @State private var selectedTab: TabSelection = .postsFeed
    @State private var feedPost: PostDestination?
    @State private var messagesPath: [User] = []
    @State private var settingsPath: [SettingsDestination] = []

    @State private var feedReselectSignal = false
    @State private var notificationsReselectSignal = false

    private enum TabSelection {
        case postsFeed
        case messages
        case notifications
        case settings
    }

    private var tabSelection: Binding<TabSelection> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == selectedTab {
                    switch newValue {
                    case .postsFeed:
                        if feedPost == nil {
                            feedReselectSignal.toggle()
                        }
                    case .messages:
                        break
                    case .notifications:
                        notificationsReselectSignal.toggle()
                    case .settings:
                        break
                    }
                }
                selectedTab = newValue
            },
        )
    }

    var body: some View {
        content()
    }

    private func openPendingConversationIfNeeded() async {
        guard appState.isLoggedIn, let uid = appState.pendingConversationUid else {
            return
        }
        appState.pendingConversationUid = nil
        guard let otherUser = await appState.conversationUser(withUid: uid, api: api) else {
            return
        }
        messagesPath = [otherUser]
        selectedTab = .messages
    }

    @ViewBuilder private func content() -> some View {
        TabView(selection: tabSelection) {
            Tab(value: .postsFeed) {
                NavigationStack {
                    FeedView(selectedPost: $feedPost, reselectSignal: feedReselectSignal)
                }
            } label: {
                Label {
                    Text("Posts")
                } icon: {
                    Image(systemName: "list.bullet.rectangle")
                }
            }

            Tab(value: .messages) {
                NavigationStack(path: $messagesPath) {
                    MessagesView()
                }
            } label: {
                Label {
                    Text("Messages")
                } icon: {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
            }
            .badge(appState.unreadMessageCount)

            Tab(value: .notifications) {
                NavigationStack {
                    NotificationsView(
                        reselectSignal: notificationsReselectSignal,
                        onOpenPost: { destination in
                            feedPost = destination
                            selectedTab = .postsFeed
                        },
                        onOpenConversation: { otherUser in
                            messagesPath = [otherUser]
                            selectedTab = .messages
                        },
                        onOpenOwnProfile: {
                            settingsPath = [.profile]
                            selectedTab = .settings
                        },
                    )
                }
            } label: {
                Label {
                    Text("Notifications")
                } icon: {
                    Image(systemName: "bell")
                }
            }
            .badge(appState.unreadNotificationCount)

            Tab(value: .settings) {
                NavigationStack(path: $settingsPath) {
                    SettingsView()
                }
            } label: {
                Label {
                    Text("Settings")
                } icon: {
                    Image(systemName: "gear")
                }
            }
        }
        .task {
            if appState.isLoggedIn {
                await PushNotificationManager.shared.registerForPushNotifications(api: api)
                await openPendingConversationIfNeeded()
            }
        }
        .onChange(of: appState.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                Task {
                    await PushNotificationManager.shared.registerForPushNotifications(api: api)
                    await openPendingConversationIfNeeded()
                }
            } else {
                messagesPath = []
                settingsPath = []
            }
        }
        .onChange(of: appState.pendingConversationUid) { _, uid in
            guard uid != nil else { return }
            Task {
                await openPendingConversationIfNeeded()
            }
        }
        .onChange(of: selectedTab) {
            Task {
                await appState.loadUnreadCounts(api: api)
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            Task {
                await appState.loadUnreadCounts(api: api)
            }
        }
    }
}

#Preview {
    MainView()
}
