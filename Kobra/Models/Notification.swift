//
//  Notification.swift
//  Kobra
//
//  Created by Spencer SLiffe on 7/5/23.
//

import Foundation

class Notification: Identifiable  {
    enum NotificationType {
        case postNotification(PostNotification)
        case chatNotification(ChatNotification)
        case followerNotification(FollowerNotification)
    }
    var id = UUID()
    var accountId: String
    var type: NotificationType
    var timestamp: Date
    var seen: Bool
    
    init(id: UUID = UUID(), accountId: String, type: NotificationType, timestamp: Date, seen: Bool) {
        self.id = id
        self.accountId = accountId
        self.type = type
        self.timestamp = timestamp
        self.seen = seen
    }
}

struct PostNotification {
    enum PostNotiType {
        case likeNotification(LikeNotification)
        case dislikeNotification(DislikeNotification)
        case commentNotification(CommentNotification)
    }
}

struct LikeNotification {
    var postId: String
    var likerId: String
    var likerUsername: String
}

struct DislikeNotification {
    var postId: String
    var dislikerId: String
    var dislikerUsername: String
}

struct CommentNotification {
    var postId: String
    var commentId: String
    var authorId: String
    var commentText: String
    var authorUsername: String
}

struct ChatNotification {
    var chatId: String
    var authorId: String
    var authorUsername: String
}

struct FollowerNotification {
    var followerId: String
    var followerUsername: String
}

