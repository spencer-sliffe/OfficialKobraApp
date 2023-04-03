//
//  FSPostManager.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/1/23.
//

import Foundation
import FirebaseFirestore
import Firebase

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
    
    private func createPostFrom(data: [String: Any]) -> Post {
        let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        let likes = data["likes"] as? Int ?? 0
        let postTypeString = data["postType"] as? String ?? ""
        
        var postType: Post.PostType
        
        switch postTypeString {
        case "advertisement":
            let poster = data["poster"] as? String ?? ""
            let title = data["title"] as? String ?? ""
            let content = data["content"] as? String ?? ""
            let advertisementPost = AdvertisementPost(poster: poster, title: title, content: content)
            postType = .advertisement(advertisementPost)
        case "help":
            let poster = data["poster"] as? String ?? ""
            let question = data["question"] as? String ?? ""
            let details = data["details"] as? String ?? ""
            let helpPost = HelpPost(poster: poster, question: question, details: details)
            postType = .help(helpPost)
        case "news":
            let poster = data["poster"] as? String ?? ""
            let headline = data["headline"] as? String ?? ""
            let article = data["article"] as? String ?? ""
            let newsPost = NewsPost(poster: poster, headline: headline, article: article)
            postType = .news(newsPost)
        case "market":
            let vendor = data["vendor"] as? String ?? ""
            let marketPostTypeString = data["marketPostType"] as? String ?? ""
            var marketPostType: MarketPost.MarketPostType
            
            switch marketPostTypeString {
            case "hardware":
                let name = data["name"] as? String ?? ""
                let condition = Hardware.HardwareCondition(rawValue: data["condition"] as? String ?? "used") ?? .used
                let price = data["price"] as? Double ?? 0.0
                let hardware = Hardware(name: name, condition: condition, price: price)
                marketPostType = .hardware(hardware)
            case "software":
                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let price = data["price"] as? Double ?? 0.0
                let category = data["category"] as? String ?? ""
                let software = Software(name: name, description: description, price: price, category: category)
                marketPostType = .software(software)
            case "service":
                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let price = data["price"] as? Double ?? 0.0
                let category = data["category"] as? String ?? ""
                let service = Service(name: name, description: description, price: price, category: category)
                marketPostType = .service(service)
            case "other":
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let other = Other(title: title, description: description)
                marketPostType = .other(other)
            default:
                fatalError("Unknown market post type")
            }
            
            let marketPost = MarketPost(vendor: vendor, type: marketPostType)
            postType = .market(marketPost)
        default:
            fatalError("Unknown post type")
        }
        
        return Post(id: id, type: postType, likes: likes)
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
            "likes": post.likes
        ]
        
        var postTypeString: String
        var marketPostTypeString: String?
        
        switch post.type {
        case .advertisement(let advertisementPost):
            postTypeString = "advertisement"
            data["poster"] = advertisementPost.poster
            data["title"] = advertisementPost.title
            data["content"] = advertisementPost.content
        case .help(let helpPost):
            postTypeString = "help"
            data["poster"] = helpPost.poster
            data["question"] = helpPost.question
            data["details"] = helpPost.details
        case .news(let newsPost):
            postTypeString = "news"
            data["poster"] = newsPost.poster
            data["headline"] = newsPost.headline
            data["article"] = newsPost.article
        case .market(let marketPost):
            postTypeString = "market"
            data["vendor"] = marketPost.vendor
            
            switch marketPost.type {
            case .hardware(let hardware):
                marketPostTypeString = "hardware"
                data["name"] = hardware.name
                data["condition"] = hardware.condition == .new ? "new" : "used"
                data["price"] = hardware.price
            case .software(let software):
                marketPostTypeString = "software"
                data["name"] = software.name
                data["description"] = software.description
                data["price"] = software.price
                data["category"] = software.category
            case .service(let service):
                marketPostTypeString = "service"
                data["name"] = service.name
                data["description"] = service.description
                data["price"] = service.price
                data["category"] = service.category
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
        return data
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
        let id = post.id
        
        db.collection(postsCollection).document(id.uuidString).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateLikeCount(_ post: Post, likeCount: Int) {
        let id = post.id
        let postRef = db.collection(postsCollection).document(id.uuidString)
        
        postRef.updateData([
            "likes": likeCount
        ]) { error in
            if let error = error {
                print("Error updating like count: \(error.localizedDescription)")
            } else {
                print("Like count updated successfully")
            }
        }
    
    }

}
