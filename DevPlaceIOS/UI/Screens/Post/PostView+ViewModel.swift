import Foundation
import Observation
import DevPlaceSwiftSDK

extension PostView {
    @Observable final class ViewModel {
        let slug: String
        let api: DevPlaceApi
        
        var postDetail: PostDetail?
        
        var isReloading = false
        
        var alertMessage: AlertMessage = .none()
        
        init(slug: String, api: DevPlaceApi) {
            self.slug = slug
            self.api = api
        }
        
        var navigationTitle: String {
            postDetail?.post.title ?? "Post"
        }
        
        func load() async {
            do {
                postDetail = try await api.postDetail(slug: slug)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
        
        func reload() async {
            guard !isReloading else { return }
            isReloading = true
            defer { isReloading = false }
            do {
                postDetail = try await api.postDetail(slug: slug)
            } catch {
                alertMessage = .presentedError(error)
            }
        }
    }
}

extension PostDetail {
    var currentVote: Vote {
        switch myVote {
        case 1: .up
        case -1: .down
        default: .none
        }
    }
}
