//
//  SwipeView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/21/24.
//

import Foundation

import SwiftUI
import AVKit

struct SwipeView: View {
    @ObservedObject var viewModel: KobraViewModel // Assuming this contains your video posts
    @State private var currentVideoIndex = 0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let videoURL = URL(string: viewModel.posts[currentVideoIndex].videoURL ?? "") {
                    VideoPlayer(player: createPlayer(from: videoURL))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onAppear {
                            viewModel.currentlyPlaying?.play()
                        }
                        .onDisappear {
                            viewModel.currentlyPlaying?.pause()
                        }
                } else {
                    Text("No video available")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height < 0 {
                            // Swipe Up
                            if currentVideoIndex < viewModel.posts.count - 1 {
                                currentVideoIndex += 1
                            }
                        } else if value.translation.height > 0 {
                            // Swipe Down
                            if currentVideoIndex > 0 {
                                currentVideoIndex -= 1
                            }
                        }
                        viewModel.currentlyPlaying?.pause() // Pause current video
                        loadNextVideo()
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }

    private func createPlayer(from url: URL) -> AVPlayer {
        if viewModel.currentlyPlaying == nil || viewModel.currentlyPlaying?.currentItem?.asset != AVAsset(url: url) {
            viewModel.currentlyPlaying = AVPlayer(url: url)
        }
        return viewModel.currentlyPlaying!
    }

    private func loadNextVideo() {
        if let nextVideoURL = URL(string: viewModel.posts[currentVideoIndex].videoURL ?? "") {
            viewModel.currentlyPlaying = AVPlayer(url: nextVideoURL)
            viewModel.currentlyPlaying?.play()
        }
    }
}
