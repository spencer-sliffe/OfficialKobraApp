//
//  CommentRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/13/23.
//

import SwiftUI
import FirebaseAuth

struct CommentRow: View {
    let comment: Comment
    let post: Post // Add post as a parameter
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var kobraViewModel: KobraViewModel // Make sure to inject KobraViewModel
    
    // Get the current user's UID from FirebaseAuth
    let currentUserUID = Auth.auth().currentUser?.uid
    
    // State variable to control the delete confirmation alert
    @State private var isDeleteAlertPresented = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.commenter)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("•")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(comment.text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                if currentUserUID == comment.commenterId {
                    Button(action: {
                        // Show the delete confirmation alert
                        isDeleteAlertPresented = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    }
                    .alert(isPresented: $isDeleteAlertPresented) {
                        Alert(
                            title: Text("Delete Comment"),
                            message: Text("Are you sure you want to delete this comment?"),
                            primaryButton: .destructive(Text("Delete")) {
                                // Call the deleteComment function when the user confirms
                                kobraViewModel.deleteComment(comment, from: post) { result in
                                    switch result {
                                    case .success:
                                        // Handle success, you might want to update your UI here
                                        break
                                    case .failure(let error):
                                        // Handle failure, show an alert or error message
                                        print("Error deleting comment: \(error.localizedDescription)")
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .padding(.bottom, 4)

            // Show the delete button only if the current user is the commenter
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 2)
    }
}


