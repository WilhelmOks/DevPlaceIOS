import SwiftUI

struct FullscreenImageViewer: View {
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
