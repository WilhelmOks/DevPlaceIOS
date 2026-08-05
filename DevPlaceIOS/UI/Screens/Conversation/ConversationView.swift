import SwiftUI
import DevPlaceSwiftSDK

struct ConversationView: View {
    let otherUser: User

    @Environment(\.api) var api

    var body: some View {
        ConversationViewContent(viewModel: .init(otherUser: otherUser, api: api))
    }
}

private struct ConversationViewContent: View {
    @State var viewModel: ConversationView.ViewModel

    @Environment(\.scenePhase) private var scenePhase

    @State private var isAtBottom = true

    @FocusState private var isInputFocused: Bool

    @State private var attachmentsResetToken = 0

    var body: some View {
        content()
            .environment(
                \.quoteComposer,
                QuoteComposer(isActive: true) { viewModel.draft += $0 },
            )
            .screenStyle(bgColor: .BG_2)
            .navigationTitle(Text(viewModel.otherUser.username))
            .navigationBarTitleDisplayMode(.inline)
            .alert($viewModel.alertMessage)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    reloadToolbarItem()
                }
            }
            .safeAreaInset(edge: .bottom) {
                composer()
            }
            .task {
                await viewModel.load()
            }
            .onDisappear {
                Task { await viewModel.deleteUnsubmittedAttachments() }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task { await viewModel.load() }
                }
            }
    }

    @ViewBuilder private func content() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top)
            }
            .defaultScrollAnchor(.bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    isInputFocused = false
                }
            )
            .onScrollGeometryChange(for: Bool.self) { geometry in
                let distanceFromBottom = geometry.contentSize.height - geometry.contentInsets.top - geometry.containerSize.height - geometry.contentOffset.y
                return distanceFromBottom <= 30
            } action: { _, newValue in
                isAtBottom = newValue
            }
            .onChange(of: viewModel.messages.last?.id, initial: true) {
                scrollToBottom(proxy, animated: false)
            }
            .overlay(alignment: .bottomTrailing) {
                if !isAtBottom {
                    scrollToBottomButton(proxy)
                }
            }
            .animation(.snappy, value: isAtBottom)
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool) {
        guard let lastId = viewModel.messages.last?.id else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            if animated {
                withAnimation {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }

    @ViewBuilder private func scrollToBottomButton(_ proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToBottom(proxy, animated: true)
        } label: {
            Label("Scroll to latest", systemImage: "chevron.down")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.accentGradient(shape: .circle))
        .padding()
        .transition(.scale.combined(with: .opacity))
    }

    @ViewBuilder private func composer() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .composerInput, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Type a message…", text: $viewModel.draft, axis: .vertical)
                        .lineLimit(1...6)
                        .textFieldStyle(.devPlace(backgroundColor: .BG_0))
                        .focused($isInputFocused)
                        .alignmentGuide(.composerInput) { $0[.bottom] }

                    HStack(spacing: 8) {
                        CharacterCounterView(
                            text: viewModel.draft,
                            minCount: viewModel.minCharacterCount,
                            maxCount: DevPlaceConstants.maxDirectMessageLength,
                        )

                        if viewModel.attachments.isEmpty {
                            Spacer(minLength: 0)

                            AttachmentUploaderView(
                                isSmall: true,
                                attachments: viewModel.attachments,
                                onAttachmentsChange: { viewModel.attachments = $0 },
                            )
                            .id(attachmentsResetToken)
                        }
                    }
                    .padding(.horizontal, 10)
                }

                sendButton()
            }

            if !viewModel.attachments.isEmpty {
                AttachmentUploaderView(
                    attachments: viewModel.attachments,
                    onAttachmentsChange: { viewModel.attachments = $0 },
                )
                .id(attachmentsResetToken)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Color.BG_1.ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            Divider()
        }
    }

    @ViewBuilder private func sendButton() -> some View {
        Button {
            Task {
                if await viewModel.send() {
                    attachmentsResetToken += 1
                }
            }
        } label: {
            if viewModel.isSending {
                ProgressView()
            } else {
                Label("Send message", systemImage: "paperplane.fill")
                    .labelStyle(.iconOnly)
            }
        }
        .buttonStyle(.accentGradient(shape: .circle))
        .disabled(!viewModel.canSend)
        .opacity(viewModel.canSend ? 1 : 0.4)
    }

    @ViewBuilder private func reloadToolbarItem() -> some View {
        if viewModel.isReloading {
            ProgressView()
        } else {
            Button {
                Task { await viewModel.reload() }
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

private extension VerticalAlignment {
    enum ComposerInputAlignment: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            dimensions[.bottom]
        }
    }

    static let composerInput = VerticalAlignment(ComposerInputAlignment.self)
}

#Preview {
    NavigationStack {
        ConversationView(otherUser: .mockAlice)
    }
    .environment(\.api, .mock)
}
