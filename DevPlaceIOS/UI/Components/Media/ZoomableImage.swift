import SwiftUI

struct ZoomableImage: View {
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
