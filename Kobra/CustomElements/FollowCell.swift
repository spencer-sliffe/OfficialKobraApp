//
//  FollowCell.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/2/23.
//

import Foundation
import SwiftUI

struct FollowCell: View {
    @ObservedObject var viewModel: FollowCellViewModel
    let accountId: String
    
    init(accountId: String) {
        self.accountId = accountId
        self.viewModel = FollowCellViewModel(accountId: accountId)
        self.viewModel.fetchAccount()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Circle view for the profile picture
            if viewModel.isLoading {
                ProgressView()
            } else if let account = viewModel.account {
                ZStack {
                    if let profilePictureURL = account.profilePicture {
                        AsyncImage(url: profilePictureURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 3)
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }
                    } else {
                        // Placeholder image with system person.crop.circle.fill
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    }
                }
                VStack(alignment: .leading) {
                    // Display only the part of the email before the '@'
                    Text(account.username.uppercased())
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.7))
                    
                    // Additional information about the account, showing if the user has a subscription
                    HStack {
                        Image(systemName: account.subscription ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .foregroundColor(account.subscription ? .green : .red)
                        Text(account.subscription ? "Subscribed" : "Not subscribed")
                            .font(.system(size: 12))
                            .foregroundColor(Color.black.opacity(0.7))
                    }
                }
                Spacer() // Add this line
            }
            
        }
        .padding(.all, 5)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
    }
}
