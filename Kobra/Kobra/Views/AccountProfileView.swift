//
//  AccountProfileView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 6/5/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct AccountProfileView: View {
    let accountId: String
    @ObservedObject var viewModel: AccountProfileViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var kobraViewModel: KobraViewModel

    init(accountId: String) {
        self.accountId = accountId
        self.viewModel = AccountProfileViewModel(accountId: accountId)
        self.viewModel.fetchAccount()
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let account = viewModel.account {
                let displayName = account.username.uppercased()

                HStack(alignment: .top) {
                    // Profile picture
                    if let profilePictureString = account.profilePicture {
                        AsyncImage(url: profilePictureString) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .padding(.leading, 20)
                    }

                    VStack(alignment: .center) { // Changed from .leading to .center
                        // Account name, Following and followers
                        VStack(alignment: .center, spacing: 10) { // Changed from .leading to .center
                            Text(displayName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            HStack {
                                VStack {
                                    Text("\(account.followers.count)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .padding(.trailing)
                                VStack {
                                    Text("\(account.following.count)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Text("Following")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .padding(.trailing)
                            }
                            .foregroundColor(.white)
                            HStack {
                                Button(action: {
                                }) {
                                    Text(viewModel.isFollowing ? "Following" : "Follow")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 3)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                                .padding(.top, 1)
                            }
                        }
                        .padding(.bottom, 2)
                    }
                }
                .foregroundColor(.white)
            } else {
                Text("Failed to fetch account data")
                    .foregroundColor(.white)
            }
            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.userPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })) { post in
                        PostRow(post: post)
                            .background(Color.clear)
                    }
                }
            }
            .background(Color.clear)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        gradientOptions[settingsViewModel.gradientIndex].0,
                        gradientOptions[settingsViewModel.gradientIndex].1
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .foregroundColor(.white)
    }
}
