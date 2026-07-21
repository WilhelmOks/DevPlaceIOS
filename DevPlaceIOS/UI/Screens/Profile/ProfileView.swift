import SwiftUI
import MarkdownUI
import DevPlaceSwiftSDK

struct ProfileView: View {
    var username: String?
    
    @Environment(\.api) var api
    
    var body: some View {
        ProfileViewContent(viewModel: .init(username: username, api: api))
    }
}

private struct ProfileViewContent: View {
    @State var viewModel: ProfileView.ViewModel
    
    @ScaledMetric private var scale = 1.0
    
    var body: some View {
        content()
            .screenStyle()
            .navigationTitle(Text(viewModel.navigationTitle))
            .alert($viewModel.alertMessage)
            .task {
                await viewModel.load()
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack(spacing: 10) {
                if let profile = viewModel.profile {
                    UserImage(user: profile.user, size: .large)
                    
                    sectionTitle("Bio")
                    
                    Markdown(profile.user.bio)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    let text = "\(String(describing: viewModel.profile))"
                    Text(text)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    @ViewBuilder private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 19, weight: .semibold))
            .multilineTextAlignment(.leading)
            .foregroundStyle(.FG_2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(\.api, .mock)
}
