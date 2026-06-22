import SwiftUI

struct MainView: View {
    var body: some View {
        content()
    }
    
    @ViewBuilder private func content() -> some View {
        TabView {
            Tab {
                FeedView()
            } label: {
                Label {
                    Text("Feed")
                } icon: {
                    Image(systemName: "list.bullet.rectangle")
                }
            }
            
            Tab {
                Text("Notifications Content")
            } label: {
                Label {
                    Text("Notifications")
                } icon: {
                    Image(systemName: "bell")
                }
            }

            Tab {
                SettingsView()
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
