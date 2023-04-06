//
//  KobraViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/31/23.
//

import Foundation
import Combine

class KobraViewModel: ObservableObject {
    @Published var posts: [Post] = []
    
    private let postManager = FSPostManager.shared
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        fetchPosts()
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
    
    func addPost(_ post: Post) {
        postManager.addPost(post) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPosts()
                case .failure(let error):
                    print("Error adding post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateLikeCount(_ post: Post, likeCount: Int) {
        postManager.updateLikeCount(post, likeCount: likeCount)
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
