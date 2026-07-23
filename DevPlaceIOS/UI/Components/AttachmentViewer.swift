import SwiftUI
import AVKit
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
        if let url = URL(string: attachment.url) {
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
}

private struct VideoThumbnailView: View {
    let url: URL
    
    @State private var thumbnail: UIImage?
    
    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.BG_2
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            }
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white, .black.opacity(0.5))
                .shadow(radius: 4)
                .accessibilityHidden(true)
        }
        .task(id: url) {
            await loadThumbnail()
        }
    }
    
    private func loadThumbnail() async {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 800, height: 0)
        do {
            let cgImage = try await generator.image(at: .zero).image
            thumbnail = UIImage(cgImage: cgImage)
        } catch {
            dlog("Failed to load video thumbnail: \(error)")
        }
    }
}

private struct FullscreenImageViewer: View {
    let url: URL
    
    @Environment(\.dismiss) private var dismiss
    @State private var uiImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Group {
                if let uiImage {
                    ZoomableImage(uiImage: uiImage)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let uiImage {
                        let sharedImage = Image(uiImage: uiImage)
                        ShareLink(
                            item: sharedImage,
                            preview: SharePreview("Image", image: sharedImage),
                        )
                    }
                }
            }
            .task(id: url) {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            uiImage = UIImage(data: data)
        } catch {
            dlog("Failed to load image: \(error)")
        }
    }
}

private struct ZoomableImage: View {
    let uiImage: UIImage
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 5
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = min(max(minScale, lastScale * value.magnification), maxScale)
                    }
                    .onEnded { _ in
                        lastScale = scale
                        if scale <= minScale {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        guard scale > minScale else { return }
                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height,
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
    }
}

private struct FullscreenVideoPlayer: View {
    let url: URL
    
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer
    
    init(url: URL) {
        self.url = url
        self._player = State(initialValue: AVPlayer(url: url))
    }
    
    var body: some View {
        NavigationStack {
            VideoPlayer(player: player)
                .ignoresSafeArea(edges: .bottom)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: url)
                    }
                }
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
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
