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
                    Text("\(like.likerUsername) liked your post")
                case .dislike(let dislike):
                    Text("\(dislike.dislikerUsername) disliked your post")
                case .comment(let comment):
                    Text("\(comment.authorUsername) commented on your post: \(comment.commentText)")
                }
            case .chat(let chatNoti):
                Text("\(chatNoti.senderUsername) messaged you")
            case .follower(let follower):
                Text("\(follower.followerUsername) started following you")
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
}

