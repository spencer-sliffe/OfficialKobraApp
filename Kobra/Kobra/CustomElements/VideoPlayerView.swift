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
    @Binding var isInView: Bool // Binding to track if the video is in view

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: self.videoURL)
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            if shouldPlay && isInView { // Check both conditions
                player.play()
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        playerViewController.player = player
        return playerViewController
    }

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        if shouldPlay && isInView { // Check both conditions
            playerViewController.player?.play()
        } else {
            playerViewController.player?.pause()
        }
    }
}
