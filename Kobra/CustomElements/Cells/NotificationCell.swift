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
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 5)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
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
                        .foregroundColor(.white)
                }
                Spacer(minLength:5)
            }
            .padding(5)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.35))
            .cornerRadius(2)
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
                NavigationLink(destination: AccountProfileView(accountId: senderId)
                    .environmentObject(homePageViewModel)
                    ) {
                    Text(username)
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
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
            NotificationLink(username: comment.authorUsername, text:  "'\(comment.commentText)'", senderId: notification.senderId, homePageViewModel: homePageViewModel)
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
        case .post(let postNoti):
            switch postNoti.type {
            case .like:
                return "heart" // Use a heart icon for like notifications
            case .dislike:
                return "hand.thumbsdown" // Use a thumbs down icon for dislike notifications
            case .comment:
                return "message" // Use a message icon for comment notifications
            }
        case .chat(_):
            return "message"
        case .follower(_):
            return "person.badge.plus"
        }
    }
}


