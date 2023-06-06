//
//  AccountProfileViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 6/6/23.
//

import Foundation
import Combine
import FirebaseFirestore

class AccountProfileViewModel: ObservableObject {
    @Published var account: Account?
    @Published var isLoading = true
    let dataManager = FSAccountManager.shared
    @Published var userPosts: [Post] = []
    private var accountId: String
    var currentUserId: String = ""
    @Published var isFollowing = false
    
    init(accountId: String) {
        self.accountId = accountId
        fetchAccount()
        checkFollowStatus()
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
                self.checkFollowStatus()  // Call checkFollowStatus here
            })
            .store(in: &cancellables)
        
        // Listen for account updates
        dataManager.accountDidUpdate = { result in
            switch result {
            case .success(let updatedAccount):
                self.account = updatedAccount
                self.checkFollowStatus()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func fetchUserData() -> Future<Account, Error> {
        Future { promise in
            let db = Firestore.firestore()
            let ref = db.collection("Accounts").document(self.accountId)
            ref.getDocument { (document, error) in
                guard let document = document, document.exists, error == nil else {
                    promise(.failure(NSError(domain: "Error fetching account data", code: 0, userInfo: nil)))
                    return
                }
                let data = document.data()!
                let email = data["email"] as? String ?? ""
                let subscription = data["subscription"] as? Bool ?? false
                let followers = data["followers"] as? [String] ?? []  // Holds emails
                let following = data["following"] as? [String] ?? []  // Holds emails
                let account = Account(id: self.accountId, email: email, subscription: subscription, packageData: nil, profilePicture: nil, followers: followers, following: following)
                promise(.success(account))
            }
        }
    }
    
    func toggleFollow() {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "currentUserEmail") else { return }
        if isFollowing {
            // Unfollow logic here
            if let index = account?.followers.firstIndex(of: currentUserEmail) {
                account?.followers.remove(at: index)
                dataManager.unfollow(userToUnfollow: self.accountId)  // Pass the user's accountId here, not the currentUserEmail
            }
        } else {
            // Follow logic here
            account?.followers.append(currentUserEmail)
            dataManager.follow(userToFollow: self.accountId)  // Pass the user's accountId here, not the currentUserEmail
        }
        isFollowing.toggle()
    }
    
    private func fetchUserPosts() -> Future<[Post], Error> {
        Future { promise in
            let db = Firestore.firestore()
            let ref = db.collection("Accounts").document(self.accountId)
            ref.getDocument { (document, error) in
                guard let document = document, document.exists, error == nil else {
                    promise(.failure(NSError(domain: "Error fetching account data", code: 0, userInfo: nil)))
                    return
                }
                let data = document.data()!
                let userEmail = data["email"] as? String ?? ""
                let emailComponents = userEmail.split(separator: "@")
                let displayName = String(emailComponents[0])
                FSPostManager.shared.fetchUserPosts(userEmail: displayName) { result in
                    switch result {
                    case .success(let posts):
                        promise(.success(posts))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    private func checkFollowStatus() {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "currentUserEmail"), let account = account else { return }
        isFollowing = account.followers.contains(currentUserEmail)
    }
}

