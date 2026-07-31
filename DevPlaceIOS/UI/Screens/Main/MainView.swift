import SwiftUI

struct MainView: View {
    @Environment(\.api) private var api

    private let appState = AppState.shared

    @State private var selectedTab: TabSelection = .feed

    private enum TabSelection {
        case feed
        case notifications
        case settings
    }

    var body: some View {
        content()
    }

    @ViewBuilder private func content() -> some View {
        TabView(selection: $selectedTab) {
            Tab(value: .feed) {
                NavigationStack {
                    FeedView()
                }
            } label: {
                Label {
                    Text("Feed")
                } icon: {
                    Image(systemName: "list.bullet.rectangle")
                }
            }

            Tab(value: .notifications) {
                NavigationStack {
                    NotificationsView()
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
            guard newValue == .feed || newValue == .notifications else { return }
            Task {
                await appState.loadUnreadNotificationCount(api: api)
            }
        }
    }
}

#Preview {
    MainView()
}
