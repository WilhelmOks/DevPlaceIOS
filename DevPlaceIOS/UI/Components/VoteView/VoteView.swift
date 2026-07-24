import SwiftUI
import DevPlaceSwiftSDK

struct VoteView: View {
    let targetType: TargetType
    let targetId: String
    let count: Int
    let currentVote: Vote
    
    @Environment(\.api) var api
    
    var body: some View {
        VoteViewContent(
            count: count,
            currentVote: currentVote,
            viewModel: .init(
                targetType: targetType,
                targetId: targetId,
                count: count,
                vote: currentVote,
                api: api,
            )
        )
    }
}

private struct VoteViewContent: View {
    let count: Int
    let currentVote: Vote
    @State var viewModel: VoteView.ViewModel
    
    @ScaledMetric private var scale = 1.0
    
    let buttonSize = 15.0
    
    var body: some View {
        content()
            .alert($viewModel.alertMessage)
            .onChange(of: count) { _, newValue in
                viewModel.count = newValue
            }
            .onChange(of: currentVote) { _, newValue in
                viewModel.currentVote = newValue
            }
    }
    
    @ViewBuilder private func content() -> some View {
        HStack(spacing: 10) {
            Button {
                Task { await viewModel.voteDown() }
            } label: {
                Image(systemName: viewModel.currentVote == .down ? "minus.circle.fill" : "minus.circle")
                    .font(.system(size: buttonSize * scale))
            }
            .buttonStyle(.plain)
            .foregroundStyle(viewModel.currentVote == .down ? Color.accentColor : Color.FG_2)
            .disabled(!viewModel.userCanVote)
            
            Text("\(viewModel.count)")
                .font(.system(size: 14 * scale))
                .fontWeight(.semibold)
                .monospacedDigit()
            
            Button {
                Task { await viewModel.voteUp() }
            } label: {
                Image(systemName: viewModel.currentVote == .up ? "plus.circle.fill" : "plus.circle")
                    .font(.system(size: buttonSize * scale))
            }
            .buttonStyle(.plain)
            .foregroundStyle(viewModel.currentVote == .up ? Color.accentColor : Color.FG_2)
            .disabled(!viewModel.userCanVote)
        }
    }
}

#Preview {
    VoteView(targetType: .post, targetId: "1", count: 5, currentVote: .none)
        .environment(\.api, .mock)
}
