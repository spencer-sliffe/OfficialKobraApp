//
// AccountViewModel.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import Firebase
import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    @Published var account: Account?
    @Published var isLoading = true
    let accountManager = FSAccountManager.shared
    @Published var userPosts: [Post] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
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
            guard let user = Auth.auth().currentUser else {
                promise(.failure(NSError(domain: "No user is currently signed in.", code: 0, userInfo: nil)))
                return
            }
            
            let db = Firestore.firestore()
            let ref = db.collection("Accounts").document(user.uid)
            ref.getDocument { (document, error) in
                guard let document = document, document.exists, error == nil else {
                    promise(.failure(NSError(domain: "Error fetching account data", code: 0, userInfo: nil)))
                    return
                }
                let data = document.data()!
                let email = user.email ?? ""
                let subscription = data["subscription"] as? Bool ?? false
                let followers = data["followers"] as? [String] ?? []
                let following = data["following"] as? [String] ?? []
                let package = data["package"] as? String ?? ""
                var account = Account(id: user.uid, email: email, subscription: subscription, package: package, profilePicture: nil, followers: followers, following: following)
                
                // Fetch and assign package data
                // Assign profile picture URL if available
                if let profilePictureURLString = data["profilePicture"] as? String,
                   let profilePictureURL = URL(string: profilePictureURLString) {
                    account.profilePicture = profilePictureURL
                }
                
                promise(.success(account))
            }
        }
    }
    
    private func fetchUserPosts() -> Future<[Post], Error> {
        Future { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(NSError(domain: "No user is currently signed in.", code: 0, userInfo: nil)))
                return
            }
            let userEmail = user.email ?? ""
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
    
    func updateProfilePicture(image: UIImage) {
        isLoading = true
        accountManager.uploadProfilePicture(image, userId: self.account?.id ?? "") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    self?.account?.profilePicture = URL(string: imageURL) // converting string to URL
                case .failure(let error):
                    print("Error uploading profile picture: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
}
