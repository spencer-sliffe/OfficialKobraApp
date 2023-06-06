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
    @Published var isFollowing = false
    var currentUserId: String = ""
    
    func toggleFollowStatus() {
        guard let account = self.account else { return }

        isFollowing.toggle()

        DispatchQueue.main.async {
            let db = Firestore.firestore()
            let currentUserRef = db.collection("Accounts").document(self.currentUserId)
            let targetUserRef = db.collection("Accounts").document(account.id)

            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    let currentUserDocument = try transaction.getDocument(currentUserRef)
                    let targetUserDocument = try transaction.getDocument(targetUserRef)
                    var following = currentUserDocument.data()?["following"] as? [String] ?? []
                    var followers = targetUserDocument.data()?["followers"] as? [String] ?? []

                    if self.isFollowing {
                        following.append(account.id)
                        followers.append(self.currentUserId)
                    } else {
                        following.removeAll { $0 == account.id }
                        followers.removeAll { $0 == self.currentUserId }
                    }

                    transaction.updateData(["following": following], forDocument: currentUserRef)
                    transaction.updateData(["followers": followers], forDocument: targetUserRef)

                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }

                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                } else {
                    print("Transaction successfully committed!")
                }
            }
        }
    }


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

