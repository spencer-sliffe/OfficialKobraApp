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

