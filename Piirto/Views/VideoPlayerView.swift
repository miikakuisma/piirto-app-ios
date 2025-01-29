import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoName: String
    
    var body: some View {
        if let path = Bundle.main.path(forResource: videoName, ofType: "mp4") {
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                    // Loop the video
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem,
                        queue: .main
                    ) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
        }
    }
} 