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
    let accountId: String
    @StateObject var viewModel: AccountProfileViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel // Make sure this environment object is available
    
    init(accountId: String) {
        self.accountId = accountId
        _viewModel = StateObject(wrappedValue: AccountProfileViewModel(accountId: accountId))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let account = viewModel.account {
                let emailComponents = account.email.split(separator: "@")
                let displayName = String(emailComponents[0]).uppercased()
                
                HStack {
                    // Profile picture
                    if let profilePicture = account.profilePicture {
                        AsyncImage(url: profilePicture) { image in
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

                    // Account name, subscription, and following information
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) { // Adjusted spacing from 10 to 5
                            Text(displayName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            
                            if let package = account.package {
                                Text("Current Subscription: \(package.name) - $\(package.price, specifier: "%.2f")/month")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            } else {
                                Text("Current Subscription: None")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        
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
                    }
                }
                .padding(.bottom, 2)
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
        .frame(maxWidth: .infinity) // Make sure VStack takes the whole width
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
            .edgesIgnoringSafeArea(.all) // Ignore safe area to fill the whole screen
        )
        .foregroundColor(.white)
    }
}


