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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Markdown(profile.user.bio)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    infoRow(title: "Location", text: profile.user.location)
                    
                    Divider()
                    
                    infoRow(title: "Git Link", link: profile.user.gitLink)
                    
                    Divider()
                    
                    infoRow(title: "Website", link: profile.user.website)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    @ViewBuilder private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.FG_2)
    }
    
    @ViewBuilder private func infoRow(title: String, text: String) -> some View {
        HStack {
            sectionTitle(title)
            
            Spacer()
            
            Text(text)
                .multilineTextAlignment(.trailing)
        }
    }
    
    @ViewBuilder private func infoRow(title: String, link: String) -> some View {
        HStack {
            sectionTitle(title)
            
            Spacer()
            
            if let url = URL(string: link) {
                Link(destination: url) {
                    Text(link)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(\.api, .mock)
}
