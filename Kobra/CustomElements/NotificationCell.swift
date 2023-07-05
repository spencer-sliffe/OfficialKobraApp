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
    
    var body: some View {
        HStack {
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
