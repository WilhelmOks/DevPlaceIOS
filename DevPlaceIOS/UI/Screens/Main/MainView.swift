import SwiftUI

struct MainView: View {
    @Environment(\.api) private var api
    @Environment(\.scenePhase) private var scenePhase

    private let appState = AppState.shared

    @State private var selectedTab: TabSelection = .postsFeed
    @State private var feedPost: PostDestination?

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
                NavigationStack {
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
                NavigationStack {
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
