//
// AccountView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import SwiftUI
import Firebase

struct AccountView: View {
    @ObservedObject var viewModel = AccountViewModel()
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State var isLoggedOut = false
    
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
                                    .padding(.leading, 10)
                            } else {
                                Text("Current Subscription: None")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
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
                
                .foregroundColor(.white)
            } else {
                Text("Failed to fetch account data")
                    .foregroundColor(.white)
            }
            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.userPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })) { post in
                        AccountPostRow(post: post)
                            .background(Color.clear)
                            .environmentObject(kobraViewModel)
                    }
                }
            }
            .background(Color.clear)
        }
        .background(Color.clear)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }
}


