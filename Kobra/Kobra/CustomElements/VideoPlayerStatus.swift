//
//  VideoPlayerStatus.swift
//  Kobra
//
//  Created by Spencer SLiffe on 7/24/23.
//

import Foundation
import AVFoundation
import Combine

class VideoPlayerStatus: ObservableObject {
    @Published var status: AVPlayer.Status = .unknown
    private var player: AVPlayer?
    private var playerStatusObservation: AnyCancellable?

    func setURL(_ url: URL) {
        player = AVPlayer(url: url)
        playerStatusObservation = player?.publisher(for: \.status)
            .sink { [weak self] in
                self?.status = $0
                
                if $0 == .readyToPlay {
                    self?.player?.play()
                }
            }
    }
    
    var avPlayer: AVPlayer? {
        player
    }
    
    deinit {
        playerStatusObservation?.cancel()
    }
}
