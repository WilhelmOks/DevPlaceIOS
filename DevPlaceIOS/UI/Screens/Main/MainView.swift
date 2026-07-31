import SwiftUI

struct MainView: View {
    @Environment(\.api) private var api

    private let appState = AppState.shared

    @State private var selectedTab: TabSelection = .postsFeed
    @State private var feedPost: PostDestination?

    private enum TabSelection {
        case postsFeed
        case notifications
        case settings
    }

    var body: some View {
        content()
    }

    @ViewBuilder private func content() -> some View {
        TabView(selection: $selectedTab) {
            Tab(value: .postsFeed) {
                NavigationStack {
                    FeedView(selectedPost: $feedPost)
                }
            } label: {
                Label {
                    Text("Posts")
                } icon: {
                    Image(systemName: "list.bullet.rectangle")
                }
            }

            Tab(value: .notifications) {
                NavigationStack {
                    NotificationsView(
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
        .onChange(of: selectedTab) { _, newValue in
            guard newValue == .postsFeed || newValue == .notifications else { return }
            Task {
                await appState.loadUnreadNotificationCount(api: api)
            }
        }
    }
}

#Preview {
    MainView()
}
