import SwiftUI

struct ProfileView: View {
    var body: some View {
        content()
            .background {
                Color.BG_2.ignoresSafeArea()
            }
            .foregroundStyle(.FG_1)
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
