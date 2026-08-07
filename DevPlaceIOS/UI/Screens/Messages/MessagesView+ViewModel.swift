import Foundation
import Observation
import DevPlaceSwiftSDK

extension MessagesView {
    @Observable final class ViewModel {
        let api: DevPlaceApi

        var inbox: MessagesInbox?
        var isReloading = false
        var alertMessage: AlertMessage = .none()

        init(api: DevPlaceApi) {
            self.api = api
        }

        var conversations: [Conversation] {
            inbox?.conversations ?? []
        }

        func load() async {
            guard AppState.shared.isLoggedIn else {
                inbox = nil
                return
            }
            do {
                inbox = try await api.messages()
                await AppState.shared.loadUnreadCounts(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func reload() async {
            guard AppState.shared.isLoggedIn else {
                inbox = nil
                return
            }
            guard !isReloading else { return }
            isReloading = true
            defer { isReloading = false }
            do {
                inbox = try await api.messages()
                await AppState.shared.loadUnreadCounts(api: api)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
