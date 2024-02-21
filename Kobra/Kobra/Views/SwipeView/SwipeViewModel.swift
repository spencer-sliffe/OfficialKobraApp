//
//  SwipeViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/21/24.
//

import Foundation
import Combine

/*class SwipeViewModel: ObservableObject {
    @Published var videoPosts: [Post] = []
    @Published var currentVideoIndex: Int = 0
    private var postManager = FSPostManager.shared
    private var allVideoURLs: [String] = []
    private var cancellables: Set<AnyCancellable> = []

    init() {
        loadInitialVideos()
    }

    private func loadInitialVideos() {
        // Fetch the first two video posts
        postManager.fetchVideoPosts(limit: 2) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.videoPosts = posts
                self?.allVideoURLs = posts.compactMap { $0.videoURL }
            case .failure(let error):
                print("Error fetching posts: \(error.localizedDescription)")
            }
        }
    }

    func loadNextVideo() {
        let nextIndex = currentVideoIndex + 1
        guard nextIndex < allVideoURLs.count else { return }

        if nextIndex >= videoPosts.count {
            // Fetch the next video post
            postManager.fetchVideoPost(url: allVideoURLs[nextIndex]) { [weak self] result in
                switch result {
                case .success(let post):
                    self?.videoPosts.append(post)
                case .failure(let error):
                    print("Error fetching post: \(error.localizedDescription)")
                }
            }
        }
    }
    func updateCurrentVideoIndex(to newIndex: Int) {
        currentVideoIndex = newIndex
        loadNextVideo()
    }
}
*/
