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

    private let bottomAnchorId = "conversation-bottom"

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

                    Color.clear
                        .frame(height: 1)
                        .id(bottomAnchorId)
                }
                .padding()
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y + geometry.containerSize.height >= geometry.contentSize.height - 24
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
        guard !viewModel.messages.isEmpty else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            if animated {
                withAnimation {
                    proxy.scrollTo(bottomAnchorId, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(bottomAnchorId, anchor: .bottom)
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
        VStack(spacing: 8) {
            AttachmentUploaderView(
                attachments: viewModel.attachments,
                onAttachmentsChange: { viewModel.attachments = $0 },
            )

            DevPlaceTextEditor(
                text: $viewModel.draft,
                placeholder: "Type a message…",
                initialLineCount: 1,
                animatesHeightChanges: true,
            )

            HStack(alignment: .center, spacing: 12) {
                CharacterCounterView(
                    text: viewModel.draft,
                    minCount: viewModel.minCharacterCount,
                    maxCount: DevPlaceConstants.maxDirectMessageLength,
                )

                Spacer(minLength: 0)

                sendButton()
            }
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
            Task { await viewModel.send() }
        } label: {
            if viewModel.isSending {
                ProgressView()
            } else {
                Label("Send message", systemImage: "arrow.up")
                    .labelStyle(.iconOnly)
            }
        }
        .buttonStyle(.accentGradient(shape: .circle))
        .disabled(!viewModel.canSend)
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
