import Foundation
import Observation
import DevPlaceSwiftSDK

extension ConversationView {
    @Observable final class ViewModel {
        let otherUser: User
        let api: DevPlaceApi

        var inbox: MessagesInbox?
        var messages: [Message] = []
        var draft = ""
        var attachments: [UploadResponse] = []
        var isReloading = false
        var isSending = false
        var isOtherTyping = false
        var alertMessage: AlertMessage = .none()

        private var socket: (any MessagesSocket)?
        private var eventLoop: Task<Void, Never>?
        private var typingResetTask: Task<Void, Never>?
        private var isSocketConnected = false
        private var lastTypingSentAt: Date?
        private var pendingSends: [String: PendingSend] = [:]

        private struct PendingSend {
            let content: String
            let attachments: [UploadResponse]
        }

        init(otherUser: User, api: DevPlaceApi) {
            self.otherUser = otherUser
            self.api = api
        }

        var minCharacterCount: Int {
            attachments.isEmpty ? 1 : 0
        }

        var canSend: Bool {
            guard !isSending else { return false }
            let count = TextCharacterCounter.numberOfCharacters(draft)
            return count >= minCharacterCount && count <= DevPlaceConstants.maxDirectMessageLength
        }

        func load() async {
            do {
                let inbox = try await api.messages(withUid: otherUser.id)
                self.inbox = inbox
                seedMessages(from: inbox)
                await AppState.shared.loadUnreadCounts(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func reload() async {
            guard !isReloading else { return }
            isReloading = true
            defer { isReloading = false }
            do {
                let inbox = try await api.messages(withUid: otherUser.id)
                self.inbox = inbox
                seedMessages(from: inbox)
                await AppState.shared.loadUnreadCounts(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func send() async -> Bool {
            guard canSend else { return false }
            let content = draft
            let attachmentsToSend = attachments
            let clientId = UUID().uuidString
            isSending = true
            draft = ""
            attachments = []
            defer { isSending = false }

            appendOptimistic(content: content, attachments: attachmentsToSend, clientId: clientId)

            if isSocketConnected, let socket {
                pendingSends[clientId] = PendingSend(content: content, attachments: attachmentsToSend)
                await socket.send(content: content, attachmentUids: attachmentsToSend.map(\.id), clientId: clientId)
                return true
            }

            do {
                try await api.sendMessage(receiverId: otherUser.id, content: content, attachments: attachmentsToSend)
                try? await Task.sleep(for: .milliseconds(500))
                let inbox = try await api.messages(withUid: otherUser.id)
                self.inbox = inbox
                removeOptimistic(clientId: clientId)
                seedMessages(from: inbox)
                await AppState.shared.loadUnreadCounts(api: api)
                return true
            } catch {
                removeOptimistic(clientId: clientId)
                draft = content
                attachments = attachmentsToSend
                alertMessage = .presentedError(error)
                return false
            }
        }

        func userIsTyping() {
            guard isSocketConnected, let socket else { return }
            let now = Date()
            if let last = lastTypingSentAt, now.timeIntervalSince(last) < 1.5 {
                return
            }
            lastTypingSentAt = now
            Task { await socket.sendTyping() }
        }

        func deleteUnsubmittedAttachments() async {
            let unsubmitted = attachments
            attachments = []
            for attachment in unsubmitted {
                do {
                    try await api.deleteAttachment(uid: attachment.id)
                } catch {
                    dlog("Failed to delete unsubmitted message attachment \(attachment.id): \(error)")
                }
            }
        }

        // MARK: - Realtime

        func startRealtime() async {
            guard socket == nil else { return }
            let socket = api.makeMessagesSocket(otherUserId: otherUser.id)
            self.socket = socket
            eventLoop = Task { [weak self] in
                for await event in socket.events {
                    self?.handle(event)
                }
            }
            await socket.connect()
        }

        func stopRealtime() {
            isSocketConnected = false
            isOtherTyping = false
            typingResetTask?.cancel()
            typingResetTask = nil
            eventLoop?.cancel()
            eventLoop = nil
            if let socket {
                Task { await socket.disconnect() }
            }
            socket = nil
        }

        private func handle(_ event: ChatSocketEvent) {
            switch event {
            case .ready:
                isSocketConnected = true
                sendRead()
            case .message(let incoming):
                upsertIncoming(incoming)
            case .typing(let fromUid):
                if fromUid == otherUser.id {
                    showOtherTyping()
                }
            case .read(let byUid):
                if byUid == otherUser.id {
                    markMyMessagesRead()
                }
            case .failed(let clientId, let text):
                handleSendFailure(clientId: clientId, text: text)
            case .disconnected:
                isSocketConnected = false
            }
        }

        private func upsertIncoming(_ incoming: ChatSocketIncomingMessage) {
            let belongsToConversation = incoming.senderUid == otherUser.id || incoming.receiverUid == otherUser.id
            guard belongsToConversation else { return }

            let message = makeMessage(from: incoming)

            if let clientId = incoming.clientId, let index = messages.firstIndex(where: { $0.data.id == clientId }) {
                messages[index] = message
                pendingSends[clientId] = nil
            } else if let index = messages.firstIndex(where: { $0.data.id == message.data.id }) {
                messages[index] = message
            } else {
                messages.append(message)
            }
            messages.sort { $0.data.createdAt < $1.data.createdAt }

            if !message.isMine {
                sendRead()
                Task { await AppState.shared.loadUnreadCounts(api: api) }
            }
        }

        private func showOtherTyping() {
            isOtherTyping = true
            typingResetTask?.cancel()
            typingResetTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { return }
                self?.isOtherTyping = false
            }
        }

        private func markMyMessagesRead() {
            messages = messages.map { message in
                guard message.isMine, !message.data.read else {
                    return message
                }
                return message.withRead(true)
            }
        }

        private func handleSendFailure(clientId: String?, text: String) {
            if let clientId {
                removeOptimistic(clientId: clientId)
                if draft.isEmpty, let pending = pendingSends[clientId] {
                    draft = pending.content
                    attachments = pending.attachments
                }
                pendingSends[clientId] = nil
            }
            alertMessage = .presentedError(message: text)
        }

        private func sendRead() {
            guard let socket else { return }
            let otherUserId = otherUser.id
            Task { await socket.sendRead(withUid: otherUserId) }
        }

        private func seedMessages(from inbox: MessagesInbox) {
            let stillPending = messages.filter { pendingSends.keys.contains($0.data.id) }
            var merged = inbox.messages
            for pending in stillPending where !merged.contains(where: { $0.data.id == pending.data.id }) {
                merged.append(pending)
            }
            messages = merged.sorted { $0.data.createdAt < $1.data.createdAt }
        }

        private func appendOptimistic(content: String, attachments: [UploadResponse], clientId: String) {
            let attachmentModels = attachments.map { upload in
                Attachment(
                    id: upload.id,
                    filename: upload.filename,
                    url: upload.url,
                    size: upload.size,
                    isImage: upload.isImage,
                    isVideo: upload.isVideo,
                    mimeType: upload.mimeType,
                    createdAt: Date(),
                    canModify: true,
                )
            }
            let data = Message.Data(
                id: clientId,
                senderId: AppState.shared.currentUser?.id ?? "",
                receiverId: otherUser.id,
                content: content,
                read: false,
                createdAt: Date(),
            )
            let message = Message(
                data: data,
                sender: AppState.shared.currentUser ?? otherUser,
                isMine: true,
                attachments: attachmentModels,
            )
            messages.append(message)
            messages.sort { $0.data.createdAt < $1.data.createdAt }
        }

        private func removeOptimistic(clientId: String) {
            messages.removeAll { $0.data.id == clientId }
            pendingSends[clientId] = nil
        }

        private func makeMessage(from incoming: ChatSocketIncomingMessage) -> Message {
            let isMine = incoming.senderUid == AppState.shared.currentUser?.id
            let sender = isMine ? (AppState.shared.currentUser ?? otherUser) : otherUser
            let data = Message.Data(
                id: incoming.uid,
                senderId: incoming.senderUid,
                receiverId: incoming.receiverUid,
                content: incoming.content,
                read: false,
                createdAt: incoming.createdAt,
            )
            return Message(
                data: data,
                sender: sender,
                isMine: isMine,
                attachments: incoming.attachments,
            )
        }
    }
}

private extension Message {
    func withRead(_ read: Bool) -> Message {
        Message(
            data: Message.Data(
                id: data.id,
                senderId: data.senderId,
                receiverId: data.receiverId,
                content: data.content,
                read: read,
                createdAt: data.createdAt,
            ),
            sender: sender,
            isMine: isMine,
            attachments: attachments,
        )
    }
}
