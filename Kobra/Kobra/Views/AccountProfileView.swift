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
    @ObservedObject var kobraViewModel = KobraViewModel()
    @State var showFollowerView = false
    @State var showFollowingView = false
    
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
                let displayName = account.username
                
                VStack(alignment: .center, spacing: -10) { // Reduced spacing
                    
                    Text(displayName)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, -10)
                        .padding(.leading, 10)
                    HStack {
                        // Profile picture
                        if let profilePictureString = account.profilePicture {
                            AsyncImage(url: profilePictureString) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80) // Instagram's profile picture size is smaller
                                    .clipShape(Circle())
                                    .padding(.top, 10)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                                    .frame(width: 80, height: 80) // Same size for placeholder
                                    .clipShape(Circle())
                                    .padding(.top, 10)
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80) // Same size even if no picture
                                .clipShape(Circle())
                                .padding(.top, 10)
                        }
                        Spacer()
                        VStack {
                            Button(action: {
                                showFollowerView = true
                            }) {
                                VStack(alignment: .center, spacing: 0) {
                                    Text("\(account.followers.count)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                                .padding(.vertical, 2) // Padding inside the border
                                .background(
                                    RoundedRectangle(cornerRadius: 5) // Rounded Rectangle with corner radius of 15
                                        .stroke(Color.white, lineWidth: 2) // White border with line width of 2
                                )
                            }
                            .sheet(isPresented: $showFollowerView) {
                                FollowerView(viewModel: viewModel) // Provide necessary inputs if needed
                            }
                        }
                        
                        VStack {
                            Button(action: {
                                showFollowingView = true
                            }) {
                                VStack(alignment: .center, spacing: 0) {
                                    Text("\(account.following.count)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Text("Following")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                                .padding(.vertical, 2) // Padding inside the border
                                .background(
                                    RoundedRectangle(cornerRadius: 5) // Rounded Rectangle with corner radius of 15
                                        .stroke(Color.white, lineWidth: 2) // White border with line width of 2
                                )
                            }
                            .sheet(isPresented: $showFollowingView) {
                                FollowingView(viewModel: viewModel) // Provide necessary inputs if needed
                            }
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    .padding(.bottom, -12)
                    
                    if let bio = account.bio {
                        VStack(alignment: .leading) {
                            Text(bio)
                                .font(.caption)
                                .foregroundColor(.white)
                                .lineLimit(nil) // Allows text to wrap onto as many lines as needed
                        }
                        .frame(maxWidth: 200) // Adjust this to fit your needs
                        .padding(.bottom, 12)
                        .padding(.leading, 13)
                    }
                    if(viewModel.showFollowButton){
                        Button(action: {
                            if viewModel.isFollowing {
                                viewModel.unfollowAccountById()
                            } else {
                                viewModel.followAccountById()
                            }
                        }) {
                            Text(viewModel.isFollowing ? "Following" : "Follow")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .background(viewModel.isFollowing ? Color.gray : Color.blue)
                                .cornerRadius(5)
                        }
                        .padding(.leading, 14)
                    }
                }
                .foregroundColor(.white)
                .padding(.leading, 40) // move the VStack slightly to the right
                
                // User Posts
                Spacer()
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if viewModel.userPosts.isEmpty {
                            Text("No posts yet")
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        } else {
                            ForEach(viewModel.userPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })) { post in
                                PostRow(post: post)
                                    .environmentObject(kobraViewModel)
                                    .background(Color.clear)
                            }
                        }
                    }
                }
                .background(Color.clear)
            } else {
                Text("Failed to fetch account data")
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
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

