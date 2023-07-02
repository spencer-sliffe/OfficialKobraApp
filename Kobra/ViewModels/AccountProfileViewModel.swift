//
//  AccountProfileViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 6/6/23.
//

import Foundation
import Combine
import Firebase

class AccountProfileViewModel: ObservableObject {
    @Published var account: Account?
    @Published var isLoading = true
    let dataManager = FSAccountManager.shared
    @Published var userPosts: [Post] = []
    private var accountId: String
    var currentUserId: String = ""
    @Published var isFollowing = false
    @Published var followers: [String] = []
    @Published var following: [String] = []
    @Published var showFollowButton = true
    init(accountId: String) {
        self.accountId = accountId
        fetchAccount()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func fetchAccount() {
        Publishers.CombineLatest(fetchUserData(), fetchUserPosts())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { userData, userPosts in
                self.account = userData
                self.userPosts = userPosts
                self.isLoading = false
            })
            .store(in: &cancellables)
        
        // Listen for account updates
        dataManager.accountDidUpdate = { result in
            switch result {
            case .success(let updatedAccount):
                self.account = updatedAccount
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func fetchUserData() -> Future<Account, Error> {
        Future { promise in
            let db = Firestore.firestore()
            let ref = db.collection("Accounts").document(self.accountId)
            guard let currentUser = Auth.auth().currentUser else {
                print("Error: No user is currently signed in.")
                return
            }
            let currentUserId = currentUser.uid
            if currentUserId == self.accountId {
                self.showFollowButton = false
            }
            ref.getDocument { (document, error) in
                guard let document = document, document.exists, error == nil else {
                    promise(.failure(NSError(domain: "Error fetching account data", code: 0, userInfo: nil)))
                    return
                }
                let data = document.data()!
                let email = data["email"] as? String ?? ""
                let username = data["username"] as? String ?? ""
                let subscription = data["subscription"] as? Bool ?? false
                let followers = data["followers"] as? [String] ?? []  // Holds ids
                self.followers = followers
                let following = data["following"] as? [String] ?? []  // Holds ids
                self.following = following
                let package = data["package"] as? String ?? ""
                let bio = data["bio"] as? String ?? ""
                var account = Account(id: self.accountId, email: email, username: username, subscription: subscription, package: package, profilePicture: nil, followers: followers, following: following, bio: bio)
                
                // Fetch and assign profile picture URL if available
                if let profilePictureURLString = data["profilePicture"] as? String,
                   let profilePictureURL = URL(string: profilePictureURLString) {
                    account.profilePicture = profilePictureURL
                }
                
                // Check if the current user is following this account
                if let currentUserId = Auth.auth().currentUser?.uid {
                    self.isFollowing = followers.contains(currentUserId)
                }
                
                promise(.success(account))
            }
        }
    }
    
    private func fetchUserPosts() -> Future<[Post], Error> {
        Future { promise in
            FSPostManager.shared.fetchUserPosts(userId: self.accountId) { result in
                switch result {
                case .success(let posts):
                    promise(.success(posts))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    func followAccountById() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No user is currently signed in.")
            return
        }
        
        let currentUserId = currentUser.uid
        let db = Firestore.firestore()
        
        // Update the following list of the current user
        db.collection("Accounts").document(currentUserId).updateData([
            "following": FieldValue.arrayUnion([self.accountId])
        ]) { error in
            if let error = error {
                print("Error following account: \(error)")
                return
            }
            
            // If no error, update the followers list of the target user
            db.collection("Accounts").document(self.accountId).updateData([
                "followers": FieldValue.arrayUnion([currentUserId])
            ]) { error in
                if let error = error {
                    print("Error updating followers list of the account: \(error)")
                    return
                }
                
                // If both updates are successful, update the UI and fetch new account data
                DispatchQueue.main.async {
                    self.isFollowing = true
                    self.fetchAccount()  // Refresh account data
                }
            }
        }
    }
    
    func unfollowAccountById() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No user is currently signed in.")
            return
        }
        
        let currentUserId = currentUser.uid
        let db = Firestore.firestore()
        
        // Update the following list of the current user
        db.collection("Accounts").document(currentUserId).updateData([
            "following": FieldValue.arrayRemove([self.accountId])
        ]) { error in
            if let error = error {
                print("Error unfollowing account: \(error)")
                return
            }
            
            // If no error, update the followers list of the target user
            db.collection("Accounts").document(self.accountId).updateData([
                "followers": FieldValue.arrayRemove([currentUserId])
            ]) { error in
                if let error = error {
                    print("Error updating followers list of the account: \(error)")
                    return
                }
                
                // If both updates are successful, update the UI and fetch new account data
                DispatchQueue.main.async {
                    self.isFollowing = false
                    self.fetchAccount()  // Refresh account data
                }
            }
        }
    }
}

