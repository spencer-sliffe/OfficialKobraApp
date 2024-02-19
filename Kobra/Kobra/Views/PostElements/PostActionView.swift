//
//  PostActionView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/17/24.
//

import Foundation
import SwiftUI

struct PostActionView: View {
    let post: Post
    let currentUserId: String
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @Binding var showingComments: Bool // Add a binding for showingComments

    var body: some View {
        HStack {
            LikeButton(post: post, currentUserId: currentUserId)
                .environmentObject(kobraViewModel)
            DislikeButton(post: post, currentUserId: currentUserId)
                .environmentObject(kobraViewModel)
            CommentButton(post: post, showingComments: $showingComments)
                .environmentObject(kobraViewModel)
        }
    }
}

