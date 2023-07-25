//
//  VideoPlayerView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/24/23.
//

import Foundation
import AVKit
import SwiftUI

struct VideoPlayerView: UIViewControllerRepresentable {
    var videoURL: URL
    @Binding var shouldPlay: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: self.videoURL)
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            if shouldPlay {
                player.play()
            }
        }
        playerViewController.player = player
        return playerViewController
    }

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        if shouldPlay {
            playerViewController.player?.play()
        } else {
            playerViewController.player?.pause()
        }
    }
}

