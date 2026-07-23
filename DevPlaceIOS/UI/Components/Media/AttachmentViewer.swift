import SwiftUI
import DevPlaceSwiftSDK

struct AttachmentViewer: View {
    let attachment: Attachment
    
    @State private var fullscreen: FullscreenItem?
    
    enum FullscreenItem: Identifiable {
        case image(URL)
        case video(URL)
        
        var id: String {
            switch self {
            case .image(let url): "image:\(url.absoluteString)"
            case .video(let url): "video:\(url.absoluteString)"
            }
        }
    }
    
    var body: some View {
        if let url = URL(string: fullUrl) {
            content(url: url)
                .fullScreenCover(item: $fullscreen) { item in
                    switch item {
                    case .image(let url):
                        FullscreenImageViewer(url: url)
                    case .video(let url):
                        FullscreenVideoPlayer(url: url)
                    }
                }
        }
    }
    
    @ViewBuilder private func content(url: URL) -> some View {
        if attachment.isVideo {
            Button {
                fullscreen = .video(url)
            } label: {
                VideoThumbnailView(url: url)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Video attachment. Tap to play."))
        } else if attachment.isImage {
            Button {
                fullscreen = .image(url)
            } label: {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Image attachment. Tap to view fullscreen."))
        }
    }
    
    private var fullUrl: String {
        if attachment.url.hasPrefix("/") {
            return "https://devplace.net" + attachment.url
        } else {
            return attachment.url
        }
    }
}

#Preview("image") {
    AttachmentViewer(
        attachment: .init(
            id: "1",
            filename: "cat.jpg",
            url: "https://picsum.photos/id/1015/600/400",
            size: nil,
            isImage: true,
            isVideo: false,
            mimeType: "image/jpeg",
            createdAt: .now,
            canModify: false,
        )
    )
    .padding()
}

#Preview("video") {
    AttachmentViewer(
        attachment: .init(
            id: "2",
            filename: "clip.mp4",
            url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            size: nil,
            isImage: false,
            isVideo: true,
            mimeType: "video/mp4",
            createdAt: .now,
            canModify: false,
        )
    )
    .padding()
}
