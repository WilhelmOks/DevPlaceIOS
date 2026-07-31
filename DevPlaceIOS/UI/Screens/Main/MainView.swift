import SwiftUI

struct MainView: View {
    private let appState = AppState.shared

    var body: some View {
        content()
    }
    
    @ViewBuilder private func content() -> some View {
        TabView {
            Tab {
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
            
            Tab {
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

            Tab {
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
    }
}

#Preview {
    MainView()
}
