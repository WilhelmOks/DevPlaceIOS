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
                        .padding(.bottom, 10)
                    
                    numericInfoArea(profile)
                    
                    levelProgressArea(profile)
                        .padding(.vertical, 10)
                    
                    infoRowsArea(profile)
                    
                    //TODO: place those badges somewhere else.
                    //Divider()
                    VFlowStack(spacing: 8) {
                        ForEach(profile.badges, id: \.self) { badge in
                            UserBadgeView(badge: badge)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    @ViewBuilder private func numericInfoArea(_ profile: Profile) -> some View {
        HStack(spacing: 20) {
            numericInfo(label: "Posts", numericText: profile.postsCount.formatted())
            
            numericInfo(label: "Level", numericText: profile.user.level.formatted())
            
            numericInfo(label: "Stars", numericText: profile.user.stars.formatted())
            
            if let rank = profile.rank {
                numericInfo(label: "Rank", numericText: "#\(rank.formatted())")
            }
        }
    }
    
    @ViewBuilder private func levelProgressArea(_ profile: Profile) -> some View {
        VStack(spacing: 4) {
            let progressValue = 0.32 //TODO: get the real number from the API (currently not exposed via the API)
            
            HStack {
                Text("Progress to next level")
                
                Spacer()
                
                Text("\(progressValue.formatted(.percent))")
            }
            .font(.system(size: 12 * scale))
            .foregroundStyle(.FG_2)
            
            ProgressView(value: progressValue)
        }
    }
    
    @ViewBuilder private func infoRowsArea(_ profile: Profile) -> some View {
        VStack(spacing: 10) {
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
    
    @ViewBuilder private func numericInfo(label: String, numericText: String) -> some View {
        VStack(spacing: 2) {
            Text(numericText)
                .font(.system(size: 18 * scale))
                .fontWeight(.bold)
            
            Text(label.uppercased())
                .font(.system(size: 14 * scale))
                .foregroundStyle(.FG_2)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(\.api, .mock)
}
