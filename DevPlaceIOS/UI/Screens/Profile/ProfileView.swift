import SwiftUI

struct ProfileView: View {
    var body: some View {
        content()
            .screenStyle()
            .navigationTitle(Text("Profile"))
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
        ProfileView()
    }
}
