//
//  DiscoverViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/18/23.
//

import Foundation
import Combine
import Firebase

class DiscoverViewModel: ObservableObject {
    @Published var accounts = [Account]()
    @Published var searchResults = [Account]()
    @Published var posts: [Post] = []
    
    private var db = Firestore.firestore()
    private var postManager = FSPostManager.shared
    
    func fetchPosts() {
        postManager.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    // Reset posts array before assigning new posts
                    self?.posts = posts
                case .failure(let error):
                    print("Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchAccounts() {
        db.collection("Accounts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.accounts = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let newAccount = Account(
                        id: document.documentID, // use documentID as the account's id
                        email: data["email"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        subscription: data["subscription"] as? Bool ?? false,
                        package: data["package"] as? String ?? "",
                        profilePicture: data["profilePicture"] as? String,
                        followers: data["followers"] as? [String] ?? [""],
                        following: data["following"] as? [String] ?? [""],
                        bio: data["bio"] as? String ?? ""
                    )
                    self.accounts.append(newAccount)
                }
            }
        }
    }
    
    func fetchHotPosts() {
        
    }
    
    func searchAccounts(query: String) {
        if query.isEmpty {
            fetchAccounts()
        } else {
            searchResults = self.accounts.filter({$0.email.lowercased().contains(query.lowercased())})
        }
    }
    
    func clearSearchResults() {
        searchResults = []
    }
    
    func resetData() {
        accounts = []
        searchResults = []
        posts = []
    }
}

