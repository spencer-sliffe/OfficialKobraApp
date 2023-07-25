//
//  PlayerUIView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 7/22/23.
//

import Foundation
import AVKit
class PlayerUIView: UIView, ObservableObject {
    private var playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    @Published var playerError: Error?
    
    @Published var playerStatus: AVPlayer.Status = .unknown
    
    init(url: URL) {
        super.init(frame: .zero)
        
        player = AVPlayer(url: url)
        player?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player?.removeObserver(self, forKeyPath: "status")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "status" {
                if let status = player?.status {
                    playerStatus = status
                    switch status {
                    case .readyToPlay:
                        player?.play()
                    case .failed:
                        // When the player fails, you can read the error here
                        playerError = player?.currentItem?.error
                    case .unknown:
                        break
                    @unknown default:
                        break
                    }
                }
            }
        }
}
