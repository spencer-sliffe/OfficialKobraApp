//
//  DislikeButton.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/17/24.
//

import Foundation
import SwiftUI

struct DislikeButton: View {
    let post: Post
    let currentUserId: String
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    
    var body: some View {
        Button(action: {
            // Implement dislike action
            // Toggle dislike status
            let isDisliked = post.dislikingUsers.contains(currentUserId)
            var dislikes = post.dislikes
            
            if isDisliked {
                dislikes -= 1
                post.dislikingUsers.removeAll { $0 == currentUserId }
            } else {
                dislikes += 1
                post.dislikingUsers.append(currentUserId)
            }
            
            // Update dislike count
            kobraViewModel.updateDislikeCount(post, dislikeCount: dislikes, userId: currentUserId, isAdding: !isDisliked)
        }) {
            HStack {
                Image(systemName: post.dislikingUsers.contains(currentUserId) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .foregroundColor(post.dislikingUsers.contains(currentUserId) ? .black : .gray)
                Text("\(post.dislikes)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(5)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 1)
                    )
            }
        }
    }
}
