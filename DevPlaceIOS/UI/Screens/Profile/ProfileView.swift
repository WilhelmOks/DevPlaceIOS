import SwiftUI
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
            VStack {
                let text = "\(String(describing: viewModel.profile))"
                Text(text)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
