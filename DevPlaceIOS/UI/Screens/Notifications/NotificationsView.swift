import SwiftUI
import DevPlaceSwiftSDK

struct NotificationsView: View {
    @Environment(\.api) var api
    
    var body: some View {
        NotificationsViewContent(viewModel: .init(api: api))
    }
}

private struct NotificationsViewContent: View {
    @State var viewModel: NotificationsView.ViewModel
    
    var body: some View {
        content()
            .background {
                Color.BG_2.ignoresSafeArea()
            }
            .foregroundStyle(.FG_1)
            .navigationTitle(Text("Notifications"))
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack {
                Text("...")
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
