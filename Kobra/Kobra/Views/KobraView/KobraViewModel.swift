//
//  KobraViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/31/23.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import Firebase
import AVKit

class KobraViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    private var postManager = FSPostManager.shared
    private var notificationManager = FSNotificationManager.shared
    private var cancellables: Set<AnyCancellable> = []
    @Published var uploadProgress: Double = 0.0
    @Published var isUploadInProgress: Bool = false
    @Published var currentlyPlaying: AVPlayer?
    @Published var isLoading = false
    @Published var accountId = ""
    
    init() {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        self.accountId = user.uid
    }

    func uploadImage(_ image: UIImage, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        isUploadInProgress = true
        postManager.uploadImage(image, postId: postId, progress: { [weak self] progress in
            DispatchQueue.main.async {
                self?.uploadProgress = progress // adjust the scale
            }
        }, completion: { result in
            DispatchQueue.main.async {
                self.isUploadInProgress = false
                completion(result)
            }
        })
    }
    
    func uploadVideo(_ videoURL: URL, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        isUploadInProgress = true
        postManager.uploadVideo(videoURL, postId: postId, progress: { [weak self] progress in
            DispatchQueue.main.async {
                self?.uploadProgress = progress // adjust the scale
            }
        }, completion: { result in
            DispatchQueue.main.async {
                self.isUploadInProgress = false
                completion(result)
            }
        })
    }
    
    
    func fetchPosts(completion: @escaping () -> Void) {
        postManager.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self?.posts = posts
                case .failure(let error):
                    print("Error fetching posts: \(error.localizedDescription)")
                }
                completion() // Call the completion closure here
            }
        }
    }
    
    func addPost(_ post: Post, image: UIImage? = nil, videoURL: URL? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        if let image = image {
            uploadImage(image, postId: post.id.uuidString) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    let newPost = post
                    newPost.imageURL = imageURL
                    self?.addPostToDatabase(newPost, completion: completion)
                case .failure(let error):
                    print("Error uploading image: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        } else if let videoURL = videoURL {
            uploadVideo(videoURL, postId: post.id.uuidString) { [weak self] result in
                switch result {
                case .success(let videoURL):
                    let newPost = post
                    newPost.videoURL = videoURL
                    self?.addPostToDatabase(newPost, completion: completion)
                case .failure(let error):
                    print("Error uploading video: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        } else {
            addPostToDatabase(post, completion: completion)
        }
    }
    
    private func addPostToDatabase(_ post: Post, completion: ((Result<Void, Error>) -> Void)? = nil) {
        postManager.addPost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPosts(){}
                    completion?(.success(()))
                case .failure(let error):
                    print("Error adding post: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func updateLikeCount(_ post: Post, likeCount: Int, userId: String, isAdding: Bool) {
        postManager.updateLikeCount(post, likeCount: likeCount, userId: userId, isAdding: isAdding)
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        let db = Firestore.firestore()
        let ref = db.collection("Accounts").document(user.uid)
        ref.getDocument { [weak self] (document, error) in
            if let document = document, document.exists, let data = document.data(), let username = data["username"] as? String {
                let id = UUID()
                let receiverId = post.posterId
                let senderId = user.uid
                let timestamp = Date()
                let seen = false
                let postIdString = post.id
                let postId = postIdString.uuidString
                print(postId)
                let likerUsername = username
                if isAdding {
                    let postNotiType: PostNotification.PostNotiType
                    let like = LikeNotification(postId: postId, likerUsername: likerUsername)
                    postNotiType = .like(like)
                    let postNotification = PostNotification(type: postNotiType)
                    let notificationType = Notification.NotificationType.post(postNotification)
                    let notification = Notification(id: id, receiverId: receiverId, senderId: senderId, type: notificationType, timestamp: timestamp, seen: seen)
                    self?.sendLikeNotification(notification)
                }
                self?.fetchPosts(){}
            } else {
                print("Error fetching account data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func updateDislikeCount(_ post: Post, dislikeCount: Int, userId: String, isAdding: Bool) {
        postManager.updateDislikeCount(post, dislikeCount: dislikeCount, userId: userId, isAdding: isAdding)
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        let db = Firestore.firestore()
        let ref = db.collection("Accounts").document(user.uid)
        ref.getDocument { [weak self] (document, error) in
            if let document = document, document.exists, let data = document.data(), let username = data["username"] as? String {
                let id = UUID()
                let receiverId = post.posterId
                let senderId = user.uid
                let timestamp = Date()
                let seen = false
                let postIdString = post.id
                let postId = postIdString.uuidString
                print(postId)
                let dislikerUsername = username
                if isAdding {
                    let postNotiType: PostNotification.PostNotiType
                    let dislike = DislikeNotification(postId: postId, dislikerUsername: dislikerUsername)
                    postNotiType = .dislike(dislike)
                    let postNotification = PostNotification(type: postNotiType)
                    let notificationType = Notification.NotificationType.post(postNotification)
                    let notification = Notification(id: id, receiverId: receiverId, senderId: senderId, type: notificationType, timestamp: timestamp, seen: seen)
                    self?.sendDislikeNotification(notification)
                    
                }
                self?.fetchPosts(){}
            } else {
                print("Error fetching account data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    func updateComments(_ post: Post, comment: Comment){
        postManager.updateComments(post, comment: comment)
        fetchPosts(){}
    }
    
    func deleteComment(_ comment: Comment, from post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        postManager.deleteComment(comment, from: post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPosts(){}
                    completion(.success(()))
                case .failure(let error):
                    print("Error deleting comment: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updatePost(_ post: Post) {
        postManager.updatePost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPosts(){}
                case .failure(let error):
                    print("Error updating post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deletePost(_ post: Post) {
        postManager.deletePost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let imageURL = post.imageURL {
                        self?.postManager.deleteImage(imageURL: imageURL) { result in
                            switch result {
                            case .success:
                                print("Image deleted successfully")
                            case .failure(let error):
                                print("Error deleting image: \(error.localizedDescription)")
                            }
                        }
                    }
                    self?.fetchPosts(){}
                case .failure(let error):
                    print("Error deleting post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchComments(for post: Post, completion: @escaping ([Comment]) -> Void) {
        postManager.fetchComments(for: post) { [weak self] comments in
            DispatchQueue.main.async {
                self?.comments = comments
                completion(comments)
            }
        }
    }
    
    func addComment(_ comment: Comment, to post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        postManager.addComment(comment, to: post, completion: completion)
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "No user is currently signed in.", code: 0, userInfo: nil)))
            return
        }
        let id = UUID()
        let receiverId = post.posterId
        let senderId = user.uid
        let timestamp = Date()
        let seen = false
        let postIdString = post.id
        let postId = postIdString.uuidString
        print(postId)
        let commentId = comment.id.uuidString
        let commentText = comment.text
        let authorUsername = comment.commenter
        let postNotiType: PostNotification.PostNotiType
        let comment = CommentNotification(postId: postId, commentId: commentId, commentText: commentText, authorUsername: authorUsername)
        postNotiType = .comment(comment)
        let postNotification = PostNotification(type: postNotiType)
        let notificationType: Notification.NotificationType
        notificationType = .post(postNotification)
        let notification = Notification(id: id, receiverId: receiverId, senderId: senderId, type: notificationType, timestamp: timestamp, seen: seen)
        self.sendCommentNotification(notification)
        
    }
    
    func fetchProfilePicture(for post: Post, completion: @escaping (Result<URL, Error>) -> Void) {
        postManager.fetchProfilePicture(post) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(let error):
                    print("Error fetching profile picture: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchUsername(completion: @escaping (Result<String, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "No user is currently signed in.", code: 0, userInfo: nil)))
            return
        }
        let db = Firestore.firestore()
        let ref = db.collection("Accounts").document(user.uid)
        ref.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists, let data = document.data(), let username = data["username"] as? String {
                completion(.success(username))
            } else {
                completion(.failure(NSError(domain: "Error fetching account data", code: 0, userInfo: nil)))
            }
        }
    }
    
    private func sendLikeNotification(_ notification: Notification) {
        notificationManager.addNotification(notification) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Like notification sent successfully.")
                case .failure(let error):
                    print("Error sending like notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendDislikeNotification(_ notification: Notification) {
        notificationManager.addNotification(notification) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Dislike notification sent successfully.")
                case .failure(let error):
                    print("Error sending dislike notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendCommentNotification(_ notification: Notification) {
        notificationManager.addNotification(notification) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Comment notification sent successfully.")
                case .failure(let error):
                    print("Error sending comment notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetData() {
        posts = []
        comments = []
        uploadProgress = 0.0
        isUploadInProgress = false
        currentlyPlaying = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
