//
//  FSNotificationManager.swift
//  Kobra
//
//  Created by Spencer SLiffe on 7/5/23.
//

import Foundation
import Firebase
import UIKit

class FSNotificationManager {
    private let db = Firestore.firestore()
    private let Collection = "Accounts"
    
    func fetchNotifications(accountId: String, completion: @escaping (Result<[Notification], Error>) -> Void) {
        let query = db.collection(Collection).document(accountId).collection("Notifications")
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var notifs: [Notification] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let notification = self.createNotiFrom(data: data)
                notifs.append(notification)
            }
            completion(.success(notifs))
        }
    }
    
    private func createNotiFrom(data: [String: Any]) -> Notification {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let receiverId = data["receiverId"] as? String ?? ""
        let senderId = data["senderId"] as? String ?? ""
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let notificationTypeString = data["notificationType"] as? String ?? ""
        var notificationType: Notification.NotificationType
        let seen = data["seen"] as? Bool ?? false
        
        switch notificationTypeString {
        case "chat":
            let chatId = data["chatId"] as? String ?? ""
            let senderUsername = data["senderUsername"] as? String ?? ""
            let chat = ChatNotification(chatId: chatId, senderUsername: senderUsername)
            notificationType = .chat(chat)
        case "follower":
            let followerUsername = data["followerUsername"] as? String ?? ""
            let follower = FollowerNotification(followerUsername: followerUsername)
            notificationType = .follower(follower)
        case "post":
            let postNotiTypeString = data["postNotificationType"] as? String ?? ""
            var postNotiType: PostNotification.PostNotiType
            switch postNotiTypeString {
            case "like":
                let postId = data["postId"] as? String ?? ""
                let likerUsername = data["likerUsername"] as? String ?? ""
                let like = LikeNotification(postId: postId, likerUsername: likerUsername)
                postNotiType = .like(like)
            case "dislike":
                let postId = data["postId"] as? String ?? ""
                let dislikerUsername = data["dislikerUsername"] as? String ?? ""
                let dislike = DislikeNotification(postId: postId, dislikerUsername: dislikerUsername)
                postNotiType = .dislike(dislike)
            case "comment":
                let postId = data["postId"] as? String ?? ""
                let commentId = data["commentId"] as? String ?? ""
                let commentText = data["commentText"] as? String ?? ""
                let authorUsername = data["authorUserName"] as? String ?? ""
                let comment = CommentNotification(postId: postId, commentId: commentId, commentText: commentText, authorUsername: authorUsername)
                postNotiType = .comment(comment)
            default:
                fatalError("Unknown Post notification type")
            }
            let post = PostNotification(type: postNotiType)
            notificationType = .post(post)
        default:
            fatalError("Unknown notification type")
        }
        return Notification(id: id, receiverId: receiverId, senderId: senderId, type: notificationType, timestamp: timestamp, seen: seen)
    }
    
    func addNotification(_ notification: Notification, completion: @escaping (Result<Void, Error>) -> Void) {
        let accountId = notification.receiverId
        let data = self.convertNotiToData(notification)
        let query = db.collection(Collection).document(accountId).collection("Notifications")
        query.addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    private func convertNotiToData(_ notification: Notification) -> [String: Any] {
        var data: [String: Any] = [
            "id": notification.id.uuidString,
            "receiverId": notification.receiverId,
            "senderId": notification.senderId,
            "timeStamp": notification.timestamp,
            "seen": notification.seen
        ]
        
        var notiTypeString: String
        var postNotiTypeString: String?
        switch notification.type {
        case .chat(let chatNotification):
            notiTypeString = "chat"
            data["chatId"] = chatNotification.chatId
            data["senderUsername"] = chatNotification.senderUsername
        case .follower(let followerNotification):
            notiTypeString = "follower"
            data["followerUsername"] = followerNotification.followerUsername
        case .post(let postNotification):
            notiTypeString = "post"
            switch postNotification.type {
            case .like(let like):
                postNotiTypeString = "like"
                data["postId"] = like.postId
                data["likerUsername"] = like.likerUsername
            case .dislike(let dislike):
                postNotiTypeString = "dislike"
                data["postId"] = dislike.postId
                data["dislikerUsername"] = dislike.dislikerUsername
            case .comment(let comment):
                postNotiTypeString = "comment"
                data["postId"] = comment.postId
                data["commentId"] = comment.commentId
                data["commentText"] = comment.commentText
                data["authorUsername"] = comment.authorUsername
            }
            if let postNotiTypeString = postNotiTypeString {
                data["postNotiType"] = postNotiTypeString
            }
        }
        data["notificationType"] = notiTypeString
        return data
    }
}
