import SwiftUI
import DevPlaceSwiftSDK

struct PollView: View {
    let poll: Poll
    
    @Environment(\.api) var api
    
    var body: some View {
        PollViewContent(
            poll: poll,
            viewModel: .init(poll: poll, api: api),
        )
    }
}

private struct PollViewContent: View {
    let poll: Poll
    @State var viewModel: PollView.ViewModel
    
    private let outerCornerRadius: CGFloat = 12
    private let outerPadding: CGFloat = 12
    private let optionCornerRadius: CGFloat = 10
    private let optionHorizontalPadding: CGFloat = 12
    private let optionVerticalPadding: CGFloat = 10
    private let subtleBorderOpacity: Double = 0.25
    private let unselectedFillOpacity: Double = 0.2
    private let selectedFillOpacity: Double = 0.3
    
    var body: some View {
        content()
            .alert($viewModel.alertMessage)
            .onChange(of: poll) { _, newValue in
                viewModel.options = newValue.options
                viewModel.total = newValue.total
                viewModel.myChoice = newValue.myChoice
            }
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
                .padding(.horizontal, 4)
        }
        .padding(outerPadding)
        .overlay {
            RoundedRectangle(cornerRadius: outerCornerRadius)
                .strokeBorder(Color.FG_2.opacity(subtleBorderOpacity), lineWidth: 1)
        }
        .background {
            RoundedRectangle(cornerRadius: outerCornerRadius)
                .foregroundStyle(.BG_2)
        }
    }
    
    @ViewBuilder private func optionRow(option: PollOption) -> some View {
        let isSelected = viewModel.myChoice == option.id
        Button {
            Task { await viewModel.select(optionId: option.id) }
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
            .padding(.horizontal, optionHorizontalPadding)
            .padding(.vertical, optionVerticalPadding)
            .background(alignment: .leading) {
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.accentColor.opacity(isSelected ? selectedFillOpacity : unselectedFillOpacity))
                        .frame(width: geo.size.width * CGFloat(option.pct) / 100)
                }
            }
            .background(Color.BG_1)
            .clipShape(RoundedRectangle(cornerRadius: optionCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: optionCornerRadius)
                    .strokeBorder(
                        isSelected ? Color.accentColor : Color.FG_2.opacity(subtleBorderOpacity),
                        lineWidth: isSelected ? 1.5 : 1,
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: optionCornerRadius))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(viewModel.userCanVote)
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
