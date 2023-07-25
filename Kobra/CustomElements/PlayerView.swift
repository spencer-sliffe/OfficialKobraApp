//
//  PlayerView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/22/23.
//

import Foundation
import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {
    let url: URL
    @ObservedObject var playerUIView: PlayerUIView
    @Binding var playerStatus: AVPlayer.Status

    init(url: URL, playerStatus: Binding<AVPlayer.Status>) {
        self.url = url
        self.playerUIView = PlayerUIView(url: url)
        self._playerStatus = playerStatus
    }

    func makeUIView(context: Context) -> PlayerUIView {
        return playerUIView
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        DispatchQueue.main.async {
            // Update playerStatus in the next event cycle
            playerStatus = uiView.playerStatus
            
            // Here you can handle the error state
            if let error = uiView.playerError {
                print("Player encountered an error: \(error)")
                // Perform any other error handling as necessary
            }
        }
    }
}

