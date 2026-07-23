import SwiftUI
import DevPlaceSwiftSDK

struct PollView: View {
    let poll: Poll
    
    @Environment(\.api) var api
    
    var body: some View {
        PollViewContent(
            viewModel: .init(poll: poll, api: api),
        )
    }
}

private struct PollViewContent: View {
    @State var viewModel: PollView.ViewModel
    
    var body: some View {
        content()
            .alert($viewModel.alertMessage)
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.question)
                .font(.headline)
                .foregroundStyle(Color.FG_1)
            
            VStack(spacing: 6) {
                ForEach(viewModel.options, id: \.id) { option in
                    optionRow(option: option)
                }
            }
            
            Text("\(viewModel.total) \(viewModel.total == 1 ? "vote" : "votes")")
                .font(.footnote)
                .foregroundStyle(Color.FG_2)
        }
    }
    
    @ViewBuilder private func optionRow(option: PollOption) -> some View {
        let isSelected = viewModel.myChoice == option.id
        Button {
            Task { await viewModel.tap(optionId: option.id) }
        } label: {
            HStack(spacing: 8) {
                Text(option.label)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(Color.FG_1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
                
                Text("\(option.pct)%")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(Color.FG_2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(alignment: .leading) {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.opacity(isSelected ? 0.3 : 0.2))
                        .padding(1)
                        .frame(width: geo.size.width * CGFloat(option.pct) / 100)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isSelected ? Color.accentColor : Color.FG_2.opacity(0.25),
                        lineWidth: isSelected ? 1.5 : 1,
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.userCanVote)
    }
}

#Preview("Not voted") {
    PollView(poll: .mockLayoutContainer)
        .padding()
        .background(Color.BG_1)
        .environment(\.api, .mock)
}

#Preview("Already voted") {
    PollView(poll: .mockTestingFrameworkAlreadyVoted)
        .padding()
        .background(Color.BG_1)
        .environment(\.api, .mock)
        .task {
            AppState.shared.token = .init(tokenType: "", accessToken: "", expireTime: Date())
        }
}
