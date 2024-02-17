//  PostRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import AVKit
import AVFoundation

struct PostRow: View {
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    
    @ObservedObject var post: Post
    @Binding var selectedFeed: FeedType
    let currentUserId: String
    @State private var showingComments = false // State to control the presentation of CommentView

    init(post: Post, selectedFeed: Binding<FeedType>, currentUserId: String) {
        self.post = post
        self._selectedFeed = selectedFeed
        self.currentUserId = currentUserId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            PosterView(post: post, currentUserId: currentUserId)
                .environmentObject(kobraViewModel)
            Divider()
                .frame(height: 1)
                .background(.gray)
            PostContentView(post: post, selectedFeed: selectedFeed, showingComments: $showingComments)
            PostActionView(post: post, currentUserId: currentUserId, showingComments: $showingComments)
                .environmentObject(kobraViewModel)
            TimestampView(timestamp: post.timestamp)
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(getBackgroundColor(for: post.type))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .sheet(isPresented: $showingComments) {
            CommentView(post: post)
                .environmentObject(kobraViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(homePageViewModel)
        }
    }
    
    func getBackgroundColor(for postType: Post.PostType) -> Color {
        switch postType {
        case .advertisement:
            return Color.purple.opacity(0.35)
        case .help:
            return Color.green.opacity(0.35)
        case .news:
            return Color.red.opacity(0.35)
        case .bug:
            return Color.teal.opacity(0.35)
        case .meme:
            return Color.indigo.opacity(0.35)
        case .market:
            return Color.yellow.opacity(0.35)
        }
    }
}

struct PostContentView: View {
    let post: Post
    let selectedFeed: FeedType
    @Binding var showingComments: Bool // Add a binding for showingComments

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
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

struct MarketPostContent: View {
    let marketPost: MarketPost
    let imageURL: String?
    let videoURL: String?
    
    var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            switch marketPost.type {
            case .hardware(let hardware):
                Text("Hardware: \(hardware.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(hardware.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .software(let software):
                Text("Software: \(software.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(software.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .service(let service):
                Text("Service: \(service.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(service.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            case .other(let other):
                Text("Other: \(other.title)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(other.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                            .contentShape(Rectangle())
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                            .contentShape(Rectangle())
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
            
            if let videoURL = videoURL, let url = URL(string: videoURL) {
                VideoPlayerView(videoURL: url, shouldPlay: .constant(false), isInView: .constant(false))
                    .frame(height: 300)
                    .contentShape(Rectangle())
            }
            
            Text("Price: \(priceFormatter.string(from: NSNumber(value: marketPost.price)) ?? "")")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

