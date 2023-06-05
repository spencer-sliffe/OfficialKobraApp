//
//  AccountProfileView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 6/5/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct AccountProfileView: View {
    var account: Account
    @StateObject var viewModel = DiscoverViewModel()
    @State private var isFollowing = false

    var body: some View {
        VStack {
            if let url = account.profilePicture {
                Image(url.absoluteString)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 100, height: 100)
                    .cornerRadius(50)
            } else {
                // Placeholder view for when the profile picture is nil
            }
            
            Text(account.email)
                .font(.system(size: 18, weight: .semibold))
                .padding()
            
            Button(action: {
                isFollowing.toggle()
                if let currentUserId = Auth.auth().currentUser?.uid {
                    if isFollowing {
                        viewModel.follow(account: account, followerId: currentUserId)
                    } else {
                        viewModel.unfollow(account: account, followerId: currentUserId)
                    }
                }
            }) {
                Text(isFollowing ? "Unfollow" : "Follow")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 120, height: 40)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .onAppear {
            checkIfFollowing()
        }
    }

    func checkIfFollowing() {
        if let currentUserId = Auth.auth().currentUser?.uid {
            isFollowing = account.followers.contains(currentUserId)
        }
    }
}


