//
//  FSPostManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/1/23.
//

import Foundation
import FirebaseFirestore
import Firebase
import UIKit
import FirebaseStorage
import AVFoundation


class FSPostManager {
    private init() {}
    static let shared = FSPostManager()
    private let db = Firestore.firestore()
    private let postsCollection = "Posts"
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        db.collection(postsCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var posts: [Post] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let post = self.createPostFrom(data: data)
                posts.append(post)
            }
            completion(.success(posts))
        }
    }
    
    func fetchPostById(postId: String, completion: @escaping (Result<Post, Error>) -> Void) {
        db.collection(postsCollection)
            .whereField("id", isEqualTo: postId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let document = querySnapshot?.documents.first, document.exists {
                    let data = document.data()
                    let post = self.createPostFrom(data: data)
                    completion(.success(post))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                }
            }
    }

    func uploadImage(_ image: UIImage, postId: String, progress: @escaping (Double) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference().child("post_images/\(postId).jpg")
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            progress(percentComplete)
        }
    }
    
    func uploadVideo(_ videoUrl: URL, postId: String, progress: @escaping (Double) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        let avAsset = AVURLAsset(url: videoUrl)
        
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
        
        guard exportSession != nil else {
            completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to start export session"])))
            return
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let newVideoUrl = documentsDirectory.appendingPathComponent("\(postId).mp4")

        exportSession?.outputURL = newVideoUrl
        exportSession?.outputFileType = .mp4

        exportSession?.exportAsynchronously(completionHandler: {
            switch exportSession?.status {
            case .completed:
                self.uploadConvertedVideo(newVideoUrl, postId: postId, progress: progress, completion: completion)
            case .failed, .cancelled:
                completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert video to MP4"])))
            default:
                break
            }
        })
    }


    private func uploadConvertedVideo(_ videoUrl: URL, postId: String, progress: @escaping (Double) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("post_videos/\(postId).mp4")
        
        let uploadTask = storageRef.putFile(from: videoUrl, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            progress(percentComplete)
        }
    }


    
    private func createPostFrom(data: [String: Any]) -> Post {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let likes = data["likes"] as? Int ?? 0
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let postTypeString = data["postType"] as? String ?? ""
        var postType: Post.PostType
        let likingUsers = data["likingUsers"] as? [String] ?? [""]
        let dislikingUsers = data["dislikingUsers"] as? [String] ?? [""]
        let comments = data["comments"] as? [Comment] ?? []
        let dislikes = data["dislikes"] as? Int ?? 0
        let posterId = data["posterId"] as? String ?? ""
        let numComments = data["numComments"] as? Int ?? 0
        
        switch postTypeString {
        case "advertisement":
            let poster = data["poster"] as? String ?? ""
            let title = data["title"] as? String ?? ""
            let content = data["content"] as? String ?? ""
            let category = data["category"] as? String ?? ""
            let advertisementPost = AdvertisementPost(poster: poster, title: title, content: content, category: category)
            postType = .advertisement(advertisementPost)
        case "help":
            let poster = data["poster"] as? String ?? ""
            let question = data["question"] as? String ?? ""
            let details = data["details"] as? String ?? ""
            let category = data["category"] as? String ?? ""
            let helpPost = HelpPost(poster: poster, question: question, details: details, category: category)
            postType = .help(helpPost)
        case "news":
            let poster = data["poster"] as? String ?? ""
            let headline = data["headline"] as? String ?? ""
            let article = data["article"] as? String ?? ""
            let category = data["category"] as? String ?? ""
            let newsPost = NewsPost(poster: poster, headline: headline, article: article, category: category)
            postType = .news(newsPost)
        case "bug":
            let poster = data["poster"] as? String ?? ""
            let title = data["title"] as? String ?? ""
            let content = data["content"] as? String ?? ""
            let category = data["category"] as? String ?? ""
            let bugPost = AppBugPost(poster: poster, title: title, content: content, category: category)
            postType = .bug(bugPost)
        case "meme":
            let poster = data["poster"] as? String ?? ""
            let title = data["title"] as? String ?? ""
            let content = data["content"] as? String ?? ""
            let memePost = MemePost(poster: poster, title: title, content: content)
            postType = .meme(memePost)
        case "market":
            let vendor = data["vendor"] as? String ?? ""
            let marketPostTypeString = data["marketPostType"] as? String ?? ""
            let price = data["price"] as? Double ?? 0.0
            let category = data["category"] as? String ?? ""
            var marketPostType: MarketPost.MarketPostType
            switch marketPostTypeString {
            case "hardware":
                let name = data["name"] as? String ?? ""
                let condition = Hardware.HardwareCondition(rawValue: data["condition"] as? String ?? "used") ?? .used
                let description = data["description"] as? String ?? ""
                let hardware = Hardware(name: name, condition: condition, description: description)
                marketPostType = .hardware(hardware)
            case "software":
                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let software = Software(name: name, description: description)
                marketPostType = .software(software)
            case "service":
                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let service = Service(name: name, description: description)
                marketPostType = .service(service)
            case "other":
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let other = Other(title: title, description: description)
                marketPostType = .other(other)
            default:
                fatalError("Unknown market post type")
            }
            let marketPost = MarketPost(vendor: vendor, type: marketPostType, price: price, category: category)
            postType = .market(marketPost)
        default:
            fatalError("Unknown post type")
        }
        let imageURL = data["imageURL"] as? String
        let videoURL = data["videoURL"] as? String
        return Post(id: id, type: postType, likes: likes, timestamp: timestamp, imageURL: imageURL, videoURL: videoURL, likingUsers: likingUsers, dislikingUsers: dislikingUsers, comments: comments, dislikes: dislikes, posterId: posterId, numComments: numComments)
    }
    
    func addPost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        // Convert the Post struct into a data dictionary
        let data = self.convertPostToData(post)
        db.collection(postsCollection).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func convertPostToData(_ post: Post) -> [String: Any] {
        var data: [String: Any] = [
            "id": post.id.uuidString,
            "likes": post.likes,
            "timestamp": post.timestamp,
            "likingUsers": post.likingUsers,
            "dislikes": post.dislikes,
            "dislikingUsers": post.dislikingUsers,
            "comments": post.comments,
            "posterId": post.posterId,
            "numComments": post.numComments
        ]
        
        var postTypeString: String
        var marketPostTypeString: String?
        switch post.type {
        case .advertisement(let advertisementPost):
            postTypeString = "advertisement"
            data["poster"] = advertisementPost.poster
            data["title"] = advertisementPost.title
            data["content"] = advertisementPost.content
            data["category"] = advertisementPost.category
        case .help(let helpPost):
            postTypeString = "help"
            data["poster"] = helpPost.poster
            data["question"] = helpPost.question
            data["details"] = helpPost.details
            data["category"] = helpPost.category
        case .news(let newsPost):
            postTypeString = "news"
            data["poster"] = newsPost.poster
            data["headline"] = newsPost.headline
            data["article"] = newsPost.article
            data["category"] = newsPost.category
        case .bug(let bugPost):
            postTypeString = "bug"
            data["poster"] = bugPost.poster
            data["title"] = bugPost.title
            data["content"] = bugPost.content
            data["category"] = bugPost.category
        case.meme(let memePost):
            postTypeString = "meme"
            data["poster"] = memePost.poster
            data["title"] = memePost.title
            data["content"] = memePost.content
        case .market(let marketPost):
            postTypeString = "market"
            data["vendor"] = marketPost.vendor
            data["price"] = marketPost.price
            data["category"] = marketPost.category
            
            switch marketPost.type {
            case .hardware(let hardware):
                marketPostTypeString = "hardware"
                data["name"] = hardware.name
                data["condition"] = hardware.condition.rawValue
                data["description"] = hardware.description
            case .software(let software):
                marketPostTypeString = "software"
                data["name"] = software.name
                data["description"] = software.description
            case .service(let service):
                marketPostTypeString = "service"
                data["name"] = service.name
                data["description"] = service.description
            case .other(let other):
                marketPostTypeString = "other"
                data["title"] = other.title
                data["description"] = other.description
            }
            if let marketPostTypeString = marketPostTypeString {
                data["marketPostType"] = marketPostTypeString
            }
        }
        data["postType"] = postTypeString
        if let imageURL = post.imageURL {
            data["imageURL"] = imageURL
        }
        if let videoURL = post.videoURL {
            data["videoURL"] = videoURL
        }
        return data
    }
    
    func fetchComments(for post: Post, completion: @escaping ([Comment]) -> Void) {
        let postId = post.id
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching post: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No document found with matching post id")
                completion([])
                return
            }
            
            document.reference.collection("comments").order(by: "timestamp", descending: true).getDocuments { (commentSnapshot, error) in
                if let error = error {
                    print("Error fetching comments: \(error.localizedDescription)")
                    completion([])
                } else {
                    var comments: [Comment] = []
                    for document in commentSnapshot!.documents {
                        let data = document.data()
                        let id = UUID(uuidString: data["id"] as! String)
                        let text = data["text"] as! String
                        let commenter = data["commenter"] as! String
                        let timestamp = (data["timestamp"] as! Timestamp).dateValue() // Update this line
                        let commenterId = data["commenterId"] as! String
                        
                        let comment = Comment(id: id!, text: text, commenter: commenter, timestamp: timestamp, commenterId: commenterId)
                        comments.append(comment)
                    }
                    completion(comments)
                }
            }
        }
    }
    
    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = post.id
        let data = self.convertPostToData(post)
        db.collection(postsCollection).document(id.uuidString).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let postId = post.id
        
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = querySnapshot?.documents.first {
                document.reference.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "No document found with matching id", code: -1, userInfo: nil)))
            }
        }
    }
    
    func updateComments(_ post: Post, comment: Comment) {
        let postId = post.id
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No document found with matching post id")
                return
            }
            
            let commentData: [String: Any] = [
                "id": comment.id.uuidString,
                "text": comment.text,
                "commenter": comment.commenter,
                "timestamp": comment.timestamp,
                "commenterId": comment.commenterId
            ]
            
            document.reference.collection("comments").addDocument(data: commentData) { error in
                if let error = error {
                    print("Error adding comment: \(error.localizedDescription)")
                } else {
                    print("Comment added successfully")
                }
            }
        }
    }
    
    func updateLikeCount(_ post: Post, likeCount: Int, userId: String, isAdding: Bool) {
        let postId = post.id
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error updating like count: \(error.localizedDescription)")
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No document found with matching post id")
                return
            }
            
            let likingUsers = document.get("likingUsers") as? [String] ?? []
            let updatedUsers: Any = likingUsers.isEmpty && isAdding ? ["", userId] : (isAdding ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]))
            
            document.reference.updateData([
                "likes": likeCount,
                "likingUsers": updatedUsers
            ]) { error in
                if let error = error {
                    print("Error updating like count: \(error.localizedDescription)")
                } else {
                    print("Like count updated successfully")
                }
            }
        }
    }

    func updateDislikeCount(_ post: Post, dislikeCount: Int, userId: String, isAdding: Bool) {
        let postId = post.id
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error updating dislike count: \(error.localizedDescription)")
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No document found with matching post id")
                return
            }
            
            let dislikingUsers = document.get("dislikingUsers") as? [String] ?? []
            let updatedUsers: Any = dislikingUsers.isEmpty && isAdding ? ["", userId] : (isAdding ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]))
            
            document.reference.updateData([
                "dislikes": dislikeCount,
                "dislikingUsers": updatedUsers
            ]) { error in
                if let error = error {
                    print("Error updating dislike count: \(error.localizedDescription)")
                } else {
                    print("Dislike count updated successfully")
                }
            }
        }
    }
    
    // New function to update the image URL of a post
    private func updateImageURLForPost(_ post: Post, imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = post.id
        let postRef = db.collection(postsCollection).document(id.uuidString)
        postRef.updateData([
            "imageURL": imageURL
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteImage(imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: imageURL)
        
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchUserPosts(userId: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        db.collection(postsCollection).whereField("posterId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var posts: [Post] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let post = self.createPostFrom(data: data)
                posts.append(post)
            }
            completion(.success(posts))
        }
    }
    
    func addComment(_ comment: Comment, to post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let postId = post.id
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "No document found with matching post id"])))
                return
            }
            
            let commentData: [String: Any] = [
                "id": comment.id.uuidString,
                "text": comment.text,
                "commenter": comment.commenter,
                "timestamp": Timestamp(date: comment.timestamp),
                "commenterId": comment.commenterId
            ]
            
            document.reference.collection("comments").addDocument(data: commentData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    document.reference.updateData(["numComments": FieldValue.increment(Int64(1))]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                            completion(.failure(error))
                        } else {
                            print("Document successfully updated")
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    func deleteComment(_ comment: Comment, from post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let postId = post.id
        let query = db.collection(postsCollection).whereField("id", isEqualTo: postId.uuidString)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "No document found with matching post id"])))
                return
            }
            
            let commentsCollection = document.reference.collection("comments")
            commentsCollection.whereField("id", isEqualTo: comment.id.uuidString).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let commentDocument = querySnapshot?.documents.first else {
                    completion(.failure(NSError(domain: "Kobra", code: -1, userInfo: [NSLocalizedDescriptionKey: "No comment found with matching id"])))
                    return
                }
                
                commentDocument.reference.delete { error in
                    if let error = error {
                        print("Error deleting comment: \(error)")
                        completion(.failure(error))
                    } else {
                        document.reference.updateData(["numComments": FieldValue.increment(Int64(-1))]) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                                completion(.failure(error))
                            } else {
                                print("Document successfully updated")
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchProfilePicture(_ post: Post, completion: @escaping (Result<URL, Error>) -> Void) {
        let accountId = post.posterId
        let ref = db.collection("Accounts").document(accountId)

        ref.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "Error fetching account data", code: 0, userInfo: nil)))
                return
            }

            let data = document.data()!
            if let profilePictureURLString = data["profilePicture"] as? String,
               let profilePictureURL = URL(string: profilePictureURLString) {
                completion(.success(profilePictureURL))
            } else {
                completion(.failure(NSError(domain: "Invalid URL string", code: 0, userInfo: nil)))
            }
        }
    }
}
