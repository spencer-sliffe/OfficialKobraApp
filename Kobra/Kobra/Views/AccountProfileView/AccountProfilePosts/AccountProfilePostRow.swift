//
//  AccountProfilePostRow.swift
//  Kobra
//
//  Created by Spencer SLiffe on 8/2/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import AVKit
import AVFoundation

struct AccountProfilePostRow: View {
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    
    @ObservedObject var post: Post
    let currentUserId: String
    @State private var showingComments = false // State to control the presentation of CommentView

    init(post: Post, currentUserId: String) {
        self.post = post
        self.currentUserId = currentUserId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            PosterView(post: post, currentUserId: currentUserId)
                .environmentObject(kobraViewModel)
            Divider()
                .frame(height: 1)
                .background(.gray)
            AccountProfilePostContentView(post: post, showingComments: $showingComments)
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
