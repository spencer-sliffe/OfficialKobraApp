//
//  FollowViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 7/2/23.
//

import Foundation
import Combine
import Firebase

class FollowCellViewModel: ObservableObject {
    let dataManager = FSAccountManager.shared
    private var accountId: String
    @Published var account: Account?
    @Published var isLoading = true
    
    init(accountId: String) {
        self.accountId = accountId
        fetchAccount()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func fetchAccount() {
        let publisher = fetchUserData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { userData in
                self.account = userData
                self.isLoading = false
            })
        publisher.store(in: &cancellables)
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
                let username = data["username"] as? String ?? ""
                let subscription = data["subscription"] as? Bool ?? false
                let followers = data["followers"] as? [String] ?? []  // Holds ids
                let following = data["following"] as? [String] ?? []  // Holds ids
                let package = data["package"] as? String ?? ""
                let bio = data["bio"] as? String ?? ""
                var account = Account(id: self.accountId, email: email, username: username, subscription: subscription, package: package, profilePicture: nil, followers: followers, following: following, bio: bio)
                
                // Fetch and assign profile picture URL if available
                if let profilePictureURLString = data["profilePicture"] as? String,
                   let profilePictureURL = URL(string: profilePictureURLString) {
                    account.profilePicture = profilePictureURL
                }
                
                // Check if the current user is following this account
                promise(.success(account))
            }
        }
    }
}
