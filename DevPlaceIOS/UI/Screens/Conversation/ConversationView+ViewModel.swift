import Foundation
import Observation
import DevPlaceSwiftSDK

extension ConversationView {
    @Observable final class ViewModel {
        let otherUser: User
        let api: DevPlaceApi

        var inbox: MessagesInbox?
        var draft = ""
        var attachments: [UploadResponse] = []
        var isReloading = false
        var isSending = false
        var alertMessage: AlertMessage = .none()

        init(otherUser: User, api: DevPlaceApi) {
            self.otherUser = otherUser
            self.api = api
        }

        var messages: [Message] {
            (inbox?.messages ?? []).sorted { $0.data.createdAt < $1.data.createdAt }
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
                inbox = try await api.messages(withUid: otherUser.id)
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
                inbox = try await api.messages(withUid: otherUser.id)
                await AppState.shared.loadUnreadCounts(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func send() async {
            guard canSend else { return }
            let content = draft
            let attachmentsToSend = attachments
            isSending = true
            defer { isSending = false }
            do {
                try await api.sendMessage(receiverId: otherUser.id, content: content, attachments: attachmentsToSend)
                draft = ""
                attachments = []
                try? await Task.sleep(for: .milliseconds(500))
                inbox = try await api.messages(withUid: otherUser.id)
                await AppState.shared.loadUnreadCounts(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
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
    }
}
