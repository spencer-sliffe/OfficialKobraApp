//
//  KobraViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/31/23.
//

import Foundation
import Combine
import SwiftUI

class KobraViewModel: ObservableObject {
    @Published var posts: [Post] = []
    
    private let postManager = FSPostManager.shared
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        fetchPosts()
    }
    
    func uploadImage(_ image: UIImage, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        postManager.uploadImage(image, postId: postId, completion: completion)
    }
    
    func fetchPosts() {
        postManager.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self?.posts = posts
                case .failure(let error):
                    print("Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addPost(_ post: Post, image: UIImage? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        if let image = image {
            postManager.uploadImage(image, postId: post.id.uuidString) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    var newPost = post
                    newPost.imageURL = imageURL
                    self?.addPostToDatabase(newPost, completion: completion)
                case .failure(let error):
                    print("Error uploading image: \(error.localizedDescription)")
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
                    self?.fetchPosts()
                    completion?(.success(()))
                case .failure(let error):
                    print("Error adding post: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func updateLikeCount(_ post: Post, likeCount: Int) {
        postManager.updateLikeCount(post, likeCount: likeCount)
        fetchPosts()
    }
    
    func updateDislikeCount(_ post: Post, dislikeCount: Int) {
        postManager.updateDislikeCount(post, dislikeCount: dislikeCount)
        fetchPosts()
    }
    
    func updatePost(_ post: Post) {
        postManager.updatePost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPosts()
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
                    self?.fetchPosts()
                case .failure(let error):
                    print("Error deleting post: \(error.localizedDescription)")
                }
            }
        }
    }
}
