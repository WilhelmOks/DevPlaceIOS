import SwiftUI

struct SettingsView: View {
    @Environment(\.api) var api
    
    var body: some View {
        SettingsViewContent(viewModel: .init(api: api))
    }
}

private struct SettingsViewContent: View {
    @State var viewModel: LogInView.ViewModel
    
    enum FullscreenNavigationItem: Identifiable {
        case signIn
        
        var id: Self { self }
    }
    
    @State var fullscreenNavigationItem: FullscreenNavigationItem?
    
    var body: some View {
        NavigationStack {
            content()
                .background {
                    Color.BG_2.ignoresSafeArea()
                }
                //.foregroundStyle(.FG_1)
                .navigationTitle(Text("Settings"))
                .toolbar {
                    if true {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign in") {
                                fullscreenNavigationItem = .signIn
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
    }
    
    @ViewBuilder private func content() -> some View {
        Form {
            Section {
                if true {
                    Button("Sign out") {
                        
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SettingsView()
}
