import Foundation
import Observation
import DevPlaceSwiftSDK

extension ProfileView {
    @Observable final class ViewModel {
        let username: String?
        
        let api: DevPlaceApi
        
        var isLoading = false
        
        var alertMessage: AlertMessage = .none()
        
        var profile: Profile?

        var isBlocked = false

        var isMuted = false

        init(username: String?, api: DevPlaceApi) {
            self.username = username
            self.api = api
        }

        var navigationTitle: String {
            username ?? profile?.user.username ?? "Profile"
        }

        var isMyOwnProfile: Bool {
            profile?.isOwner ?? false
        }

        var displayedUsername: String {
            profile?.user.username ?? ""
        }

        func load() async {
            isLoading = true
            defer { isLoading = false }

            do {
                let profile = try await api.profile(username: username)
                self.profile = profile
                isBlocked = profile.isBlocked
                isMuted = profile.isMuted
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func block() async {
            guard let username = profile?.user.username else { return }
            do {
                try await api.blockUser(username: username)
                isBlocked = true
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func unblock() async {
            guard let username = profile?.user.username else { return }
            do {
                try await api.unblockUser(username: username)
                isBlocked = false
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func mute() async {
            guard let username = profile?.user.username else { return }
            do {
                try await api.muteUser(username: username)
                isMuted = true
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func unmute() async {
            guard let username = profile?.user.username else { return }
            do {
                try await api.unmuteUser(username: username)
                isMuted = false
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}
