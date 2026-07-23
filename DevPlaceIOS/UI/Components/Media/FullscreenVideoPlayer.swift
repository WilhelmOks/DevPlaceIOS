import SwiftUI
import AVKit

struct FullscreenVideoPlayer: View {
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
