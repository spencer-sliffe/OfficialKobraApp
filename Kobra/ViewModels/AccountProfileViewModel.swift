//
//  AccountProfileViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 6/5/23.
//

import Firebase
import SwiftUI
import Combine

class AccountProfileViewModel: ObservableObject {
    @Published var account: Account?
    @Published var isLoading = true
    let dataManager = FSAccountManager()
    @Published var userPosts: [Post] = []
    private var accountId: String
    var currentUserId: String = ""
    
    

    private var cancellables: Set<AnyCancellable> = []
    
    init(accountId: String) {
        self.accountId = accountId
        fetchAccount()
    }
    
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
                let followers = data["followers"] as? [String] ?? []
                let following = data["following"] as? [String] ?? []
                let account = Account(id: self.accountId, email: email, subscription: subscription, packageData: nil, profilePicture: nil, followers: followers, following: following)
                promise(.success(account))
            }
        }
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
}

