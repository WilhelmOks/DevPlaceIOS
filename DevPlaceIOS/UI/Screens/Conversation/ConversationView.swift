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

    @State private var isAtBottom = true

    @FocusState private var isInputFocused: Bool

    @State private var attachmentsResetToken = 0

    var body: some View {
        content()
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
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 12)
            }
            .defaultScrollAnchor(.bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    isInputFocused = false
                }
            )
            .onScrollGeometryChange(for: Bool.self) { geometry in
                let visibleBottom = geometry.contentOffset.y + geometry.containerSize.height - geometry.contentInsets.bottom
                return visibleBottom >= geometry.contentSize.height - 4
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Type a message…", text: $viewModel.draft, axis: .vertical)
                    .lineLimit(1...6)
                    .textFieldStyle(.devPlace)
                    .focused($isInputFocused)

                sendButton()
            }

            CharacterCounterView(
                text: viewModel.draft,
                minCount: viewModel.minCharacterCount,
                maxCount: DevPlaceConstants.maxDirectMessageLength,
            )

            AttachmentUploaderView(
                attachments: viewModel.attachments,
                onAttachmentsChange: { viewModel.attachments = $0 },
            )
            .id(attachmentsResetToken)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
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

#Preview {
    NavigationStack {
        ConversationView(otherUser: .mockAlice)
    }
    .environment(\.api, .mock)
}
