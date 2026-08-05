import SwiftUI
import DevPlaceSwiftSDK

struct MentionListHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct MentionSuggestionsView: View {
    let text: String
    var participants: [UserSearch.Result] = []
    let onSelect: (UserSearch.Result) -> Void

    @Environment(\.api) private var api

    var body: some View {
        MentionSuggestionsViewContent(
            viewModel: .init(api: api),
            text: text,
            participants: participants,
            onSelect: onSelect,
        )
    }
}

private struct MentionSuggestionsViewContent: View {
    @State var viewModel: MentionSuggestionsView.ViewModel
    let text: String
    var participants: [UserSearch.Result]
    let onSelect: (UserSearch.Result) -> Void

    @State private var rowsContentHeight: CGFloat = 0

    @ScaledMetric private var minHeight: CGFloat = 50
    @ScaledMetric private var maxHeight: CGFloat = 164

    var body: some View {
        Group {
            if isShowingList {
                suggestionsList()
            }
        }
        .onChange(of: text, initial: true) {
            viewModel.update(text: text, participants: participants)
        }
        .onChange(of: participants) {
            viewModel.update(text: text, participants: participants)
        }
        .preference(key: MentionListHeightKey.self, value: emittedHeight)
    }

    private var isShowingList: Bool {
        viewModel.isActive && !viewModel.suggestions.isEmpty
    }

    private var emittedHeight: CGFloat {
        isShowingList ? listHeight : 0
    }

    @ViewBuilder private func suggestionsList() -> some View {
        BoxView(
            borderOpacity: 0.5,
            cornerSize: .big,
            paddingSize: .none,
        ) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.suggestions) { suggestion in
                        suggestionRow(suggestion)
                    }
                }
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { rowsContentHeight = $0 }
            }
            .frame(height: listHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .contentShape(Rectangle())
        .overlay(alignment: .topTrailing) {
            closeButton()
        }
        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
        .transition(.opacity)
    }

    private var listHeight: CGFloat {
        min(max(rowsContentHeight, minHeight), maxHeight)
    }

    private var cornerRadius: CGFloat {
        BoxView<EmptyView>.CornerSize.big.value
    }

    @ViewBuilder private func closeButton() -> some View {
        Button {
            viewModel.dismiss()
        } label: {
            Label("Close suggestions", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.FG_2)
                .padding(7)
                .background(Circle().fill(Color.BG_1))
        }
        .buttonStyle(.plain)
        .padding(4)
    }

    @ViewBuilder private func suggestionRow(_ suggestion: UserSearch.Result) -> some View {
        Button {
            onSelect(suggestion)
        } label: {
            HStack(spacing: 10) {
                UserImage(seed: suggestion.avatarSeed ?? suggestion.username, size: .small)

                Text(suggestion.username)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
    }
}

#Preview {
    @Previewable @State var text = "@"
    VStack {
        Spacer()
        MentionSuggestionsView(
            text: text,
            participants: UserSearch.mock.results,
            onSelect: { _ in },
        )
    }
    .padding()
    .screenStyle()
    .environment(\.api, .mock)
}
