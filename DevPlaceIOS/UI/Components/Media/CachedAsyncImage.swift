import SwiftUI
import NetworkImage

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    init(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content,
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        NetworkImage(url: url, scale: scale, transaction: transaction) { state in
            content(state.asyncImagePhase)
        }
    }
}

extension CachedAsyncImage {
    init<I, P>(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P,
    ) where Content == _ConditionalContent<I, P> {
        self.init(
            url: url,
            scale: scale,
            transaction: transaction,
        ) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
}

private extension NetworkImageState {
    var asyncImagePhase: AsyncImagePhase {
        switch self {
        case .empty: .empty
        case .success(let image, _): .success(image)
        case .failure: .failure(CachedAsyncImageError.failedToLoad)
        }
    }
}

private enum CachedAsyncImageError: Error {
    case failedToLoad
}
