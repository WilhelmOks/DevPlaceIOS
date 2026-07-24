import SwiftUI

struct SettingsView: View {
    @Environment(\.api) var api
    
    var body: some View {
        SettingsViewContent(viewModel: .init(api: api))
    }
}

private struct SettingsViewContent: View {
    @State var viewModel: SettingsView.ViewModel
    let appState = AppState.shared
    @Bindable var appSettings = AppSettingsStore.shared

    @State private var logOutConfirmationPresented = false
    
    enum FullscreenNavigationItem: Identifiable {
        case signIn
        
        var id: Self { self }
    }
    
    @State var fullscreenNavigationItem: FullscreenNavigationItem?
    
    var body: some View {
        content()
            .screenStyle()
            .navigationTitle(Text("Settings"))
            .toolbar {
                if !appState.isLoggedIn {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            fullscreenNavigationItem = .signIn
                        } label: {
                            Text("Sign in")
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
            .fullScreenCover(item: $fullscreenNavigationItem) { item in
                switch item {
                case .signIn:
                    LogInView()
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        Form {
            Section {
                if appState.isLoggedIn {
                    NavigationLink(destination: ProfileView()) {
                        Label {
                            Text("Profile")
                        } icon: {
                            Image(systemName: "person")
                        }
                    }
                    .buttonStyle(.form)
                }
            }
            .listRowBackground(Color.BG_1)
            
            Section {
                Picker(selection: $appSettings.appearance) {
                    ForEach(AppSettingsStore.AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                } label: {
                    Label {
                        Text("Appearance")
                    } icon: {
                        Image(systemName: "circle.lefthalf.filled")
                    }
                }
                .tint(Color.accentColor)
            }
            .listRowBackground(Color.BG_1)
            
            Section(header: Text("Feed")) {
                Toggle(isOn: $appSettings.showFeedAttachments) {
                    Label {
                        Text("Show one attachment per post")
                    } icon: {
                        Image(systemName: "photo")
                    }
                }
                .tint(Color.accentColor)
                
                Toggle(isOn: $appSettings.showFeedComments) {
                    Label {
                        Text("Show recent comments")
                    } icon: {
                        Image(systemName: "text.bubble")
                    }
                }
                .tint(Color.accentColor)
            }
            .listRowBackground(Color.BG_1)
            
            Section {
                if appState.isLoggedIn {
                    Button {
                        logOutConfirmationPresented = true
                    } label: {
                        Label {
                            Text("Sign out")
                        } icon: {
                            Image(systemName: "iphone.and.arrow.right.outward")
                        }
                    }
                    .buttonStyle(.form)
                    .alert(
                        "Do you want to sign out?",
                        isPresented: $logOutConfirmationPresented
                    ) {
                        Button(role: .cancel, action: {})
                        Button("Sign out", role: .destructive) {
                            viewModel.logOut()
                        }
                    }
                }
            }
            .listRowBackground(Color.BG_1)
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
