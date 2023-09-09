//
//  NotificationCell.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/5/23.
//

import Foundation
import SwiftUI

struct NotificationCell: View {
    var notification: Notification
    @ObservedObject var viewModel = NotificationViewModel()
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    @State private var isPostSelected = false
    
    var body: some View {
        VStack {
            HStack {
                // Show a blue dot if the notification is not seen
                if !notification.seen {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color.blue)
                        .padding(.trailing, 5)
                }
                
                // Add icon based on notification type
                Image(systemName: getIcon())
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 5)
                
                VStack(alignment: .leading, spacing: 2) {
                    switch notification.type {
                    case .post(let postNoti):
                        postNotificationTypeView(from: postNoti)
                        
                    case .chat(let chatNoti):
                        NotificationLink(username: chatNoti.senderUsername, text: "messaged you", senderId: notification.senderId, homePageViewModel: homePageViewModel)

                    case .follower(let follower):
                        NotificationLink(username: follower.followerUsername, text: "started following you", senderId: notification.senderId, homePageViewModel: homePageViewModel)
                    }
                    
                    Text(getFormattedDate())
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
            .onTapGesture {
                if case let .post(postNoti) = notification.type {
                    isPostSelected = true
                    if let postId = getPostId(from: postNoti) {
                        viewModel.fetchPostById(postId: postId)
                    }
                }
            }
            .sheet(isPresented: $isPostSelected) {
                if let post = viewModel.post {
                    NavigationView {
                        PostView(post: post)
                            .environmentObject(homePageViewModel)
                    }
                }
            }
        }
    }
    
    // Helper function to format the Date
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, hh:mm a"
        return formatter.string(from: notification.timestamp)
    }
    
    struct NotificationLink: View {
        var username: String
        var text: String
        var senderId: String
        var homePageViewModel: HomePageViewModel // Pass the view model
        
        var body: some View {
            HStack {
                NavigationLink(destination: AccountProfileView(accountId: senderId).environmentObject(homePageViewModel)
                    ) {
                    Text(username)
                        .foregroundColor(.blue)
                }
                Text(text)
            }
        }
    }

    @ViewBuilder
    func postNotificationTypeView(from postNoti: PostNotification) -> some View {
        switch postNoti.type {
        case .like(let like):
            NotificationLink(username: like.likerUsername, text: "liked your post", senderId: notification.senderId, homePageViewModel: homePageViewModel)
        case .dislike(let dislike):
            NotificationLink(username: dislike.dislikerUsername, text: "disliked your post", senderId: notification.senderId, homePageViewModel: homePageViewModel)
        case .comment(let comment):
            NotificationLink(username: comment.authorUsername, text: "commented on your post: \(comment.commentText)", senderId: notification.senderId, homePageViewModel: homePageViewModel)
        }
    }
    
    func getPostId(from postNoti: PostNotification) -> String? {
        switch postNoti.type {
        case .like(let like):
            return like.postId
        case .dislike(let dislike):
            return dislike.postId
        case .comment(let comment):
            return comment.postId
        }
    }

    func getIcon() -> String {
        switch notification.type {
        case .post(_):
            return "doc.text.below.ecg"
        case .chat(_):
            return "message"
        case .follower(_):
            return "person.2"
        }
    }
}

