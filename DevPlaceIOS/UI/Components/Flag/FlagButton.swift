import SwiftUI
import DevPlaceSwiftSDK

struct FlagButton: View {
    let targetType: TargetType
    let targetId: String
    let authorId: String
    
    @Environment(\.api) var api
    let appSettings = AppSettingsStore.shared
    
    private var isVisible: Bool {
        appSettings.showFlagButtons
            && AppState.shared.isLoggedIn
            && !AppState.shared.isCurrentUser(id: authorId)
    }
    
    var body: some View {
        if isVisible {
            FlagButtonContent(
                viewModel: .init(
                    targetType: targetType,
                    targetId: targetId,
                    api: api,
                )
            )
        }
    }
}

private struct FlagButtonContent: View {
    @State var viewModel: FlagButton.ViewModel
    
    @State private var isConfirming = false
    
    var body: some View {
        Button {
            isConfirming = true
        } label: {
            Label("Flag \(viewModel.targetNoun)", systemImage: "flag")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
        .confirmationDialog(
            viewModel.confirmationTitle,
            isPresented: $isConfirming,
            titleVisibility: .visible,
        ) {
            Button("Flag") {
                Task { await viewModel.flag() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert($viewModel.alertMessage)
    }
}

#Preview {
    FlagButton(targetType: .post, targetId: "1", authorId: "other-user")
        .environment(\.api, .mock)
}
