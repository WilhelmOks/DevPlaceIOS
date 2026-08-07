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
    @State private var deleteAccountConfirmationPresented = false
    @State private var deleteAccountFinalConfirmationPresented = false
    
    enum FullscreenNavigationItem: Identifiable {
        case signIn
        
        var id: Self { self }
    }
    
    @State var fullscreenNavigationItem: FullscreenNavigationItem?
    
    var body: some View {
        content()
            .screenStyle()
            .navigationTitle(Text("Settings"))
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .profile:
                    ProfileView()
                }
            }
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
                    NavigationLink(value: SettingsDestination.profile) {
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
            
            Section(header: Text("Posts Feed")) {
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
            
            Section(header: Text("Violating Content")) {
                Toggle(isOn: $appSettings.showFlagButtons) {
                    Label {
                        Text("Show flag buttons")
                    } icon: {
                        Image(systemName: "flag")
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
                            Task {
                                await viewModel.logOut()
                            }
                        }
                    }
                    
                    Button {
                        deleteAccountConfirmationPresented = true
                    } label: {
                        Label {
                            Text("Delete account")
                        } icon: {
                            Image(systemName: "trash")
                        }
                    }
                    .buttonStyle(.form)
                    .alert(
                        "Do you want to permanently delete your account?",
                        isPresented: $deleteAccountConfirmationPresented
                    ) {
                        Button(role: .cancel, action: {})
                        Button("Delete account", role: .destructive) {
                            deleteAccountFinalConfirmationPresented = true
                        }
                    }
                    .alert(
                        "Your account will be deleted. This cannot be undone! Do you want to proceed?",
                        isPresented: $deleteAccountFinalConfirmationPresented
                    ) {
                        Button(role: .cancel, action: {})
                        Button("Delete account", role: .destructive) {
                            Task {
                                await viewModel.deleteAccount()
                            }
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
