import SwiftUI
import AVKit
import DevPlaceSwiftSDK

struct AttachmentViewer: View {
    let attachment: Attachment
    
    var body: some View {
        if let url = URL(string: attachment.url) {
            if attachment.isVideo {
                VideoAttachmentView(url: url)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
            } else if attachment.isImage {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

private struct VideoAttachmentView: View {
    let url: URL
    @State private var player: AVPlayer
    
    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }
    
    var body: some View {
        VideoPlayer(player: player)
    }
}

#Preview("image") {
    AttachmentViewer(
        attachment: .init(
            id: "1",
            filename: "cat.jpg",
            url: "https://picsum.photos/600/400",
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
