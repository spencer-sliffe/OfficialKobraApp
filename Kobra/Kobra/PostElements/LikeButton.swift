//
//  LikeButton.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/17/24.
//

import Foundation
import SwiftUI

struct LikeButton: View {
    let post: Post
    let currentUserId: String
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    
    var body: some View {
        Button(action: {
            // Implement like action
            // Toggle like status
            let isLiked = post.likingUsers.contains(currentUserId)
            var likes = post.likes
            
            if isLiked {
                likes -= 1
                post.likingUsers.removeAll { $0 == currentUserId }
            } else {
                likes += 1
                post.likingUsers.append(currentUserId)
            }
            
            // Update like count
            kobraViewModel.updateLikeCount(post, likeCount: likes, userId: currentUserId, isAdding: !isLiked)
        }) {
            HStack {
                Image(systemName: post.likingUsers.contains(currentUserId) ? "heart.fill" : "heart")
                    .foregroundColor(post.likingUsers.contains(currentUserId) ? .red : .gray)
                Text("\(post.likes)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(5)
                    .background(Color.red.opacity(0.5))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.red, lineWidth: 1)
                    )
            }
        }
    }
}
