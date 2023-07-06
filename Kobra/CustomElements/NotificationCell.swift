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
    
    var body: some View {
        HStack {
            // Show a blue dot if the notification is not seen
            if !notification.seen {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(Color.blue)
                    .padding(.trailing, 5)
            }

            switch notification.type {
            case .post(let postNoti):
                switch postNoti.type {
                case .like(let like):
                    NotificationLink(username: like.likerUsername, text: "liked your post", senderId: notification.senderId)
                case .dislike(let dislike):
                    NotificationLink(username: dislike.dislikerUsername, text: "disliked your post", senderId: notification.senderId)
                case .comment(let comment):
                    NotificationLink(username: comment.authorUsername, text: "commented on your post: \(comment.commentText)", senderId: notification.senderId)
                }
            case .chat(let chatNoti):
                NotificationLink(username: chatNoti.senderUsername, text: "messaged you", senderId: notification.senderId)
            case .follower(let follower):
                NotificationLink(username: follower.followerUsername, text: "started following you", senderId: notification.senderId)
            }
            Spacer()
            Text(getFormattedDate())
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
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

        var body: some View {
            HStack {
                NavigationLink(destination: AccountProfileView(accountId: senderId)) {
                    Text(username)
                        .foregroundColor(.blue)
                }
                Text(text)
            }
        }
    }
}

