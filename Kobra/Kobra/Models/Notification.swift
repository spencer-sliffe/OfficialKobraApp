//
//  Notification.swift
//  Kobra
//
//  Created by Spencer SLiffe on 7/5/23.
//

import Foundation

class Notification: Identifiable  {
    enum NotificationType {
        case post(PostNotification)
        case chat(ChatNotification)
        case follower(FollowerNotification)
    }
    var id = UUID()
    var receiverId: String
    var senderId: String
    var type: NotificationType
    var timestamp: Date
    var seen: Bool
    
    
    
    init(id: UUID = UUID(), receiverId: String, senderId: String, type: NotificationType, timestamp: Date, seen: Bool) {
        self.id = id
        self.receiverId = receiverId
        self.senderId = senderId
        self.type = type
        self.timestamp = timestamp
        self.seen = seen
    }
}

struct PostNotification {
    enum PostNotiType {
        case like(LikeNotification)
        case dislike(DislikeNotification)
        case comment(CommentNotification)
    }
    var type: PostNotiType
}

struct LikeNotification {
    var postId: String
    var likerUsername: String
}

struct DislikeNotification {
    var postId: String
    var dislikerUsername: String
}

struct CommentNotification {
    var postId: String
    var commentId: String
    var commentText: String
    var authorUsername: String
}

struct ChatNotification {
    var chatId: String
    var senderUsername: String
}

struct FollowerNotification {
    var followerUsername: String
}

