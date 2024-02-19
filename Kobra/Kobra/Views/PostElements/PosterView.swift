//
//  PosterView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/17/24.
//

import Foundation
import SwiftUI

struct PosterView: View {
    let post: Post
    let currentUserId: String
    @State private var profilePictureURL: URL?
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    
    var body: some View {
        HStack {
            if let url = profilePictureURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.gray))
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(.gray))
            }
            
            // Implement post type-specific text
            switch post.type {
            case .advertisement(let advertisementPost):
                Text(advertisementPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(advertisementPost.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .help(let helpPost):
                Text(helpPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(helpPost.question + "?")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .news(let newsPost):
                Text(newsPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(newsPost.headline)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .bug(let bugPost):
                Text(bugPost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(bugPost.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .meme(let memePost):
                Text(memePost.poster + ":  ")
                    .font(.subheadline)
                    .foregroundColor(.blue) +
                Text(memePost.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            case .market(let marketPost):
                Text(marketPost.vendor)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            fetchProfilePicture()
        }
    }
    
    private func fetchProfilePicture() {
        kobraViewModel.fetchProfilePicture(for: post) { result in
            switch result {
            case .success(let url):
                self.profilePictureURL = url
            case .failure(let error):
                print("Error fetching profile picture: \(error.localizedDescription)")
            }
        }
    }
}
