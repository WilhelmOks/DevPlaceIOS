import SwiftUI
import AVKit

struct VideoThumbnailView: View {
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
