//
//  CommentView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/13/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct CommentView: View {
    @ObservedObject var post: Post
    @State private var newCommentText = ""
    var currentUserId: String = Auth.auth().currentUser?.uid ?? ""
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(post.comments) { comment in
                        CommentRow(comment: comment)
                    }
                }
                HStack {
                    TextField("Write a comment...", text: $newCommentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        addComment()
                    }) {
                        Text("Post")
                    }
                }
                .padding()
            }
            .navigationTitle("Comments")
        }
    }
    
    func addComment() {
        if !newCommentText.isEmpty {
            let newComment = Comment(text: newCommentText, commenter: currentUserId, timestamp: Date())
            post.comments.append(newComment)
            newCommentText = ""
        }
    }
}
