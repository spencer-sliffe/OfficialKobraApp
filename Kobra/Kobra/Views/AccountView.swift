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
                    .padding(.bottom, 20)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding(.bottom, 20)
                }
                
                Text(displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let package = account.package {
                    VStack(spacing: 20) {
                        Text("Current Subscription:")
                            .font(.headline)
                        HStack {
                            Text(package.name)
                                .font(.title2)
                            Spacer()
                            Text("$\(package.price, specifier: "%.2f")/month")
                                .font(.title2)
                        }
                        .padding(.horizontal)
                    }
                    .foregroundColor(.white)
                } else {
                    Text("Current Subscription: None")
                        .font(.headline)
                        .foregroundColor(.white)
                }
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
                            .environmentObject(kobraViewModel) // Pass the environment object here
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
