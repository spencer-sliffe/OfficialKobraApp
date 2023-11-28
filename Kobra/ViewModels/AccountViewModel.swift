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
    @Published var accountId = ""
    
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
        let user = Auth.auth().currentUser
        self.accountId = user?.uid ?? ""
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
                let username = data["username"] as? String ?? ""
                let subscription = data["subscription"] as? Bool ?? false
                let followers = data["followers"] as? [String] ?? []
                let following = data["following"] as? [String] ?? []
                let package = data["package"] as? String ?? ""
                let bio = data["bio"] as? String ?? ""
                var account = Account(id: user.uid, email: email, username: username, subscription: subscription, package: package, profilePicture: nil, followers: followers, following: following, bio: bio)
                
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
            FSPostManager.shared.fetchUserPosts(userId: user.uid) { result in
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
    
    func deleteProfilePicture() {
        guard let imageUrl = self.account?.profilePicture?.absoluteString else {
            print("No image URL found for account")
            return
        }
        
        isLoading = true
        accountManager.deleteProfilePicture(imageURL: imageUrl) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.account?.profilePicture = nil
                    print("Profile picture deleted successfully")
                case .failure(let error):
                    print("Error deleting profile picture: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
    
    func updateBio(bio: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }

        isLoading = true
        accountManager.updateBio(userId: user.uid, bio: bio) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedBio):
                    self?.account?.bio = updatedBio
                    print("Bio updated successfully")
                case .failure(let error):
                    print("Error updating bio: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }

    func deleteBio() {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }

        isLoading = true
        accountManager.updateBio(userId: user.uid, bio: "") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.account?.bio = ""
                    print("Bio deleted successfully")
                case .failure(let error):
                    print("Error deleting bio: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
    
    func updateUsername(username: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }

        isLoading = true
        accountManager.updateUsername(userId: user.uid, username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUsername):
                    self?.account?.username = updatedUsername
                    print("Username updated successfully")
                case .failure(let error):
                    print("Error updating username: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
}
