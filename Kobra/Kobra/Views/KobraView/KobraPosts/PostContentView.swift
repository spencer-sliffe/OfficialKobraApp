//
//  PostContentView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/19/24.
//

import Foundation
import SwiftUI

struct PostContentView: View {
    let post: Post
    let selectedFeed: FeedType
    @Binding var showingComments: Bool // Add a binding for showingComments

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
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
            VStack(alignment:.center){
                switch post.type {
                case .advertisement(let advertisementPost):
                    Text(advertisementPost.content)
                        .font(.subheadline)
                        .foregroundColor(.white)
                case .help(let helpPost):
                    Text(helpPost.details)
                        .font(.subheadline)
                        .foregroundColor(.white)
                case .news(let newsPost):
                    Text(newsPost.category + " News: " + newsPost.article)
                        .font(.subheadline)
                        .foregroundColor(.white)
                case .bug(let bugPost):
                    Text("App Bug: " + bugPost.content)
                        .font(.subheadline)
                        .foregroundColor(.white)
                case .meme(let memePost):
                    Text(memePost.content)
                        .font(.subheadline)
                        .foregroundColor(.white)
                case .market(let marketPost):
                    MarketPostContent(marketPost: marketPost, imageURL: post.imageURL, videoURL: post.videoURL)
                }
            }
        }
    }
}
