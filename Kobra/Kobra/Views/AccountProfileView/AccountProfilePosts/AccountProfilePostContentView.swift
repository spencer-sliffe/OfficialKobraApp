//
//  AccountProfilePostContentView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/17/24.
//

import Foundation
import SwiftUI

struct AccountProfilePostContentView: View {
    let post: Post
    @Binding var showingComments: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            switch post.type {
            case .advertisement(let advertisementPost):
                Text("Advertisement: \(advertisementPost.content)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .help(let helpPost):
                Text("Help: \(helpPost.details)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .news(let newsPost):
                Text("\(newsPost.category) News: \(newsPost.article)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .bug(let bugPost):
                Text("App Bug: \(bugPost.content)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .meme(let memePost):
                Text("Meme: \(memePost.content)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .market(let marketPost):
                AccountProfileMarketPostContent(marketPost: marketPost, imageURL: post.imageURL, videoURL: post.videoURL)
            }
            
            if let imageURL = post.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5, anchor: .center)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: 300)
            }
            if let videoURL = post.videoURL, let url = URL(string: videoURL) {
                VideoPlayerView(videoURL: url, shouldPlay: .constant(false), isInView: .constant(false))
                    .frame(height: 300)
            }
        }
    }
}

