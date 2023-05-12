//
//  CommentView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/13/23
//

import Foundation
import SwiftUI
import FirebaseAuth

struct CommentView: View {
    @ObservedObject var viewModel: KobraViewModel
    @ObservedObject var post: Post
    @State private var newCommentText = ""
    
    var currentUserId: String = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.comments) { comment in
                        CommentRow(comment: comment)
                    }
                }
                .onAppear {
                    viewModel.fetchComments(for: post) { _ in }
                }
                .listStyle(InsetGroupedListStyle())
                
                HStack {
                    TextField("Write a comment...", text: $newCommentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .foregroundColor(.primary)
                        .accentColor(.green)
                    
                    Button(action: {
                        addComment()
                    }) {
                        Text("Post")
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Comments")
        }
    }
    
    func addComment() {
        if !newCommentText.isEmpty {
            guard let userEmail = Auth.auth().currentUser?.email else {
                print("Error: User not logged in or email not found")
                return
            }
            let username = userEmail.components(separatedBy: "@")[0]
            let newComment = Comment(text: newCommentText, commenter: username, timestamp: Date())
            viewModel.addComment(newComment, to: post) { result in
                switch result {
                case .success:
                    print("Comment added successfully")
                    newCommentText = ""
                    viewModel.fetchComments(for: post) { _ in }
                case .failure(let error):
                    print("Error adding comment: \(error.localizedDescription)")
                }
            }
        }
    }
}
