//
//  CommentView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/13/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase

struct CommentView: View {
    @EnvironmentObject var viewModel: KobraViewModel
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
                    TextField("Add a comment...", text: $newCommentText)
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
        }
    }
    
    func addComment() {
        if !newCommentText.isEmpty {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                print("Error: User not logged in or uid not found")
                return
            }
            
            let accountRef = Firestore.firestore().collection("Accounts").document(currentUserId)
            
            accountRef.getDocument { (document, error) in
                if let error = error {
                    print("Error getting user data: \(error.localizedDescription)")
                    return
                }
                
                guard let document = document, document.exists, let userData = document.data(), let username = userData["username"] as? String else {
                    print("Error: User data not found or username field is missing")
                    return
                }
                
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

}
