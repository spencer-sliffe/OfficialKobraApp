//
//  CommentRow.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/13/23.
//

import SwiftUI

struct CommentRow: View {
    let comment: Comment
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    var body: some View {
        NavigationLink(destination: AccountProfileView(accountId: comment.commenterId)
            .environmentObject(settingsViewModel)
            .environmentObject(homePageViewModel)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.commenter)
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("•")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(comment.text)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.bottom, 4) // Add some spacing between commenter and comment text
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16) // Add horizontal padding for better readability
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.35)) // Add a background color to the entire row
        )
        .padding(.horizontal, 2) // Add some horizontal spacing around the row
    }
}



